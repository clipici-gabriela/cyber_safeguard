import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cyber_safeguard/child_screens/child_home.dart';
import 'package:cyber_safeguard/registration_screens/login_or_register.dart';
import 'package:cyber_safeguard/parent_screens/parent_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (cxt, snapshot) {
          if (snapshot.hasData) {
            final String uid = snapshot.data!.uid;
            final DocumentReference userDocRef =
                FirebaseFirestore.instance.collection('Users').doc(uid);

            // Check the user type field to determine the user type
            return FutureBuilder<DocumentSnapshot>(
              future: userDocRef.get(),
              builder: (context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.done) {
                  if (userSnapshot.data!.exists) {
                    final userType = userSnapshot.data!['userType'];
                    if (userType == 'parent') {
                      return const ParentHomeScreen();
                    } else if (userType == 'child') {
                      return const ChildHomeScreen();
                    }
                  }
                  // The document does not exist
                  return const LoginOrRegisterPage();
                }
                //While wainting for data
                return const CircularProgressIndicator();
              },
            );
          } else {
            return const LoginOrRegisterPage();
          }
        },
      ),
    );
  }
}
