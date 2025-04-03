import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../widgets/custom_text_field.dart';
import 'home_screen.dart';  

class SignupScreen extends StatelessWidget {
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
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Create"),
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


// import 'package:flutter/material.dart';
// import 'package:intl_phone_field/intl_phone_field.dart';
// import '../widgets/custom_text_field.dart';
// import 'home_screen.dart';  // Import home screen

// class SignupScreen extends StatelessWidget {
//   final TextEditingController phoneController = TextEditingController();
//   final TextEditingController fullNameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 24.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               "Create Account",
//               style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
//             ),
//             const SizedBox(height: 10),
//             const Text(
//               "Please enter valid information to access your account.",
//               style: TextStyle(color: Colors.grey),
//             ),
//             const SizedBox(height: 30),

//             // Country Code & Phone Number Input Field
//             IntlPhoneField(
//               controller: phoneController,
//               decoration: const InputDecoration(
//                 labelText: "Phone Number",
//                 border: OutlineInputBorder(
//                   borderSide: BorderSide(),
//                 ),
//               ),
//               initialCountryCode: 'IN', // Default country code (India)
//               onChanged: (phone) {
//                 print(phone.completeNumber); // Get full number with country code
//               },
//             ),

//             // Other Input Fields
//             CustomTextField(controller: fullNameController, labelText: "Full Name"),
//             CustomTextField(controller: emailController, labelText: "Email"),
//             CustomTextField(controller: passwordController, labelText: "Password", obscureText: true),

//             // Signup Button
//             ElevatedButton(
//               onPressed: () {
//                 // Navigate to HomeScreen after signup
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => HomeScreen()),
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue,
//                 minimumSize: const Size(double.infinity, 50),
//               ),
//               child: const Text("Create"),
//             ),

//             const SizedBox(height: 20),

//             // Login Navigation
//             Center(
//               child: GestureDetector(
//                 onTap: () {
//                   Navigator.pop(context);
//                 },
//                 child: const Text("Already have an account? Login", style: TextStyle(color: Colors.blue, fontSize: 16)),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
