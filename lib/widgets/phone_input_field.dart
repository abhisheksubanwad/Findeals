import 'package:flutter/material.dart';

class PhoneInputField extends StatelessWidget {
  final TextEditingController controller;

  PhoneInputField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: "Enter Phone",
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.flag), // You can replace this with a country picker package
      ),
    );
  }
}
