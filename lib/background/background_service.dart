import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_apps/device_apps.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:usage_stats/usage_stats.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true, // application support foreground
      autoStart: true,
    ),
  );

  service.startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  await Firebase.initializeApp();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });

    service.on('stopService').listen((event) {
      service.stopSelf();
    });
  }

  Timer.periodic(const Duration(seconds: 30), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        service.setForegroundNotificationInfo(
          title: 'App Usage Monitoring',
          content: "Monitoring app usage in the background",
        );
        await fetchAndLogAppUsage();
      }
    }
    await fetchAndLogAppUsage();
    service.invoke('update');
  });
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

Future<void> fetchAndLogAppUsage() async {
  try {
    DateTime end = DateTime.now();
    DateTime start = DateTime(end.year, end.month, end.day); // Start of the day

    final List<String> installedPackages = await _getInstalledPackages();
    List<UsageInfo> usageStats = await UsageStats.queryUsageStats(start, end);

    int totalDeviceScreenTime = 0;

    for (var usage in usageStats) {
      if (usage.packageName != null &&
          usage.totalTimeInForeground != null &&
          installedPackages.contains(usage.packageName)) {
        int lastTimeUsedMillis = int.tryParse(usage.lastTimeUsed ?? '0') ?? 0;
        DateTime lastTimeUsed =
            DateTime.fromMillisecondsSinceEpoch(lastTimeUsedMillis);

        int totalTimeInForeground =
            int.tryParse(usage.totalTimeInForeground!) ?? 0;
        int appUsage = totalTimeInForeground ~/ 1000 ~/ 60;

        print('Package Name: ${usage.packageName} and the usage: $appUsage');

        await updateFirebase(
          usage.packageName!,
          appUsage,
          lastTimeUsed,
        );

        totalDeviceScreenTime += appUsage;
      }
    }

    // Update the total device screen time in Firestore
    await updateTotalDeviceScreenTime(totalDeviceScreenTime);

    print('Total device usage: $totalDeviceScreenTime');
  } catch (e) {
    print("Failed to get app usage: $e");
  }
}

Future<List<String>> _getInstalledPackages() async {
  List<String> installedPackages = [];
  List<Application> apps = await DeviceApps.getInstalledApplications(
    includeSystemApps: false,
    onlyAppsWithLaunchIntent: true,
  );

  for (var app in apps) {
    installedPackages.add(app.packageName);
  }

  return installedPackages;
}

Future<void> updateFirebase(
  String packageName,
  int appUsage,
  DateTime lastTimeUsed,
) async {
  var currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    DocumentReference appDocRef = FirebaseFirestore.instance
        .collection('Apps')
        .doc(currentUser.uid)
        .collection('UserApps')
        .doc(packageName);

    // Get the current data from Firestore
    DocumentSnapshot docSnapshot = await appDocRef.get();

    // If the document exists and has a 'lastTimeUsed' field, compare the timestamps
    if (docSnapshot.exists && docSnapshot.data() != null) {
      Timestamp? firestoreLastTimeUsed = docSnapshot['lastTimeUsed'];

      if (firestoreLastTimeUsed != null &&
          lastTimeUsed.isBefore(firestoreLastTimeUsed.toDate())) {
        // If the lastTimeUsed is not more recent, skip the update
        print("Skipping update for package: $packageName as the lastTimeUsed is not more recent.");
        return;
      }
    }

    Application? app = await DeviceApps.getApp(packageName);

    await appDocRef.set({
      'packageName': packageName,
      'name': app!.appName,
      'lastTimeUsed': lastTimeUsed,
      'screenTime': appUsage,
    }, SetOptions(merge: true));

    print("Update package: $packageName");
  }
}

Future<void> updateTotalDeviceScreenTime(int totalDeviceScreenTime) async {
  var currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('Apps').doc(currentUser.uid);

    await userDocRef.set({'totalDeviceScreenTime': totalDeviceScreenTime},
        SetOptions(merge: true));

    print("Update total device screen time: $totalDeviceScreenTime");
  }
}
