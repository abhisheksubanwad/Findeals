import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/users_product.dart';
import './db_helper.dart';

part 'transaction_data.g.dart';

@HiveType(typeId: 2)
class TransactionModel extends HiveObject {
  @HiveField(0)
  String bankName;

  @HiveField(1)
  String productId;

  @HiveField(2)
  double amount;

  @HiveField(3)
  String merchant;

  @HiveField(4)
  DateTime timestamp;

  @HiveField(5)
  String productType;

   @HiveField(6)
  String transactionType;

  @HiveField(7)
  String merchantName;

  TransactionModel({
    required this.bankName,
    required this.productId,
    required this.amount,
    required this.merchant,
    required this.timestamp,
    required this.productType,
    required this.transactionType,
    required this.merchantName
  });
}

class TransactionParser {
  final Box<UserProductModel> userProductBox = Hive.box<UserProductModel>('user_products');
  final Box<TransactionModel> transactionBox = Hive.box<TransactionModel>('transactions');
  final DatabaseHelper _dbHelper = DatabaseHelper(); 

  void processTransactions(List<Map<String, String>> smsList) {
    for (var sms in smsList) {
      String body = sms['body']?.toLowerCase() ?? "";

      String? bank = extractBank(body);
      String? lastFourDigits = extractCardLastDigits(body);
      double? amount = extractAmount(body);
      String? merchant = extractMerchant(body);
      String? action = extractAction(body,bank,lastFourDigits);
      print("✅ Extraction Function bankName:$bank amount:$amount  productId:$lastFourDigits transactionType:$action  merchant:$merchant");

      if (bank != null && lastFourDigits != null && amount != null) {
        var product = userProductBox.values.firstWhere(
          (p) => p.bankName == bank && p.productId == lastFourDigits && p.isConfirmed,
          orElse: () => UserProductModel(bankName: '', productId: '', isConfirmed: false),
        );

        if (product.bankName.isNotEmpty) {
         final newTransaction = TransactionModel(
            bankName: bank,
            productId: lastFourDigits,
            amount: amount,
            merchant: merchant ?? "Unknown",
            timestamp: DateTime.fromMillisecondsSinceEpoch(int.tryParse(sms['date'] ?? '0') ?? 0),
            productType: product.productType ?? "Unknown",
            transactionType: action ?? 'Unknown',
            merchantName: merchant ?? 'Unknown'
          );

           transactionBox.add(newTransaction);
           print('✅ Txn detected bankName:$bank amount:$amount productType:${product.productType} productId:$lastFourDigits transactionType:$action ');

           _dbHelper.insertTransaction(newTransaction);
           print('transaction added to tranlog');
        }
      }
    }
  
  }

  String? extractCardLastDigits(String sms) {
    RegExp regex = RegExp(r'\b(?:xx(\d{3,4})|ending in (\d{3,4})|(?:card|acc|xxxx)[ -]?(\d{3,4}))\b');
;
    Match? match = regex.firstMatch(sms);
    return match?.group(1) ?? match?.group(2);
  }

 double? extractAmount(String sms) {
  RegExp regex = RegExp(
      r'(?:rs\.?|inr|₹|rupees?)\s?(\d{1,3}(?:[,]\d{2,3})*(?:\.\d{1,2})?)',
      caseSensitive: false);
  Match? match = regex.firstMatch(sms);

  if (match != null) {
    String amountStr = match.group(1)!.replaceAll(',', ''); // Normalize number
    return double.tryParse(amountStr);
  }
  return null;
}

 String? extractMerchant(String sms) {
  List<RegExp> patterns = [
    RegExp(r'at\s+([a-zA-Z0-9 &.-]+?)(?=[.,;]|\s+for|\s+due|\s+because|\s+with|\s+in|\s+on|\s+at|$)', caseSensitive: false),
    RegExp(r'by\s+([a-zA-Z0-9 &.-]+?)(?=[.,;]|\s+for|\s+due|\s+because|\s+with|\s+in|\s+on|\s+at|$)', caseSensitive: false),
    RegExp(r'([a-zA-Z0-9 &.-]+?)\s+credited', caseSensitive: false),
    RegExp(r'from\s+([a-zA-Z0-9 &.-]+?)(?=[.,;]|\s+for|\s+due|\s+because|\s+with|\s+in|\s+on|\s+at|$)', caseSensitive: false),
    RegExp(r'to\s+([a-zA-Z0-9 &.-]+?)(?=[.,;]|\s+for|\s+due|\s+because|\s+with|\s+in|\s+on|\s+at|$)', caseSensitive: false),
    RegExp(r'via\s+([a-zA-Z0-9 &.-]+?)(?=[.,;]|\s+for|\s+due|\s+because|\s+with|\s+in|\s+on|\s+at|$)', caseSensitive: false),
    RegExp(r'on\s+([a-zA-Z0-9 &.-]+?)(?=[.,;]|\s+for|\s+due|\s+because|\s+with|\s+in|\s+on|\s+at|$)', caseSensitive: false),
    RegExp(r'towards\s+([a-zA-Z0-9 &.-]+?)(?=[.,;]|\s+for|\s+due|\s+because|\s+with|\s+in|\s+on|\s+at|$)', caseSensitive: false),
    RegExp(r'UPI Transaction to\s+([a-zA-Z0-9 &.-]+?)(?=[.,;]|\s+for|\s+due|\s+because|\s+with|\s+in|\s+on|\s+at|$)', caseSensitive: false),
    RegExp(r'Payment to\s+([a-zA-Z0-9 &.-]+?)(?=[.,;]|\s+for|\s+due|\s+because|\s+with|\s+in|\s+on|\s+at|$)', caseSensitive: false),
    RegExp(r'POS\s+([a-zA-Z0-9 &.-]+?)(?=[.,;]|\s+for|\s+due|\s+because|\s+with|\s+in|\s+on|\s+at|$)', caseSensitive: false),
    RegExp(r'Merchant:\s*([a-zA-Z0-9 &.-]+?)(?=[.,;]|\s+for|\s+due|\s+because|\s+with|\s+in|\s+on|\s+at|$)', caseSensitive: false),
   
  ];

  List<String> possibleMerchants = [];

  for (var regex in patterns) {
    Match? match = regex.firstMatch(sms);
    if (match != null) {
      String merchant = match.group(1)?.trim() ?? "";
      possibleMerchants.add(merchant);
    }
  }

  return possibleMerchants.isNotEmpty ? possibleMerchants.first : null;
}




