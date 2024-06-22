import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cyber_safeguard/child_screens/child_tasks_list.dart';
import 'package:cyber_safeguard/models/app_info.dart';
import 'package:cyber_safeguard/registration_screens/acount_info.dart';
import 'package:device_apps/device_apps.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class ChildHomeScreen extends StatefulWidget {
  const ChildHomeScreen({super.key});

  @override
  State<ChildHomeScreen> createState() => _ChildHomeScreenState();
}

class _ChildHomeScreenState extends State<ChildHomeScreen> {
  int currentPageIndex = 0;
  String childId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    collectAndStoreApps;
  }

  void collectAndStoreApps(String childId) async {
    List<Application> apps = await DeviceApps.getInstalledApplications(
      includeAppIcons: true,
      includeSystemApps: true,
      onlyAppsWithLaunchIntent: true,
    );

    for (var app in apps) {
      AppInfo appInfo = AppInfo(
        name: app.appName,
        packageName: app.packageName,
      );

      addAppInfo(childId, appInfo);
    }
  }

  void addAppInfo(String childId, AppInfo appInfo) {
    FirebaseFirestore.instance
        .collection('Apps')
        .doc(childId)
        .collection('UserApps')
        .doc(appInfo.packageName)
        .set(appInfo.toMap());
  }

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
        const TasksList(),
        const AccountInfoScreen()
      ][currentPageIndex],
    );
  }
}
