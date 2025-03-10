import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'home_screen.dart';  // Import home screen
import '../widgets/custom_text_field.dart';
import '../widgets/social_login_button.dart';

class LoginScreen extends StatelessWidget {
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
            const Text(
              "Welcome Back!",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            const Text(
              "Enter your email and password to get access to your account.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // Email & Password Fields
            CustomTextField(controller: emailController, labelText: "Email"),
            CustomTextField(controller: passwordController, labelText: "Password", obscureText: true),

            // Forgot Password & Login Button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {}, 
                child: const Text("Forgot?", style: TextStyle(color: Colors.blue))
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to HomeScreen after login
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Login"),
            ),

            const SizedBox(height: 20),

            // Social Login Buttons
            SocialLoginButton(icon: Icons.facebook, text: "Login with Facebook", onPressed: () {}),
            SocialLoginButton(icon: Icons.g_mobiledata, text: "Login with Google", onPressed: () {}),
            SocialLoginButton(icon: Icons.email, text: "Login with Gmail", onPressed: () {}),

            const SizedBox(height: 20),

            // Signup Navigation
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SignupScreen()));
                },
                child: const Text("Create account", style: TextStyle(color: Colors.blue, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
