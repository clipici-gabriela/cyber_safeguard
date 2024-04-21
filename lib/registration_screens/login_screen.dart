// ignore_for_file: use_build_context_synchronously

import 'package:cyber_safeguard/widgets/custom_button.dart';
import 'package:cyber_safeguard/widgets/text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  final Function()? onTap;
  const LoginScreen({super.key, required this.onTap});

  @override
  State<LoginScreen> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginScreen> {
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  //sign user in
  void signUserIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
    } on FirebaseAuthException catch (error) {
      if (error.code == 'user-not-found') {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message ?? 'User not found'),
          ),
        );
      } else if (error.code == 'wrong-password') {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message ?? 'Wrong password'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color.fromARGB(255, 196, 254, 254),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock,
                size: 100,
              ),

              const SizedBox(
                height: 50,
              ),

              const Text(
                'Welcome to our app',
                style: TextStyle(
                  color: Color.fromARGB(255, 86, 86, 86),
                  fontSize: 16,
                ),
              ),

              const SizedBox(
                height: 50,
              ),

              // username textfield
              CustomTextField(
                controller: emailController,
                hintText: 'Username',
                keybordType: 'email',
                obscureText: false,
              ),

              const SizedBox(
                height: 5,
              ),

              //pasword textfield
              CustomTextField(
                controller: passwordController,
                hintText: 'Password',
                keybordType: 'text',
                obscureText: true,
              ),

              const SizedBox(
                height: 5,
              ),

              //Forgot Password
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 5,
              ),

              //Sign In Button
              CustomButton(
                text: 'Sign In',
                onTap: signUserIn,
              ),

              const SizedBox(
                height: 25,
              ),

              //not a member? register now
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Not a member?',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(
                      'Register now',
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
