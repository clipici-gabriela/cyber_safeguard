// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cyber_safeguard/widgets/custom_button.dart';
import 'package:cyber_safeguard/widgets/text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

  //sign user in
  void signUserUp() async {
    try {
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
              CustomTextField(
                controller: firstNameController,
                hintText: 'First Name',
                keybordType: 'text',
                obscureText: false,
              ),

              const SizedBox(
                height: 5,
              ),

              CustomTextField(
                controller: lastNameController,
                hintText: 'Last Name',
                keybordType: 'text',
                obscureText: false,
              ),

              const SizedBox(
                height: 5,
              ),

              const Text('Please enter a valid email'),

              // username textfield
              CustomTextField(
                controller: emailController,
                hintText: 'Email',
                keybordType: 'email',
                obscureText: false,
              ),

              const SizedBox(
                height: 5,
              ),

              const Text(
                  'The password must be longer then 8 characters and should contain at least 1 upper letter, 1 numer and 1 special charater'),

              //pasword textfield
              CustomTextField(
                controller: passwordController,
                hintText: 'Password',
                keybordType: 'password',
                obscureText: true,
              ),

              CustomTextField(
                controller: confirmPasswordController,
                hintText: 'Confirm Password',
                keybordType: 'password',
                obscureText: true,
              ),

              CustomTextField(
                controller: numberController,
                hintText: 'Number phone',
                keybordType: 'number',
                obscureText: false,
              ),

              const SizedBox(
                height: 5,
              ),
              Row(
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
              const SizedBox(
                height: 5,
              ),
              Row(
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

              const SizedBox(
                height: 5,
              ),

              if (isChildChecked == true)
                Column(
                  children: [
                    const Text('The child should not be older then 18'),
                    CustomTextField(
                      controller: ageController,
                      hintText: 'Age',
                      keybordType: 'Number',
                      obscureText: false,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                  ],
                ),

              //Sign In Button
              CustomButton(
                text: 'Sign Up',
                onTap: signUserUp,
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
              const SizedBox(
                height: 25,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
