import 'package:flutter/material.dart';


class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.location_on_outlined),
            label: 'Location',
          ),
          // NavigationDestination(
          //   icon: Icon(Icons.notifications_active_outlined),
          //   label: 'Notification',
          // ),
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
        Scaffold(),
        Scaffold(),
        Scaffold(),
        Scaffold(),
        Scaffold(),
      ][currentPageIndex],
    );
  }
}
