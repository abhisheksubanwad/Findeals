import 'package:hive/hive.dart';

part 'users_product.g.dart';

@HiveType(typeId: 1)
class UserProductModel extends HiveObject {
  @HiveField(0)
  String bankName; // Example: "HDFC "

  @HiveField(1)
  String? productType; // Example: "Credit Card", "Debit Card", "Loan", can be null initially

  @HiveField(2)
  String productId; // Example: "1234"

  @HiveField(3)
  bool isConfirmed; // User confirms product type

  UserProductModel({
    required this.bankName,
    this.productType, // Initially null
    required this.productId,
    this.isConfirmed = false, // Default false, user needs to confirm
  });
}

class ProductParser {
  final Box<UserProductModel> userProductBox = Hive.box<UserProductModel>('user_products');

  Future<void> detectFinancialProducts(List<Map<String, String>> smsList) async{
    for (var sms in smsList) {
      String body = sms['body']?.toLowerCase() ?? "";

      String? bank = extractBank(body);
      String? lastFourDigits = extractCardLastDigits(body);

      if (bank != null && lastFourDigits != null) {
        String bankName = "$bank";

        // Check if already exists
        bool exists = userProductBox.values.any((p) => p.bankName == bank && p.productId==lastFourDigits);

        if (!exists) {
          userProductBox.add(UserProductModel(
            bankName: bank,
            productId: lastFourDigits,
            isConfirmed: false, // User confirmation needed
           
          ));
           print(" ✅ Product added bank: $bank productId: $lastFourDigits  is confirmed: false ");
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


  /// This method should be called when the user confirms the product type
  void confirmProductType(int index, String selectedType) {
    var product = userProductBox.getAt(index);
    if (product != null) {
      product.productType = selectedType;
      product.isConfirmed = true;
      product.save();
    }
  }
}

