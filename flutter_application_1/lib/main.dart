// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'screens/login_screen.dart';
// import 'home_screen/home_screen.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:get/get.dart';


// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:provider/provider.dart';
// import 'models/users_product.dart';
// import 'providers/transaction_provider.dart';
// import 'home_screen/confirm_product_screen.dart';
// import 'services/sms_service.dart';
// import 'models/transaction_data.dart';


// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Hive.initFlutter();

//   Hive.registerAdapter(UserProductModelAdapter());
//   Hive.registerAdapter(TransactionModelAdapter());

//   await Hive.openBox<UserProductModel>('user_products');
//   await Hive.openBox('app_settings');
//   await Hive.openBox<TransactionModel>('transactions');

//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (context) => TransactionProvider()),
//       ],
//       child: MaterialApp(
//         debugShowCheckedModeBanner: false,
//         title: 'Transaction Analytics',
//         theme: ThemeData(primarySwatch: Colors.blue),
//         home: SplashScreen(),
//       ),
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

// Future<void> _checkLogin() async {
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

// class SplashScreen extends StatefulWidget {
//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _initializeApp();
//   }

//   void _navigateTo(Widget screen) {
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => screen),
//     );
//   }

//   Future<void> _initializeApp() async {
//     var settingsBox = Hive.box('app_settings');
//     var userProductBox = Hive.box<UserProductModel>('user_products');

//     bool isFirstOpen = settingsBox.get('isFirstOpen', defaultValue: true);
//     bool hasProducts = userProductBox.isNotEmpty;
//     bool hasUnconfirmedProducts = userProductBox.values.any((p) => !p.isConfirmed);

//     print("DEBUG: isFirstOpen: $isFirstOpen");
//     print("DEBUG: hasProducts: $hasProducts");
//     print("DEBUG: hasUnconfirmedProducts: $hasUnconfirmedProducts");

//     await Future.delayed(Duration(seconds: 2)); // Simulate loading

//     if (isFirstOpen || !hasProducts) {
//       print("DEBUG: Running first-time setup...");
//       bool success = await _processFirstTimeSetup();

//       if (success) {
//         print("✅ detectFinancialProducts() completed successfully.");
//         settingsBox.put('isFirstOpen', false);
        
//         // ✅ Check if unconfirmed products exist before navigating
//         bool hasUnconfirmed = userProductBox.values.any((p) => !p.isConfirmed);
//         if (hasUnconfirmed) {
//           _navigateTo(ConfirmProductsScreen());
//         } else {
//           _navigateTo(HomeScreen());
//         }
//       } else {
//         print("❌ Error in detectFinancialProducts(). Staying on SplashScreen.");
//       }
//     } else {
//       print("DEBUG: Navigating to HomeScreen...");
//       _navigateTo(HomeScreen());
//     }
//   }

//   Future<bool> _processFirstTimeSetup() async {
//     print("DEBUG: Fetching transaction SMS...");
//     SmsService smsService = SmsService();
//     List<Map<String, String>> smsList = await smsService.fetchTransactionSms();

//     if (smsList.isEmpty) {
//       print("❌ No SMS found. Cannot detect financial products.");
//       return false; // ⛔ Stop if no SMS data
//     }

//     print("DEBUG: Running detectFinancialProducts()...");
//     ProductParser parser = ProductParser();
    
//     try {
//       await parser.detectFinancialProducts(smsList);
//       print("✅ detectFinancialProducts() completed.");
//       return true; // ✅ Success
//     } catch (e) {
//       print("❌ Error in detectFinancialProducts(): $e");
//       return false; // ⛔ Failure
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(), // ⏳ Show loading spinner
//             SizedBox(height: 20),
//             Text("Loading app...", style: TextStyle(fontSize: 16)),
//           ],
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import './screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Auth UI',
      theme: ThemeData.dark(),
      home: const AuthCheck(),
    );
  }
}

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  _AuthCheckState createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  bool _isLoading = true; // Show loading while checking auth

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    await Future.delayed(const Duration(seconds: 2)); // Simulate loading time

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => isLoggedIn ? HomeScreen() : LoginScreen(),
        ),
      );
    }

    setState(() {
      _isLoading = false; // Hide loading indicator
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator() // Show spinner while checking login
            : const SizedBox.shrink(),
      ),
    );
  }
}