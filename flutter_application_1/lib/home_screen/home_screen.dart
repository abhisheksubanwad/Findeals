// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:hive/hive.dart';
// import '../providers/transaction_provider.dart';
// import '../models/transaction_data.dart';
// import '../screens/analytics/analytics_screen.dart';

// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   int _currentIndex = 0;
//   Box<TransactionModel>? transactionBox;

//   @override
//   void initState() {
//     super.initState();
//     _initializeBoxes().then((_) {
//       setState(() {});
//     });
//   }

//   Future<void> _initializeBoxes() async {
   
    
//   Future.microtask(() =>
//       Provider.of<TransactionProvider>(context, listen: false)
//           .loadTransactions());
  
//   transactionBox = await Hive.openBox<TransactionModel>('transactions'); 
//   }

//   final List<Widget> _screens = [
//     HomeScreenContent(),
//     AnalyticsScreen(),
//     Placeholder(),
//     Placeholder(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFF5F7FA),
//       appBar: AppBar(
//         title: Text("Transaction Overview", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: Color(0xFF1E4DB7),
//       ),
//       body: IndexedStack(
//         index: _currentIndex,
//         children: _screens,
//       ),
//       bottomNavigationBar: _buildBottomNavBar(),
//     );
//   }

//   Widget _buildBottomNavBar() {
//     return BottomNavigationBar(
//       backgroundColor: Colors.white,
//       currentIndex: _currentIndex,
//       onTap: (index) {
//         setState(() {
//           _currentIndex = index;
//         });
//       },
//       selectedItemColor: Color(0xFF1E4DB7),
//       unselectedItemColor: Colors.grey,
//       items: [
//         BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
//         BottomNavigationBarItem(icon: Icon(Icons.analytics), label: "Analytics"),
//         BottomNavigationBarItem(icon: Icon(Icons.local_offer), label: "Offers"),
//         BottomNavigationBarItem(icon: Icon(Icons.person), label: "User"),
//       ],
//     );
//   }
// }

// class HomeScreenContent extends StatelessWidget {
//   String getBankLogo(String bankName) {
//     Map<String, String> bankLogos = {
//       "ICICI": "icici.png",
//       "HDFC": "hdfc.png",
//       "SBI": "sbi.png",
//       "Axis": "axis.png",
//       "ONECARD": "onecard.png"
//     };
//     return 'assets/logos/${bankLogos[bankName] ?? "default.png"}';
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<TransactionProvider>(context);
//     return provider.isLoading
//         ? Center(child: CircularProgressIndicator())
//         : SingleChildScrollView(
//             padding: EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildGreeting(),
//                 SizedBox(height: 20),
//                 _buildBankWiseSpending(),
//               ],
//             ),
//           );
//   }

//   Widget _buildGreeting() {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 16),
//       decoration: BoxDecoration(
//         color: Color(0xFF1E4DB7),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 16),
//         child: Text(
//           "Welcome 👋",
//           style: TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildBankWiseSpending() {
//     Map<String, Map<String, double>> spendingData = _calculateSpendingFromHive();
//     return Column(
//       children: spendingData.entries.map((bankEntry) {
//         print("Loading logo: ${getBankLogo(bankEntry.key)}");
        
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [

//                 Image.asset(
//                   getBankLogo(bankEntry.key),
//                   width: 40,
//                   height: 40,
//                   errorBuilder: (context, error, stackTrace) => Icon(Icons.account_balance, size: 40),
//                 ),
//                 SizedBox(width: 10),

//                 Text(
//                   bankEntry.key,
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
//                 ),
//               ],
//             ),
//             ...bankEntry.value.entries.map((transactionType) {
//               return _buildSummaryTile(transactionType.key, transactionType.value);
//             }).toList(),
//             SizedBox(height: 20),
//           ],
//         );
//       }).toList(),
//     );
//   }

//   Map<String, Map<String, double>> _calculateSpendingFromHive() {
//     Box<TransactionModel>? transactionBox = Hive.box<TransactionModel>('transactions');
//     Map<String, Map<String, double>> spendingData = {};
//     DateTime now = DateTime.now();
//     int currentMonth = now.month;
//     int currentYear = now.year;

//     for (var transaction in transactionBox.values) {
//       if (transaction.timestamp.month == currentMonth && transaction.timestamp.year == currentYear) {
//         if (!spendingData.containsKey(transaction.bankName)) {
//           spendingData[transaction.bankName] = {
//             'UPI': 0.0,
//             'Debit Card': 0.0,
//             'Credit Card': 0.0,
//           };
//         }

//         if (transaction.transactionType == "Debited") {
//           spendingData[transaction.bankName]![transaction.productType] =
//               (spendingData[transaction.bankName]![transaction.productType] ?? 0) + transaction.amount;
//         }
//       }
//     }
//     return spendingData;
//   }

//   Widget _buildSummaryTile(String category, double amount) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       margin: EdgeInsets.symmetric(vertical: 10),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8.0),
//         child: ListTile(
//           leading: Icon(Icons.currency_rupee, color: Color(0xFF1E4DB7)),
//           title: Text(
//             category,
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
//             overflow: TextOverflow.ellipsis,
//           ),
//           trailing: Text(
//             "₹${amount.toStringAsFixed(2)}",
//             style: TextStyle(
//                 fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
//           ),
//         ),
//       ),
//     );
//   }
// }
