import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_auth_service.dart';
import 'home_screen.dart';

class OTPVerificationScreen extends StatelessWidget {
  final String verificationId;
  final TextEditingController otpController = TextEditingController();

  OTPVerificationScreen({required this.verificationId});

  final FirebaseAuthService _authService = FirebaseAuthService();

  void _verifyOTP(BuildContext context) async {
    User? user = await _authService.verifyOTP(verificationId, otpController.text);
    if (user != null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          TextField(controller: otpController, decoration: const InputDecoration(labelText: "Enter OTP")),
          ElevatedButton(onPressed: () => _verifyOTP(context), child: const Text("Verify OTP")),
        ],
      ),
    );
  }
}
