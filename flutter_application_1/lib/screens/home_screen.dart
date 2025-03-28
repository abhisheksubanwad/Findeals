import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedMonth = 1; // January
  int selectedYear = 2021;
  double totalExpenses = 4853.72;
  double totalIncome = 8700.00;
  double totalBalance = 3846.28;

  List<Map<String, dynamic>> transactions = [
    {"date": "Jan 03, Sunday", "transactions": [
      {"category": "Clothing", "amount": -65.55, "method": "Card", "icon": Icons.shopping_bag},
      {"category": "Broadband Bill", "amount": -80.00, "method": "Card", "icon": Icons.wifi},
      {"category": "Shopping", "amount": -120.00, "method": "Card", "icon": Icons.store},
      {"category": "Bills", "amount": -150.60, "method": "Wallet", "icon": Icons.receipt}
    ]},
    {"date": "Jan 02, Saturday", "transactions": [
      {"category": "Entertainment", "amount": -30.15, "method": "Card", "icon": Icons.movie},
      {"category": "Snacks", "amount": -55.00, "method": "Wallet", "icon": Icons.fastfood},
      {"category": "Health", "amount": -50.00, "method": "Card", "icon": Icons.local_hospital}
    ]},
  ];

  void _changeMonth(int direction) {
    setState(() {
      selectedMonth += direction;
      if (selectedMonth == 0) {
        selectedMonth = 12;
        selectedYear--;
      } else if (selectedMonth == 13) {
        selectedMonth = 1;
        selectedYear++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.black),
          onPressed: () {},
        ),
        title: Text(
          "MyMoney",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_left, size: 24, color: Colors.black),
                  onPressed: () => _changeMonth(-1),
                ),
                Text(
                  "${_getMonthName(selectedMonth)}, $selectedYear",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_right, size: 24, color: Colors.black),
                  onPressed: () => _changeMonth(1),
                ),
              ],
            ),

            SizedBox(height: 10),

            // Expense, Income & Total
            Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _summaryItem("EXPENSE", totalExpenses, Colors.red),
                  _summaryItem("INCOME", totalIncome, Colors.green),
                  _summaryItem("TOTAL", totalBalance, Colors.black),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Transactions List
            Expanded(
              child: ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transactionDate = transactions[index]["date"];
                  final transactionList = transactions[index]["transactions"];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 10, bottom: 5),
                        child: Text(
                          transactionDate,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ),
                      ...transactionList.map<Widget>((transaction) {
                        return TransactionCard(transaction: transaction);
                      }).toList(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () {
          // Future: Add Manual Transaction
        },
      ),
    );
  }

  Widget _summaryItem(String title, double amount, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
        ),
        SizedBox(height: 4),
        Text(
          "₹${amount.toStringAsFixed(2)}",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    List<String> months = [
      "", "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];
    return months[month];
  }
}

class TransactionCard extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const TransactionCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 4),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blueGrey[50],
          child: Icon(transaction["icon"], color: Colors.blueGrey),
        ),
        title: Text(
          transaction["category"],
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          transaction["method"],
          style: TextStyle(color: Colors.grey),
        ),
        trailing: Text(
          "${transaction["amount"] < 0 ? '-' : ''}₹${transaction["amount"].abs().toStringAsFixed(2)}",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: transaction["amount"] < 0 ? Colors.red : Colors.green,
          ),
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import '../services/sms_service.dart';
// import '../services/transaction_service.dart';

// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final SmsService _smsService = SmsService();
//   final TransactionService _transactionService = TransactionService();
//   List<Map<String, dynamic>> transactions = [];
//   double totalExpenses = 0.0;

//   @override
//   void initState() {
//     super.initState();
//     _fetchSmsTransactions();
//   }

//   void _fetchSmsTransactions() async {
//     List<Map<String, dynamic>> fetchedTransactions = await _smsService.fetchTransactionSms();
//     double total = 0.0;
//     for (var transaction in fetchedTransactions) {
//       _transactionService.addTransaction(transaction);
//       total += double.parse(transaction["amount"]);
//     }
//     setState(() {
//       transactions = _transactionService.getTransactions();
//       totalExpenses = total;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         title: const Text(
//           "Expense Tracker",
//           style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: Colors.black,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.account_circle, size: 28),
//             onPressed: () {
//               // Navigate to Profile Page (Future Implementation)
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.logout, size: 28),
//             onPressed: () {
//               // Navigate back to Login Screen
//               Navigator.pushReplacementNamed(context, "/login");
//             },
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Total Expense Section
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.grey[900],
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     "Total Expenses",
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
//                   ),
//                   Text(
//                     "₹${totalExpenses.toStringAsFixed(2)}",
//                     style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),

//             const Text(
//               "Recent Transactions",
//               style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
//             ),
//             const SizedBox(height: 10),

//             // Transaction List
//             Expanded(
//               child: transactions.isEmpty
//                   ? const Center(
//                       child: Text(
//                         "No transactions found",
//                         style: TextStyle(color: Colors.white70, fontSize: 16),
//                       ),
//                     )
//                   : ListView.builder(
//                       itemCount: transactions.length,
//                       itemBuilder: (context, index) {
//                         final transaction = transactions[index];
//                         return TransactionCard(transaction: transaction);
//                       },
//                     ),
//             ),
//           ],
//         ),
//       ),

//       // Floating Action Button for future transaction addition
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Colors.blueAccent,
//         child: const Icon(Icons.add, color: Colors.white),
//         onPressed: () {
//           // Future: Add Manual Transaction
//         },
//       ),
//     );
//   }
// }

// // Transaction Card UI
// class TransactionCard extends StatelessWidget {
//   final Map<String, dynamic> transaction;

//   const TransactionCard({super.key, required this.transaction});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       color: Colors.grey[900],
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       child: ListTile(
//         leading: CircleAvatar(
//           backgroundColor: getCategoryColor(transaction["category"]),
//           child: const Icon(Icons.attach_money, color: Colors.white),
//         ),
//         title: Text(
//           "₹${transaction["amount"]} - ${transaction["recipient"]}",
//           style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         subtitle: Text(
//           "Account: ****${transaction["accountNumber"]} | ${transaction["category"]}",
//           style: const TextStyle(color: Colors.grey),
//         ),
//         trailing: Text(
//           transaction["date"],
//           style: const TextStyle(color: Colors.white54, fontSize: 12),
//         ),
//       ),
//     );
//   }

//   // Function to assign color based on transaction category
//   Color getCategoryColor(String category) {
//     switch (category) {
//       case "Food":
//         return Colors.orange;
//       case "Shopping":
//         return Colors.blue;
//       case "Transport":
//         return Colors.green;
//       case "Bills":
//         return Colors.purple;
//       default:
//         return Colors.grey;
//     }
//   }
// }
