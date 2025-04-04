import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'home_screen.dart';
import 'forgot_password.dart'; 
import '../services/firebase_auth_service.dart';
import '../widgets/custom_text.dart';
import '../widgets/social_login_button.dart';

class LoginScreen extends StatelessWidget {
  final FirebaseAuthService _authService = FirebaseAuthService();
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
            const Text("Welcome Back!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 10),
            const Text("Enter your email and password to access your account.", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),

            CustomTextField(controller: emailController, labelText: "Email"),
            CustomTextField(controller: passwordController, labelText: "Password", obscureText: true),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => ForgotPasswordScreen())
                  );
                },
                child: const Text("Forgot Password?", style: TextStyle(color: Colors.blue)),
              ),
            ),
            
            ElevatedButton(
              onPressed: () async {
                String email = emailController.text.trim();
                String password = passwordController.text.trim();

                var user = await _authService.signInWithEmail(email, password);

                if (user != null) {
                  // User exists -> Login successful
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                } else {
                  // User does not exist -> Prompt to sign up
                  _showSignupDialog(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Login"),
            ),

            const SizedBox(height: 20),

            SocialLoginButton(
              icon: Icons.g_mobiledata, 
              text: "Login with Google", 
              onPressed: () async {
                var user = await _authService.signInWithGoogle();
                if (user != null) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                }
              }
            ),

            const SizedBox(height: 20),

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

  // Function to show sign-up prompt if user doesn't exist
  void _showSignupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Account Not Found"),
        content: const Text("It looks like you don't have an account. Would you like to create one?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => SignupScreen()));
            },
            child: const Text("Create Account"),
          ),
        ],
      ),
    );
  }
}
