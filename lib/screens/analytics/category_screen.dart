import 'package:flutter/material.dart';
import 'package:findeals/models/db_helper.dart';
import 'package:intl/intl.dart';

class CategoryAnalyticsScreen extends StatefulWidget {
  const CategoryAnalyticsScreen({Key? key}) : super(key: key);

  @override
  _CategoryAnalyticsScreenState createState() =>
      _CategoryAnalyticsScreenState();
}

class _CategoryAnalyticsScreenState extends State<CategoryAnalyticsScreen> {
  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _summary = [];
  final Map<String, List<Map<String, dynamic>>> _categoryTransactions = {};
  final Map<String, bool> _showUpdateUI = {};
  final Map<String, String?> _selectedCategory = {};

  int selectedMonthOffset = 0;

  final List<String> allCategories = [
    'Groceries',
    'Electronics',
    'Fuel',
    'Transportation',
    'Recharge & Bill Payments',
    'Health & Wellness',
    'Entertainment',
    'Shopping',
    'Food and Dining',
    'Travel',
    'Personal'
    'Uncategorized',
  ];

  final Map<String, IconData> _categoryIcons = {
    'Groceries': Icons.local_grocery_store,
    'Electronics': Icons.devices,
    'Fuel': Icons.local_gas_station,
    'Transportation': Icons.directions_bus,
    'Recharge & Bill Payments': Icons.receipt_long,
    'Health & Wellness': Icons.health_and_safety,
    'Entertainment': Icons.movie,
    'Shopping': Icons.shopping_bag,
    'Food and Dining': Icons.restaurant,
    'Travel': Icons.flight_takeoff,
    'Personal': Icons.person,
    'Uncategorized': Icons.category,
  };

  @override
  void initState() {
    super.initState();
    _loadCategorySummary();
  }

  Future<void> _loadCategorySummary() async {
    DateTime now = DateTime.now();
    DateTime startOfMonth =
        DateTime(now.year, now.month - selectedMonthOffset, 1);
    DateTime endOfMonth = DateTime(
        now.year, now.month - selectedMonthOffset + 1, 0, 23, 59, 59);

    final data = await dbHelper.getCategoryWiseSummaryByDate(
        startOfMonth.millisecondsSinceEpoch,
        endOfMonth.millisecondsSinceEpoch);
    setState(() {
      _summary = data;
      _categoryTransactions.clear();
    });
  }

  Future<void> _toggleCategoryExpansion(String category) async {
    if (_categoryTransactions.containsKey(category)) {
      setState(() {
        _categoryTransactions.remove(category);
      });
    } else {
      DateTime now = DateTime.now();
      DateTime startOfMonth =
          DateTime(now.year, now.month - selectedMonthOffset, 1);
      DateTime endOfMonth = DateTime(
          now.year, now.month - selectedMonthOffset + 1, 0, 23, 59, 59);

      final txns = await dbHelper.getTransactionsByCategoryAndDate(
        category,
        startOfMonth.millisecondsSinceEpoch,
        endOfMonth.millisecondsSinceEpoch,
      );
      setState(() {
        _categoryTransactions[category] = txns;
      });
    }
  }

  String formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formattedMonthYear() {
    DateTime now = DateTime.now();
    DateTime selected = DateTime(now.year, now.month - selectedMonthOffset);
    return DateFormat('MMMM, yyyy').format(selected);
  }

  Future<void> _updateCategoryForMerchant(
      String merchantName, String newCategory) async {
    await dbHelper.updateCategory(merchantName, newCategory);
    _loadCategorySummary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month Switcher
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_left),
                  onPressed: selectedMonthOffset < 2
                      ? () {
                          setState(() => selectedMonthOffset++);
                          _loadCategorySummary();
                        }
                      : null,
                ),
                Text(
                  _formattedMonthYear(),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_right),
                  onPressed: selectedMonthOffset > 0
                      ? () {
                          setState(() => selectedMonthOffset--);
                          _loadCategorySummary();
                        }
                      : null,
                ),
              ],
            ),
          ),
          const Divider(thickness: 1),

          // Category List
          Expanded(
            child: ListView.builder(
              itemCount: _summary.length,
              itemBuilder: (_, index) {
                final item = _summary[index];
                final category = item['category'] ?? 'Uncategorized';
                final txns = _categoryTransactions[category];

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: ExpansionTile(
                    leading: Icon(
                      _categoryIcons[category] ?? Icons.category,
                      color: Colors.blueAccent,
                    ),
                    title: Text(
                      category,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      "₹ ${item['totalSpend'].toStringAsFixed(2)}",
                      style: const TextStyle(color: Colors.black54),
                    ),
                    trailing: const Icon(Icons.expand_more),
                    initiallyExpanded: txns != null,
                    onExpansionChanged: (_) => _toggleCategoryExpansion(category),
                    children: txns != null && txns.isNotEmpty
                        ? txns.map<Widget>((txn) {
                            final txnId = '${txn['id']}';
                            final merchant = txn['merchantName'] ?? txn['merchant'] ?? 'Unknown';

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.receipt_long, size: 18, color: Colors.grey),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              merchant,
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              "₹${txn['amount'].toStringAsFixed(2)} • ${formatTimestamp(txn['timestamp'])}",
                                              style: const TextStyle(
                                                  fontSize: 12, color: Colors.black54),
                                            ),
                                          ],
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            _showUpdateUI[txnId] = !(_showUpdateUI[txnId] ?? false);
                                            _selectedCategory[txnId] = txn['category'] ?? 'Uncategorized';
                                          });
                                        },
                                        child: const Text("Update"),
                                      ),
                                    ],
                                  ),
                                  if (_showUpdateUI[txnId] ?? false)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Row(
                                        children: [
                                          DropdownButton<String>(
                                            value: _selectedCategory[txnId],
                                            hint: const Text("Select Category"),
                                            items: allCategories.map((cat) {
                                              return DropdownMenuItem(
                                                value: cat,
                                                child: Text(cat),
                                              );
                                            }).toList(),
                                            onChanged: (val) {
                                              setState(() {
                                                _selectedCategory[txnId] = val;
                                              });
                                            },
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              final selectedCat = _selectedCategory[txnId];
                                              if (selectedCat != null && selectedCat.isNotEmpty) {
                                                _updateCategoryForMerchant(merchant, selectedCat);
                                              }
                                            },
                                            child: const Text("Save"),
                                          ),
                                        ],
                                      ),
                                    )
                                ],
                              ),
                            );
                          }).toList()
                        : const [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Text("No transactions found",
                                  style: TextStyle(color: Colors.black54)),
                            )
                          ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
