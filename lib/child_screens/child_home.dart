import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cyber_safeguard/child_screens/child_tasks_list.dart';
import 'package:cyber_safeguard/models/app_info.dart';
import 'package:cyber_safeguard/registration_screens/acount_info.dart';
import 'package:device_apps/device_apps.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:usage_stats/usage_stats.dart';

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
    collectAndStoreApps(childId);
  }

  void collectAndStoreApps(String childId) async {
    //await UsageStats.grantUsagePermission();
    // bool permissionGranted = UsageStats.checkUsagePermission() as bool;
    // print('Permission Granted: $permissionGranted');

    // if (!permissionGranted) {
    //   print('Permission not granted');
    //   return;
    // }

    List<Application> apps = await DeviceApps.getInstalledApplications(
      includeAppIcons: true,
      includeSystemApps: true,
      onlyAppsWithLaunchIntent: true,
    );
    DateTime endDate = DateTime.now();
    DateTime startDate = endDate.subtract(const Duration(days: 1));

    List<UsageInfo> usageStats =
        await UsageStats.queryUsageStats(startDate, endDate);

    for (var app in apps) {
      UsageInfo? appUsageInfo;

      for (var element in usageStats) {
        if (element.packageName == app.packageName) {
          appUsageInfo = element;
          break;
        }
      }

      int screenTime = 0;
      DateTime lastTimeUsed = DateTime.utc(1970, 1, 1);

      if (appUsageInfo != null) {
        if (appUsageInfo.totalTimeInForeground != null) {
          screenTime = int.parse(appUsageInfo.totalTimeInForeground!) /
              1000 ~/
              60; // Convert milliseconds to minutes
        }
        if (appUsageInfo.lastTimeUsed != null &&
            appUsageInfo.lastTimeUsed!.isNotEmpty) {
          int lastTimeUsedMillis =
              int.tryParse(appUsageInfo.lastTimeUsed!) ?? 0;
          if (lastTimeUsedMillis != 0) {
            lastTimeUsed =
                DateTime.fromMillisecondsSinceEpoch(lastTimeUsedMillis);
          }
        }
      }

      AppInfo appInfo = AppInfo(
        name: app.appName,
        packageName: app.packageName, 
        screenTime: screenTime, 
        lastTimeUsed: lastTimeUsed, 
        timeAllocation: 0, 
      );

      addAppInfo(childId, appInfo);
    }
  }

  void addAppInfo(String childId, AppInfo appInfo) {
    FirebaseFirestore.instance
        .collection('Apps')
        .doc(childId)
        .collection('UserApps')
        .doc(appInfo.packageName).set(appInfo.toMap());
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
