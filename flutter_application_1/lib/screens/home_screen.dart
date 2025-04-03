import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telephony/telephony.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isPermissionGranted = false;
  List<String> accountNumbers = [];
  List<Map<String, dynamic>> transactions = [];
  final Telephony telephony = Telephony.instance;
  int currentIndex = 0;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    var status = await Permission.sms.status;
    if (status.isGranted) {
      setState(() => isPermissionGranted = true);
      _fetchTransactionMessages();
    } else {
      _requestPermission();
    }
  }

  Future<void> _requestPermission() async {
    var status = await Permission.sms.request();
    if (status.isGranted) {
      setState(() => isPermissionGranted = true);
      _fetchTransactionMessages();
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

    Set<String> extractedNumbers = {};
    List<Map<String, dynamic>> extractedTransactions = [];

    for (var msg in filteredMessages) {
      String? accNo = _extractAccountNumber(msg.body!);
      if (accNo != null) extractedNumbers.add(accNo);

      var transaction = _extractTransactionDetails(msg.body!, msg.date!);
      if (transaction != null) extractedTransactions.add(transaction);
    }

    setState(() {
      transactions = extractedTransactions;
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
    RegExp regExp = RegExp(r'A\/C\s?[Xx]*?(\d{4})');
    Match? match = regExp.firstMatch(message);
    return match?.group(1);
  }

  Map<String, dynamic>? _extractTransactionDetails(String message, int timestamp) {
    RegExp amountRegExp = RegExp(r'debited by\s?([\d,]+\.\d{2})');
    RegExp receiverRegExp = RegExp(r'trf to\s?([a-zA-Z\s]+)');

    String? accNo = _extractAccountNumber(message);
    String? amount = amountRegExp.firstMatch(message)?.group(1);
    String? recipient = receiverRegExp.firstMatch(message)?.group(1);

    if (accNo != null && amount != null && recipient != null) {
      String date = DateFormat('dd MMM yyyy').format(DateTime.fromMillisecondsSinceEpoch(timestamp));
      return {"accountNo": accNo, "amount": amount, "date": date, "recipient": recipient};
    }
    return null;
  }

  Future<void> _showSelectionDialog(int index) async {
    if (index >= accountNumbers.length) return;

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

  void _selectDate(DateTime date) {
    setState(() {
      selectedDate = date;
    });
  }

  Widget _buildTransactionList() {
    String formattedDate = DateFormat('dd MMM yyyy').format(selectedDate);
    List<Map<String, dynamic>> filteredTransactions =
        transactions.where((tx) => tx["date"] == formattedDate).toList();

    return filteredTransactions.isNotEmpty
        ? ListView.builder(
            itemCount: filteredTransactions.length,
            itemBuilder: (context, index) {
              var transaction = filteredTransactions[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                elevation: 2,
                child: ListTile(
                  leading: Icon(Icons.account_balance_wallet, color: Colors.blue),
                  title: Text("A/C No. ${transaction["accountNo"]}"),
                  subtitle: Text("To: ${transaction["recipient"]}"),
                  trailing: Text(
                    "₹${transaction["amount"]}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ),
              );
            },
          )
        : Center(child: Text("No transactions found for this date."));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Transactions"),
        actions: [IconButton(icon: Icon(Icons.search), onPressed: () {})],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(icon: Icon(Icons.arrow_left), onPressed: () => _selectDate(selectedDate.subtract(Duration(days: 1)))),
                Text(DateFormat('d MMM yyyy').format(selectedDate), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(icon: Icon(Icons.arrow_right), onPressed: () => _selectDate(selectedDate.add(Duration(days: 1)))),
                IconButton(icon: Icon(Icons.calendar_today), onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) _selectDate(pickedDate);
                }),
              ],
            ),
          ),
        ),
      ),
      body: isPermissionGranted ? _buildTransactionList() : Center(child: CircularProgressIndicator()),
    );
  }
}