// import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:findeals/models/transaction_data.dart';

// class TransactionsPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final transactionBox = Hive.box<TransactionModel>('transactions');

//     return ValueListenableBuilder(
//       valueListenable: transactionBox.listenable(),
//       builder: (context, Box<TransactionModel> box, _) {
//         final transactions = box.values.toList();

//         // Sort transactions in descending order (latest first)
//         transactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));

//         if (transactions.isEmpty) {
//           return Center(
//             child: Text(
//               "No transactions found",
//               style: TextStyle(fontSize: 16, color: Colors.grey),
//             ),
//           );
//         }

//         return SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.all(10.0),
//             child: ListView.builder(
//               itemCount: transactions.length,
//               itemBuilder: (context, index) {
//                 final txn = transactions[index];
//                 return TransactionTile(transaction: txn);
//               },
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// class TransactionTile extends StatelessWidget {
//   final TransactionModel transaction;

//   TransactionTile({required this.transaction});

//   @override
//   Widget build(BuildContext context) {
//     bool isDebit = transaction.transactionType == "Debited";

//     return Container(
//       constraints: BoxConstraints(
//         minHeight: 80, // Ensures content does not shrink too much
//       ),
//       margin: EdgeInsets.symmetric(vertical: 5),
//       padding: EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.shade200,
//             blurRadius: 5,
//             spreadRadius: 2,
//           )
//         ],
//       ),
//       child: Row(
//         children: [
//           // Transaction Type Icon
//           CircleAvatar(
//             radius: 25,
//             backgroundColor: isDebit ? Colors.red[100] : Colors.green[100],
//             child: Icon(
//               isDebit ? Icons.arrow_downward : Icons.arrow_upward,
//               color: isDebit ? Colors.red : Colors.green,
//             ),
//           ),
//           SizedBox(width: 12),

//           // Transaction Details
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   transaction.merchantName,
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   overflow: TextOverflow.ellipsis, // Prevents text overflow
//                 ),
//                 SizedBox(height: 4),
//                 Text(
//                   transaction.bankName,
//                   style: TextStyle(fontSize: 14, color: Colors.grey[700]),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 SizedBox(height: 4),
//                 Text(
//                   "${transaction.timestamp.day}-${transaction.timestamp.month}-${transaction.timestamp.year}, ${_formatTime(transaction.timestamp)}",
//                   style: TextStyle(fontSize: 12, color: Colors.grey),
//                 ),
//               ],
//             ),
//           ),

//           // Transaction Amount
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Text(
//                 "₹${transaction.amount.toStringAsFixed(2)}",
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: isDebit ? Colors.red : Colors.green,
//                 ),
//               ),
//               SizedBox(height: 4),
//               Text(
//                 transaction.productType,
//                 style: TextStyle(fontSize: 12, color: Colors.grey),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatTime(DateTime timestamp) {
//     return "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";
//   }
// }
