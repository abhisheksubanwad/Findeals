import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/transaction_data.dart';
import '../services/sms_service.dart';

class TransactionProvider with ChangeNotifier {
  late Box<TransactionModel> transactionBox;
  late Box<dynamic> timestampBox;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<TransactionModel> get transactions => transactionBox.values.toList();

  TransactionProvider() {
    _initializeBoxes();
  }

  /// ✅ **Initialize Hive Boxes Before Loading Transactions**
  Future<void> _initializeBoxes() async {
    transactionBox = await Hive.openBox<TransactionModel>('transactions');
    timestampBox = await Hive.openBox<dynamic>('timestamp');

    print("✅ Hive boxes initialized successfully!");
    notifyListeners();

    // ✅ Only load transactions after both boxes are opened
    await loadTransactions();
  }

  /// ✅ **Fetch and Store Transactions Persistently**
  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    print("📦 Transactions box is open!");

    if (!Hive.isBoxOpen('timestamp')) {
      print("❌ timestampBox is not open yet!");
      _isLoading = false;
      notifyListeners();
      return;
    }

    SmsService smsService = SmsService();
    TransactionParser parser = TransactionParser();

    try {
      // ✅ Load last fetch time from Hive (or default to an old date)
      int? lastFetchEpoch = timestampBox.get('lastFetchTime');
      DateTime lastFetchTime = lastFetchEpoch != null
          ? DateTime.fromMillisecondsSinceEpoch(lastFetchEpoch)
          : DateTime(2000);

      // ✅ Fetch all transaction SMS
      List<Map<String, String>> smsList = await smsService.fetchTransactionSms();
      print("📩 Received SMS Count: ${smsList.length}");

      // ✅ Filter only new SMS received after the last fetch time
      List<Map<String, String>> newSms = smsList.where((sms) {
        String? dateStr = sms['date'];
        if (dateStr == null) return false;

        DateTime smsTime = DateTime.fromMillisecondsSinceEpoch(int.parse(dateStr));
        return smsTime.isAfter(lastFetchTime);
      }).toList();

      if (newSms.isNotEmpty) {
        print("🔄 Processing ${newSms.length} new transactions...");
        parser.processTransactions(newSms); // Process all new transactions
        timestampBox.put('lastFetchTime', DateTime.now().millisecondsSinceEpoch); // ✅ Update last fetch time
      } else {
        print("✅ No new transactions found.");
      }

      print("💾 Stored Transactions Count: ${transactionBox.length}");
    } catch (e) {
      print("⚠️ Error loading transactions: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ **Get Total Amount Spent By Product Type & Transaction Type**
  double totalAmountByType(String type, String transactionType) {
    DateTime now = DateTime.now();
    return transactions
        .where((txn) =>
            txn.productType == type &&
            txn.transactionType == transactionType &&
            txn.timestamp.year == now.year &&
            txn.timestamp.month == now.month)
        .fold(0.0, (sum, txn) => sum + txn.amount);
  }

  /// ✅ **Get Total Spend By Transaction Type (e.g., 'UPI', 'Credit')**
  double totalAmountByTransactionType(String type) {
    DateTime now = DateTime.now();
    return transactions
        .where((txn) =>
            txn.transactionType == type &&
            txn.timestamp.year == now.year &&
            txn.timestamp.month == now.month)
        .fold(0.0, (sum, txn) => sum + txn.amount);
  }
}
