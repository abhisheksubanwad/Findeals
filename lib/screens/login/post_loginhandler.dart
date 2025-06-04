import 'package:flutter/material.dart';
import '../home_screen.dart';
import '../confirm_product_screen.dart';
import '../../models/users_product.dart';
import '../../services/sms_service.dart';
import '../../services/setup_service.dart';
import 'package:hive/hive.dart';

class PostLoginHandler extends StatefulWidget {
  const PostLoginHandler({Key? key}) : super(key: key);

  @override
  State<PostLoginHandler> createState() => _PostLoginHandlerState();
}

class _PostLoginHandlerState extends State<PostLoginHandler> {
  bool _isProcessing = true;

  @override
  void initState() {
    super.initState();
    _handlePostLogin();
  }

  Future<void> _handlePostLogin() async {
    final userProductBox = Hive.box<UserProductModel>('user_products');
    final settingsBox = Hive.box('app_settings');

    // Fetch and parse SMS data
    SmsService smsService = SmsService();
    List<Map<String, String>> smsList = await smsService.fetchTransactionSms();

    if (smsList.isNotEmpty) {
      ProductParser parser = ProductParser();
      await parser.detectFinancialProducts(smsList);
    }

    // Mark setup as done
    settingsBox.put('isFirstOpen', false);

    
    await Future.delayed(const Duration(milliseconds: 100));

    bool hasUnconfirmed = userProductBox.values.any((p) => !p.isConfirmed);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            hasUnconfirmed ? ConfirmProductsScreen() : HomeScreen(),
      ),
    );

    setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
