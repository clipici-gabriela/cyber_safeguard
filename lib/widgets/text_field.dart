import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String keybordType;
  final bool obscureText;

  const CustomTextField(
      {super.key,
      required this.controller,
      required this.hintText,
      required this.obscureText,
      required this.keybordType});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: TextField(
        controller: controller,
        autocorrect: false,
        keyboardType: keybordType == 'number'
            ? TextInputType.number
            : keybordType == 'email'
                ? TextInputType.emailAddress
                : TextInputType.text,
        obscureText: obscureText,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue.shade200),
            ),
            fillColor: const Color.fromARGB(255, 192, 227, 255),
            filled: true,
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.blueGrey)),
      ),
    );
  }
}
