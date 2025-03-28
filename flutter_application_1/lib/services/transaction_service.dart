import 'dart:collection';

class TransactionService {
  final List<Map<String, dynamic>> transactions = [];

  // Predefined categories
  final Map<String, String> categories = {
    "Dominos": "Food",
    "Amazon": "Shopping",
    "BigBazaar": "Groceries",
    "Uber": "Transport",
  };

  void addTransaction(Map<String, dynamic> transaction) {
    // Assign category based on recipient name
    String category = categories[transaction["recipient"]] ?? "Others";
    transaction["category"] = category;
    transaction["date"] = DateTime.now().toString();

    transactions.add(transaction);
  }

  List<Map<String, dynamic>> getTransactions() {
    return UnmodifiableListView(transactions);
  }
}
