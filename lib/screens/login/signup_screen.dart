import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../services/firebase_auth_service.dart';
import '../../widgets/custom_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'home_screen.dart';
import '../home_screen.dart';

class SignupScreen extends StatelessWidget {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Create Account", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 10),
            const Text("Please enter valid information to access your account.", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),

            IntlPhoneField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: "Phone Number",
                border: OutlineInputBorder(),
              ),
              initialCountryCode: 'IN', 
              onChanged: (phone) {
                print(phone.completeNumber);
              },
            ),

            CustomTextField(controller: fullNameController, labelText: "Full Name"),
            CustomTextField(controller: emailController, labelText: "Email"),
            CustomTextField(controller: passwordController, labelText: "Password", obscureText: true),

            ElevatedButton(
              onPressed: () async {
                String email = emailController.text.trim();
                String password = passwordController.text.trim();

                var user = await _authService.signUpWithEmail(email, password);

                if (user != null) {
                  // ✅ Store login status
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.setBool('isLoggedIn', true);

                  // ✅ Navigate to Home Screen
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                } else {
                  // ❌ Show Error Message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Signup Failed. Try again!"))
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Create"),
            ),

            const SizedBox(height: 20),

            // Google Sign-Up Button
            ElevatedButton.icon(
              onPressed: () async {
                var user = await _authService.signInWithGoogle();
                if (user != null) {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.setBool('isLoggedIn', true);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                }
              },
              icon: const Icon(Icons.login, color: Colors.white),
              label: const Text("Sign Up with Google"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),

            const SizedBox(height: 20),

            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Text("Already have an account? Login", style: TextStyle(color: Colors.blue, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
