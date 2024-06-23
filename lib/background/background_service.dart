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
import 'package:cyber_safeguard/messages_configuration/notification_sender.dart';

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

    Application? app = await DeviceApps.getApp(packageName);
    DocumentSnapshot appDoc = await appDocRef.get();

    if (appDoc.exists) {
      var data = appDoc.data() as Map<String, dynamic>;
      int timeAllocated = data['timeAllocation'] ?? 0;
      int previousAppUsage = data['screenTime'] ?? 0;
      bool notificationSent = data['notificationSent'] ?? false;

      if (appUsage >= timeAllocated &&
          previousAppUsage < timeAllocated &&
          !notificationSent) {
        sendNotificationToParent(
          currentUser.uid,
          app!.appName,
          appUsage,
        );
        sendNotificationToChild(
          currentUser.uid,
          app.appName,
          appUsage,
        );
        await appDocRef.update({'notificationSent': true});
      }
    }

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

Future<void> sendNotificationToChild(
    String parentId, String appName, int appUsage) async {
  final parentUserDoc =
      await FirebaseFirestore.instance.collection('Users').doc(parentId).get();

  if (parentUserDoc.exists) {
    final parentData = parentUserDoc.data()!;
    final fcmToken = parentData['fcmToken'];

    if (fcmToken != null) {
      final notificationSender = NotificationSender();
      await notificationSender.sendNotification(
        fcmToken,
        null,
        'Time Allocation Reached',
        'You reached the allocated time for $appName with $appUsage minutes of usage.',
      );
    } else {
      print("No FCM token for parent.");
    }
  } else {
    print("No parent found with the given ID.");
  }
}

Future<void> sendNotificationToParent(
    String childId, String appName, int appUsage) async {
  // Fetch parentId from Relationships collection
  QuerySnapshot relationshipsSnapshot = await FirebaseFirestore.instance
      .collection('Relationships')
      .where('childId', isEqualTo: childId)
      .get();

  if (relationshipsSnapshot.docs.isNotEmpty) {
    String parentId = relationshipsSnapshot.docs.first['parentId'];

    // Fetch parent's FCM token
    final parentUserDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(parentId)
        .get();

    if (parentUserDoc.exists) {
      final parentData = parentUserDoc.data()!;
      final fcmToken = parentData['fcmToken'];

      if (fcmToken != null) {
        final notificationSender = NotificationSender();
        await notificationSender.sendNotification(
          fcmToken,
          null,
          'Time Allocation Reached',
          'Your child has reached the allocated time for $appName with $appUsage minutes of usage.',
        );
      } else {
        print("No FCM token for parent.");
      }
    } else {
      print("No parent found with the given ID.");
    }
  } else {
    print("No relationship found for the given child ID.");
  }
}
