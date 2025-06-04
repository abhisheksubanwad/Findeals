import 'package:flutter/services.dart';

class SmsService {
  static const platform = MethodChannel('com.example.sms_reader_app/sms');

  Future<List<Map<String, String>>> fetchTransactionSms() async {
    try {
      final result = await platform.invokeMethod('getTxnSms');
      print("Dart: Raw SMS Data Received: $result");  // ✅ Debug log

      if (result != null && result is List) {
        final smsList = result.map((item) => Map<String, String>.from(item)).toList();
        print("Dart: Parsed Transaction SMS: $smsList");  // ✅ Check parsed data
        return smsList;
      }
    } on PlatformException catch (e) {
      print("Dart: Failed to get SMS messages: '${e.message}'");  // ✅ Error log
    }
    return [];
  }
  
}
