// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cyber_safeguard/widgets/custom_button.dart';
import 'package:cyber_safeguard/widgets/text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:usage_stats/usage_stats.dart';

class RegisterScreen extends StatefulWidget {
  final Function()? onTap;
  const RegisterScreen({super.key, required this.onTap});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final numberController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final ageController = TextEditingController();

  bool? isParentChecked = false;
  bool? isChildChecked = false;

  Future<void> saveFCMToken(String userId) async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await FirebaseFirestore.instance.collection('Users').doc(userId).update({
        'fcmToken': token,
      });
    }
  }

  void signUserUp() async {
    try {
      if (emailController.text.isEmpty ||
          passwordController.text.isEmpty ||
          confirmPasswordController.text.isEmpty ||
          numberController.text.isEmpty ||
          firstNameController.text.isEmpty ||
          lastNameController.text.isEmpty ||
          (isChildChecked == true && ageController.text.isEmpty)) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All fields are required'),
          ),
        );
        return;
      }

      if (!EmailValidator.validate(emailController.text)) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid email address'),
          ),
        );
        return;
      }

      if (passwordController.text.length < 8) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password must be longer than 8 characters'),
          ),
        );
        return;
      }

      if (passwordController.text == confirmPasswordController.text) {
        if (isParentChecked == true) {
          final userCredentials =
              await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text,
          );
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(userCredentials.user!.uid)
              .set({
            'firstName': firstNameController.text,
            'lastName': lastNameController.text,
            'email': emailController.text,
            'phoneNumber': numberController.text,
            'userType': 'parent'
          });
        } else if (isChildChecked == true) {
          final userCredentials =
              await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text,
          );
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(userCredentials.user!.uid)
              .set({
            'firstName': firstNameController.text,
            'lastName': lastNameController.text,
            'email': emailController.text,
            'phoneNumber': numberController.text,
            'age': ageController.text,
            'userType': 'child'
          });

          saveFCMToken(FirebaseAuth.instance.currentUser!.uid);
          UsageStats.grantUsagePermission();
          FlutterBackgroundService().invoke('setAsBackground');
        } else {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select one of the options'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password does not match'),
          ),
        );
      }
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'An error occurred'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock_outline,
                  size: 100,
                  color: Colors.blue,
                ),
                const SizedBox(height: 50),
                const Text(
                  'Welcome to Cyber Safeguard',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: firstNameController,
                  hintText: 'First Name',
                  keybordType: 'text',
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: lastNameController,
                  hintText: 'Last Name',
                  keybordType: 'text',
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: emailController,
                  hintText: 'Email',
                  keybordType: 'email',
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  keybordType: 'password',
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  keybordType: 'password',
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: numberController,
                  hintText: 'Phone Number',
                  keybordType: 'number',
                  obscureText: false,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: isParentChecked,
                      onChanged: (bool? value) {
                        setState(() {
                          isParentChecked = value;
                          isChildChecked = false;
                        });
                      },
                    ),
                    const Text('Sign up as a parent'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: isChildChecked,
                      onChanged: (bool? value) {
                        setState(() {
                          isChildChecked = value;
                          isParentChecked = false;
                        });
                      },
                    ),
                    const Text('Sign up as a child'),
                  ],
                ),
                if (isChildChecked == true) ...[
                  const SizedBox(height: 10),
                  const Text(
                    'The child should not be older than 18',
                    style: TextStyle(color: Colors.red),
                  ),
                  CustomTextField(
                    controller: ageController,
                    hintText: 'Age',
                    keybordType: 'number',
                    obscureText: false,
                  ),
                ],
                const SizedBox(height: 20),
                CustomButton(
                  text: 'Sign Up',
                  onTap: signUserUp,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        'Login now',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
