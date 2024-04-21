import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AccountInfoScreen extends StatefulWidget {
  const AccountInfoScreen({super.key});

  @override
  State<StatefulWidget> createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  Future<DocumentSnapshot<Object>?> getUserDocument() async {
    User? user = FirebaseAuth.instance.currentUser;

    DocumentSnapshot<Object> userDocRef = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.uid)
        .get();

    return userDocRef;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getUserDocument(),
      builder: (BuildContext context,
          AsyncSnapshot<DocumentSnapshot<Object>?> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (snapshot.hasData) {
            Map<String, dynamic> userData =
                snapshot.data!.data() as Map<String, dynamic>;
            return Scaffold(
              appBar: AppBar(
                title: const Text('Account'),
                backgroundColor: const Color.fromARGB(255, 117, 213, 243),
              ),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.only(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    top: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        'First Name: ${userData['firstName']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Divider(),
                      Text(
                        'Last Name: ${userData['lastName']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Divider(),
                      Text(
                        'Email: ${userData['email']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          FirebaseAuth.instance.signOut();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Account'),
            backgroundColor: const Color.fromARGB(255, 117, 213, 243),
          ),
          body: ElevatedButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor:
                    Theme.of(context).colorScheme.primaryContainer),
            child: const Text('Logout'),
          ),
        );
      },
    );
  }
}
