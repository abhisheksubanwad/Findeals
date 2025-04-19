import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

import 'models/users_product.dart';
import 'models/transaction_data.dart';
import 'providers/transaction_provider.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import './home_screen/home_screen.dart';
import './home_screen/confirm_product_screen.dart';
import 'services/sms_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();

  Hive.registerAdapter(UserProductModelAdapter());
  Hive.registerAdapter(TransactionModelAdapter());

  await Hive.openBox<UserProductModel>('user_products');
  await Hive.openBox('app_settings');
  await Hive.openBox<TransactionModel>('transactions');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Transaction App',
        theme: ThemeData.dark(),
        home: SplashScreen(),
      ),
    );
  }
}

// ---------------- SplashScreen ----------------
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  void _navigateTo(Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  Future<void> _initializeApp() async {
    final settingsBox = Hive.box('app_settings');
    final userProductBox = Hive.box<UserProductModel>('user_products');

    bool isFirstOpen = settingsBox.get('isFirstOpen', defaultValue: true);
    bool hasProducts = userProductBox.isNotEmpty;

    await Future.delayed(const Duration(seconds: 2));

    if (isFirstOpen || !hasProducts) {
      bool success = await _processFirstTimeSetup();

      if (success) {
        settingsBox.put('isFirstOpen', false);
        bool hasUnconfirmed = userProductBox.values.any((p) => !p.isConfirmed);
        if (hasUnconfirmed) {
          _navigateTo(ConfirmProductsScreen());
        } else {
          _navigateTo(AuthCheck());
        }
      } else {
        print("❌ First time setup failed.");
        _navigateTo(AuthCheck());
      }
    } else {
      _navigateTo(AuthCheck());
    }
  }

  Future<bool> _processFirstTimeSetup() async {
    SmsService smsService = SmsService();
    List<Map<String, String>> smsList = await smsService.fetchTransactionSms();

    if (smsList.isEmpty) {
      print("❌ No SMS found.");
      return false;
    }

    try {
      ProductParser parser = ProductParser();
      await parser.detectFinancialProducts(smsList);
      return true;
    } catch (e) {
      print("Error parsing products: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("Loading app...", style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

// ---------------- AuthCheck ----------------
class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => isLoggedIn ? HomeScreen() : LoginScreen(),
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : const SizedBox.shrink(),
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'screens/login_screen.dart';
// import './screens/home_screen.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:get/get.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Auth UI',
//       theme: ThemeData.dark(),
//       home: const AuthCheck(),
//     );
//   }
// }

// class AuthCheck extends StatefulWidget {
//   const AuthCheck({super.key});

//   @override
//   _AuthCheckState createState() => _AuthCheckState();
// }

// class _AuthCheckState extends State<AuthCheck> {
//   bool _isLoading = true; // Show loading while checking auth

//   @override
//   void initState() {
//     super.initState();
//     _checkLogin();
//   }

//   Future<void> _checkLogin() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

//     await Future.delayed(const Duration(seconds: 2)); // Simulate loading time

//     if (mounted) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => isLoggedIn ? HomeScreen() : LoginScreen(),
//         ),
//       );
//     }

//     setState(() {
//       _isLoading = false; // Hide loading indicator
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Center(
//         child: _isLoading
//             ? const CircularProgressIndicator() // Show spinner while checking login
//             : const SizedBox.shrink(),
//       ),
//     );
//   }
// }