import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import '../models/users_product.dart';
import '../providers/transaction_provider.dart';
import '../screens/home_screen.dart';

class ConfirmProductsScreen extends StatefulWidget {
  @override
  _ConfirmProductsScreenState createState() => _ConfirmProductsScreenState();
}

class _ConfirmProductsScreenState extends State<ConfirmProductsScreen> {
  final Box<UserProductModel> userProductBox = Hive.box<UserProductModel>('user_products');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _askUserForProductType();
    });
  }

  void _askUserForProductType() async {
    List<UserProductModel> unclassifiedProducts = userProductBox.values
        .where((p) => p.productType == null)
        .toList();
    

    for (var product in unclassifiedProducts) {
      String? selectedType = await _showTypeSelectionDialog(product.bankName, product.productId);

      if (selectedType != null) {
        // ✅ Directly modify the object and save it
        product.productType = selectedType;
        product.isConfirmed = true;

        await product.save(); // ✅ Save changes in Hive
      }

      print("""
      🔹 Bank: ${product.bankName}
      🔹 Product ID: ${product.productId}
      🔹 Type: ${product.productType}
      🔹 Confirmed: ${product.isConfirmed}
      ----------------------
      """);
    }

   await  _loadTransactionsAndGoHome();
  }

  Future<void> _loadTransactionsAndGoHome() async {
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);

    await transactionProvider.loadTransactions(); // ✅ Wait for transactions to load

    // ✅ Navigate to HomeScreen after transactions load
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  Future<String?> _showTypeSelectionDialog(String bankName, String? accountOrCardNumber) async {
    String maskedAccount = _maskAccountNumber(accountOrCardNumber);

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String? selectedType;
        return AlertDialog(
          title: Text("Confirm Product Type"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Bank: $bankName\nAccount: $maskedAccount\nSelect Product Type:"),
              SizedBox(height: 10),
              StatefulBuilder(
                builder: (context, setDialogState) {
                  return DropdownButton<String>(
                    isExpanded: true,
                    value: selectedType,
                    hint: Text("Select Type"),
                    items: ["Credit Card", "Debit Card", "Loan", "UPI"].map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedType = value;
                      });
                    },
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, selectedType),
              child: Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  String _maskAccountNumber(String? accountNumber) {
    if (accountNumber == null || accountNumber.isEmpty) return "Unknown";

    int visibleDigits = accountNumber.length >= 4 ? 4 : accountNumber.length;
    String maskedPart = "X" * (accountNumber.length - visibleDigits);
    String visiblePart = accountNumber.substring(accountNumber.length - visibleDigits);

    return "$maskedPart$visiblePart";
  }

  @override
  Widget build(BuildContext context) {
    List<UserProductModel> products = userProductBox.values.toList();

    return Scaffold(
      appBar: AppBar(title: Text("Confirm Financial Products")),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 4,
            margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: ListTile(
              contentPadding: EdgeInsets.all(15),
              title: Text(
                "${product.bankName}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "Account: ${_maskAccountNumber(product.productId)}\nType: ${product.productType ?? '❌ Not Set'}",
                style: TextStyle(fontSize: 15, color: Colors.grey[700]),
              ),
              trailing: Icon(Icons.credit_card, color: Colors.blueAccent),
            ),
          );
        },
      ),
    );
  }
}
