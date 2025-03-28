import 'package:flutter/services.dart';

class SmsService {
  static const platform = MethodChannel('sms_reader');

  Future<List<Map<String, dynamic>>> fetchTransactionSms() async {
    try {
      final List<dynamic> transactions = await platform.invokeMethod('getTransactionSms');
      return transactions.map((transaction) => Map<String, dynamic>.from(transaction)).toList();
    } catch (e) {
      print("Error fetching SMS: $e");
      return [];
    }
  }
}
