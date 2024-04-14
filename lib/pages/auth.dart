import 'package:cyber_safeguard/parent_screen/parent_home.dart';
import 'package:cyber_safeguard/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatelessWidget{
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (cxt, snapshot) {
          if(snapshot.hasData){
            return const ParentHomeScreen();
          }
          else {
            return LoginPage();
          }          
        },
      ),
    );
  }
}