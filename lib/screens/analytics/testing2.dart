import 'package:flutter/material.dart';
import '../../models/db_helper.dart';
import '../../models/category_update.dart';

class AllTransactionsScreen extends StatefulWidget {
  const AllTransactionsScreen({super.key});

  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
     runCategoryUpdateAndFetch();
  }
   Future<void> runCategoryUpdateAndFetch() async {
    setState(() => isLoading = true);

    // 🔁 Step 1: Run category update logic before fetching
    final categoryUpdater = CategoryUpdater();
    await categoryUpdater.updateUncategorizedTransactions();

    // 🔄 Step 2: Now fetch transactions
    await fetchTransactions();

    setState(() => isLoading = false);
  }

  Future<void> fetchTransactions() async {
    final db = await dbHelper.database;
    final result = await db.query(
      'tranlog',
      orderBy: 'timestamp DESC', // Descending order
    );
    setState(() {
      transactions = result;
      isLoading = false;
    });
  }

  String formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Transactions'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : transactions.isEmpty
              ? const Center(child: Text('No transactions found.'))
              : ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text(
                          tx['merchantName'] ?? 'Unknown Merchant',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${tx['category'] ?? 'Uncategorized'} • ${formatTimestamp(tx['timestamp'])}',
                        ),
                        trailing: Text(
                          '₹${tx['amount'].toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
