import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telephony/telephony.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isPermissionGranted = false;
  List<String> accountNumbers = []; // Stores extracted account numbers
  List<SmsMessage> transactionMessages = [];
  final Telephony telephony = Telephony.instance;
  int currentIndex = 0; // Track which account is being processed

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    var status = await Permission.sms.status;

    if (status.isGranted) {
      setState(() => isPermissionGranted = true);
      _fetchTransactionMessages(); // Fetch messages immediately
    } else {
      _requestPermission();
    }
  }

  Future<void> _requestPermission() async {
    var status = await Permission.sms.request();

    if (status.isGranted) {
      setState(() => isPermissionGranted = true);
      _fetchTransactionMessages(); // Fetch messages after granting permission
    } else {
      _showPermissionDeniedDialog();
    }
  }

  Future<void> _showPermissionDeniedDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Permission Required"),
        content: Text("This app needs SMS permission to read transaction messages."),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _requestPermission();
            },
            child: Text("Grant Permission"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchTransactionMessages() async {
    List<SmsMessage> messages = await telephony.getInboxSms(
      columns: [SmsColumn.BODY, SmsColumn.ADDRESS, SmsColumn.DATE],
    );

    List<SmsMessage> filteredMessages = messages.where((msg) {
      return _isTransactionMessage(msg.body!);
    }).toList();

    // Extract unique account numbers from all messages
    Set<String> extractedNumbers = {};
    for (var msg in filteredMessages) {
      String? accNo = _extractAccountNumber(msg.body!);
      if (accNo != null) extractedNumbers.add(accNo);
    }

    setState(() {
      transactionMessages = filteredMessages;
      accountNumbers = extractedNumbers.toList();
    });

    if (accountNumbers.isNotEmpty) {
      _showSelectionDialog(currentIndex);
    }
  }

  bool _isTransactionMessage(String message) {
    List<String> keywords = ["debited", "txn", "transaction", "UPI", "balance", "INR"];
    return keywords.any((keyword) => message.toLowerCase().contains(keyword));
  }

  String? _extractAccountNumber(String message) {
    RegExp regExp = RegExp(r'A\/C\s?[Xx]*?(\d{4})'); // Extracts last 4 digits
    Match? match = regExp.firstMatch(message);
    return match != null ? match.group(1) : null;
  }

  Future<void> _showSelectionDialog(int index) async {
    if (index >= accountNumbers.length) return; // Stop if all accounts are processed

    String accountNo = accountNumbers[index];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("A/C No. $accountNo"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOptionTile(accountNo, "Account Number"),
            _buildOptionTile(accountNo, "Credit Card"),
            _buildOptionTile(accountNo, "Debit Card"),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(String accountNo, String option) {
    return ListTile(
      title: Text(option),
      leading: Radio<String>(
        value: option,
        groupValue: null,
        onChanged: (value) {
          _saveSelection(accountNo, value!);
          Navigator.pop(context);

          // Move to the next account number selection
          if (currentIndex < accountNumbers.length - 1) {
            currentIndex++;
            _showSelectionDialog(currentIndex);
          }
        },
      ),
    );
  }

  Future<void> _saveSelection(String accountNo, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("selected_${accountNo}", value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      body: isPermissionGranted
          ? transactionMessages.isNotEmpty
              ? ListView.builder(
                  itemCount: transactionMessages.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(transactionMessages[index].body!),
                      subtitle: Text(transactionMessages[index].address!),
                    );
                  },
                )
              : Center(child: Text("No transaction messages found."))
          : Center(child: CircularProgressIndicator()),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:telephony/telephony.dart';

// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   bool isPermissionGranted = false;
//   String? selectedOption;
//   String? extractedAccountNumber;
//   List<SmsMessage> transactionMessages = [];
//   final Telephony telephony = Telephony.instance;

//   @override
//   void initState() {
//     super.initState();
//     _checkPermission();
//   }

//   Future<void> _checkPermission() async {
//     var status = await Permission.sms.status;

//     if (status.isGranted) {
//       setState(() => isPermissionGranted = true);
//       _fetchTransactionMessages(); // Fetch messages immediately
//     } else {
//       _requestPermission();
//     }
//   }

//   Future<void> _requestPermission() async {
//     var status = await Permission.sms.request();

//     if (status.isGranted) {
//       setState(() => isPermissionGranted = true);
//       _fetchTransactionMessages(); // Fetch messages after granting permission
//     } else {
//       _showPermissionDeniedDialog();
//     }
//   }

//   Future<void> _showPermissionDeniedDialog() async {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         title: Text("Permission Required"),
//         content: Text("This app needs SMS permission to read transaction messages."),
//         actions: [
//           TextButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               await _requestPermission();
//             },
//             child: Text("Grant Permission"),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text("Cancel"),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _fetchTransactionMessages() async {
//     List<SmsMessage> messages = await telephony.getInboxSms(
//       columns: [SmsColumn.BODY, SmsColumn.ADDRESS, SmsColumn.DATE],
//     );

//     List<SmsMessage> filteredMessages = messages.where((msg) {
//       return _isTransactionMessage(msg.body!);
//     }).toList();

//     if (filteredMessages.isNotEmpty) {
//       extractedAccountNumber = _extractAccountNumber(filteredMessages.first.body!);
//     }

//     setState(() {
//       transactionMessages = filteredMessages;
//     });

//     if (extractedAccountNumber != null) {
//       _showSelectionDialog();
//     }
//   }

//   bool _isTransactionMessage(String message) {
//     List<String> keywords = ["debited", "txn", "transaction", "UPI", "balance", "INR"];
//     return keywords.any((keyword) => message.toLowerCase().contains(keyword));
//   }

//   String? _extractAccountNumber(String message) {
//     RegExp regExp = RegExp(r'A\/C\s?[Xx]*?(\d{4})'); // Extracts last 4 digits
//     Match? match = regExp.firstMatch(message);
//     return match != null ? match.group(1) : null;
//   }

//   Future<void> _showSelectionDialog() async {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         title: Text("A/C No. $extractedAccountNumber"),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             _buildOptionTile("Account Number"),
//             _buildOptionTile("Credit Card"),
//             _buildOptionTile("Debit Card"),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildOptionTile(String option) {
//     return ListTile(
//       title: Text(option),
//       leading: Radio<String>(
//         value: option,
//         groupValue: selectedOption,
//         onChanged: (value) {
//           _saveSelection(value!);
//           Navigator.pop(context);
//         },
//       ),
//     );
//   }

//   Future<void> _saveSelection(String value) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString("selected_option", value);
//     setState(() {
//       selectedOption = value;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Home")),
//       body: isPermissionGranted
//           ? transactionMessages.isNotEmpty
//               ? ListView.builder(
//                   itemCount: transactionMessages.length,
//                   itemBuilder: (context, index) {
//                     return ListTile(
//                       title: Text(transactionMessages[index].body!),
//                       subtitle: Text(transactionMessages[index].address!),
//                     );
//                   },
//                 )
//               : Center(child: Text("No transaction messages found."))
//           : Center(child: CircularProgressIndicator()),
//     );
//   }
// }