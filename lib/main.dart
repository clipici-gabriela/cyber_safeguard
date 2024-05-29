import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cyber_safeguard/registration_screens/auth.dart';
import 'package:device_apps/device_apps.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:usage_stats/usage_stats.dart';
import 'package:workmanager/workmanager.dart';

void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    await Firebase.initializeApp();

    //Garant user permission
    await UsageStats.grantUsagePermission();

    DateTime endDate = DateTime.now();
    DateTime startDate = endDate.subtract(const Duration(minutes: 5));

    List<UsageInfo> usageStats =
        await UsageStats.queryUsageStats(startDate, endDate);

    //Process usage data and send to Firebase
    for (var usage in usageStats) {
      if (usage.totalTimeInForeground != null) {
        //Fetch the app details
        Application? app = await DeviceApps.getApp(usage.packageName!);

        DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
            .collection('Apps')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('UserApps')
            .doc(usage.packageName)
            .get();

        int curentScreenTime = 0;
        if (documentSnapshot.exists) {
          curentScreenTime = documentSnapshot.get('screenTime') ?? 0;
        }

        int newScreenTime = curentScreenTime +
            int.parse(usage.totalTimeInForeground!) / 1000 ~/ 60;

        //Constract the data to send to Firebase
        Map<String, dynamic> appData = {
          'name': app!.appName,
          'packageName': usage.packageName,
          'totalTimeInForeground': newScreenTime,
          'lastTimeUsed': usage.lastTimeStamp
        };

        //Send to Firebase

        await FirebaseFirestore.instance
            .collection('Apps')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('UserApps')
            .doc(usage.packageName)
            .set(appData, SetOptions(merge: true));
      }
    }

    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );

  Workmanager().registerPeriodicTask("1", "backgoundTask",
      frequency: const Duration(minutes: 5));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthPage(),
    );
  }
}
