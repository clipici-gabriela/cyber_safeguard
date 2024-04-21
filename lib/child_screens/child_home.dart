import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class ChildHomeScreen extends StatefulWidget {
  const ChildHomeScreen({super.key});

  @override
  State<ChildHomeScreen> createState() => _ChildHomeScreenState();
}

class _ChildHomeScreenState extends State<ChildHomeScreen> {
  int currentPageIndex = 0;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.task),
            label: 'Tasks',
          ),
          NavigationDestination(icon: Icon(Icons.person), label: 'Account')
        ],
        selectedIndex: currentPageIndex,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
      ),
      body: <Widget>[
        Scaffold(
          body: Center(
            child: IconButton(
              icon: const Icon(Icons.output),
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
            ),
          ),
        ),
        const Scaffold(),
      ][currentPageIndex],
    );
  }
}
