import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';

import 'providers/transaction_provider.dart';
import 'models/users_product.dart';
import 'models/transaction_data.dart';
import 'services/setup_service.dart';
import 'screens/login/auth_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await dotenv.load();
  await Firebase.initializeApp();

  Hive.registerAdapter(UserProductModelAdapter());
  Hive.registerAdapter(TransactionModelAdapter());

  await Hive.openBox<UserProductModel>('user_products');
  await Hive.openBox('app_settings');
  await Hive.openBox<TransactionModel>('transactions');

  setupBackgroundTasks();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Transaction Analytics',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: AuthCheck(),
      ),
    );
  }
}
