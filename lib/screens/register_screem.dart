// ignore_for_file: use_build_context_synchronously

import 'package:cyber_safeguard/widgets/custom_button.dart';
import 'package:cyber_safeguard/widgets/square_tile.dart';
import 'package:cyber_safeguard/widgets/text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  final Function()? onTap;
  const RegisterScreen({super.key, required this.onTap});

  @override
  State<RegisterScreen> createState() => _LoginPageState();
}

class _LoginPageState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  //sign user in
  void signUserUp() async {
    try {
      if(passwordController.text == confirmPasswordController.text){
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      }else {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('password does not match'),
          ),
        );
      }
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
      backgroundColor: Colors.grey.shade200,
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
                obscureText: false,
              ),

              const SizedBox(
                height: 5,
              ),

              //pasword textfield
              CustomTextField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
              ),

              CustomTextField(
                controller: confirmPasswordController,
                hintText: 'Confirm Password',
                obscureText: true,
              ),

              const SizedBox(
                height: 5,
              ),

              //Sign In Button
              CustomButton(
                text: 'Sign Up',
                onTap: signUserUp,
              ),

              const SizedBox(
                height: 25,
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Text(
                        'Or continue with',
                        style: TextStyle(),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              //google + apple sign in buttons
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SquareTile(imagePath: 'assests/images/google-logo.png'),
                  SizedBox(
                    width: 25,
                  ),
                  SquareTile(imagePath: 'assests/images/apple-logo.png'),
                ],
              ),

              const SizedBox(
                height: 50,
              ),

              //not a member? register now
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account?',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(
                      'Login now',
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