 String? extractBank(String sms) {
  Map<String, List<String>> bankAliases = {
    "HDFC": ["HDFC", "HDFCBK", "HDFC Bank"],
    "ICICI": ["ICICI", "ICICIBANK", "ICICI Bank"],
    "SBI": ["SBI", "SBIINB", "State Bank of India"],
    "AXIS": ["AXIS", "AXISBANK", "AXIS Bank"],
    "KOTAK": ["KOTAK", "KOTAKBANK", "KOTAK Mahindra"],
    "BOB": ["BOB", "BANK OF BARODA"],
    "IDFC": ["IDFC", "IDFCFIRST", "IDFC First Bank"],
    "RBL": ["RBL", "RBLBANK", "RBL Bank"],
    "INDUSIND": ["INDUSIND", "INDUSIND Bank"],
    "YES": ["YES", "YESBANK", "YES Bank"],
    "ONECARD": ["ONECARD"],
    "SLICE": ["SLICE"],
    "AU": ["AU", "AU Small Finance Bank"],
    "FEDERAL": ["FEDERAL", "FEDERALBANK"],
    "CANARA": ["CANARA", "CANARA BANK"],
    "PNB": ["PNB", "Punjab National Bank"],
    "UNION": ["UNION", "Union Bank"],
    "BANDHAN": ["BANDHAN", "Bandhan Bank"],
    "SCB": ["SCB", "Standard Chartered"],
    "HSBC": ["HSBC"],
    "CITI": ["CITI", "CITIBANK"],
    "DBS": ["DBS", "DBS Bank"],
    "JUPITER": ["JUPITER"],
    "FI": ["FI"],
    "NAVI": ["NAVI"],
    "PAYTM": ["PAYTM", "PAYTMBANK"],
    "AMAZON": ["AMAZON", "AMAZONPAY"],
    "PHONEPE": ["PHONEPE"],
    "FREECHARGE": ["FREECHARGE"],
    "MOBIKWIK": ["MOBIKWIK"]
  };

  // Convert SMS to lowercase for case-insensitive matching
  String cleanSms = sms.toLowerCase();

  for (var entry in bankAliases.entries) {
    for (var alias in entry.value) {
      String cleanAlias = alias.toLowerCase();

      // New regex pattern: Match if preceded by a space, start of string, or special character
     String regexPattern = r'(^|[\s\W])' + RegExp.escape(cleanAlias) + r'($|[\s\W])';

      
      if (RegExp(regexPattern, caseSensitive: false).hasMatch(cleanSms)) {
        return entry.key;
      }
    }
  }

  return "Unknown Bank";
}


  
  String? extractAction(String sms, String? bank, String? lastFourDigits) {
  if (sms.isEmpty) return null;

  if (bank != null && lastFourDigits != null) {
    var product = userProductBox.values.firstWhere(
      (p) => p.bankName == bank && p.productId == lastFourDigits && p.isConfirmed,
      orElse: () => UserProductModel(bankName: '', productId: '', isConfirmed: false, productType: ''),
    );

    if (product.bankName.isNotEmpty && product.productType == "Credit Card") {
      return "Debited"; // Default to Debited for Credit Cards if no explicit action is found
    }
  }

  String lowerSms = sms.toLowerCase();

  // Regex for detecting credited and debited transactions
  RegExp debitedRegex = RegExp(r'\b(debited|withdrawn|deducted|spent)\b', caseSensitive: false);
  RegExp creditedRegex = RegExp(r'\b(credited|received|added)\b', caseSensitive: false);

  // Find positions in SMS
  Match? debitedMatch = debitedRegex.firstMatch(lowerSms);
  Match? creditedMatch = creditedRegex.firstMatch(lowerSms);

  // Prioritize "Debited" if both are found
  if (debitedMatch != null && creditedMatch != null) {
    return debitedMatch.start < creditedMatch.start ? "Debited" : "Credited";
  }

  // If only "Debited" is found
  if (debitedMatch != null) return "Debited";

  // If only "Credited" is found
  if (creditedMatch != null) return "Credited";

  // Check user-confirmed product type for Credit Cards

  return "Unknown"; // No clear action found
}


}
