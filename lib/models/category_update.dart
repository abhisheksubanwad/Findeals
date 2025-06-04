import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:hive/hive.dart';
import '../models/db_helper.dart';
import 'package:string_similarity/string_similarity.dart';

class CategoryUpdater {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> updateUncategorizedTransactions() async {
    try {
      // ✅ Open Hive box only once
      final categoryBox = await Hive.openBox('merchantCategory');
      final transactions = await _dbHelper.getUncategorizedTransactions();
      print("🟡 Found ${transactions.length} uncategorized transactions");

      // ✅ Prepare lowercase merchant mapping once to avoid repeated I/O
      final hiveMap = {
        for (var key in categoryBox.keys)
          key.toString().toLowerCase().trim(): categoryBox.get(key)
      };

      for (var txn in transactions) {
        final rawMerchant = txn['merchantName']?.toString() ?? '';
        final merchantKey = rawMerchant.toLowerCase().trim();

        if (merchantKey.isEmpty) {
          print("⚠️ Skipping empty merchant name");
          continue;
        }

        String? matchedCategory;

        // 🧠 1. Exact match
        matchedCategory = hiveMap[merchantKey];

        // 🧠 2. Partial match
        if (matchedCategory == null) {
          matchedCategory = hiveMap.entries.firstWhere(
            (entry) => merchantKey.contains(entry.key),
            orElse: () => const MapEntry('', null),
          ).value;

          if (matchedCategory != null) {
            print("🟨 Partial match for $merchantKey");
          }
        }

        // 🧠 3. Fuzzy match
        if (matchedCategory == null) {
          final matches = hiveMap.keys
              .map((key) => {'key': key, 'score': key.similarityTo(merchantKey)})
              .where((entry) => (entry['score'] as double) > 0.7)
              .toList()
            ..sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));

          if (matches.isNotEmpty) {
            final bestMatchKey = matches.first['key'] as String;
            matchedCategory = hiveMap[bestMatchKey];
            print("🟧 Fuzzy match for $merchantKey -> $bestMatchKey (${matches.first['score']})");
          }
        }

        // ✅ 4. Final update or fallback
        if (matchedCategory != null) {
          await _dbHelper.updateCategory(txn['merchant'], matchedCategory);
          print("✅ Updated '${txn['merchant']}' with category '$matchedCategory'");
        } else {
          print("❌ No match for: $merchantKey — needs manual input");
        }
      }

      await categoryBox.close();
    } catch (e) {
      print("❌ Error updating categories: $e");
    }
  }
}
