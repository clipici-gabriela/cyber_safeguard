import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:usage_stats/usage_stats.dart';

Future<void> fetchAndLogAppUsage() async {
  // Check and request usage stats permission
  bool? granted = await UsageStats.checkUsagePermission();
  if (granted == false) {
    await UsageStats.grantUsagePermission();
    return;
  }

  DateTime end = DateTime.now();
  DateTime start = end.subtract(const Duration(minutes: 15)); // Fetch usage for the last 15 minutes

  List<UsageInfo> usageStats = await UsageStats.queryUsageStats(start, end);

  for (var usage in usageStats) {
    if (usage.packageName != null && usage.totalTimeInForeground != null && usage.lastTimeUsed != null) {
      await updateFirebase(
        usage.packageName!,
        int.parse(usage.totalTimeInForeground!),
        DateTime.fromMillisecondsSinceEpoch(int.parse(usage.lastTimeUsed!)),
      );
    }
  }
}

Future<void> updateFirebase(
    String packageName, int screenTime, DateTime lastTimeUsed) async {
  var currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    DocumentReference appDocRef = FirebaseFirestore.instance
        .collection('Apps')
        .doc(currentUser.uid)
        .collection('UserApps')
        .doc(packageName);

    DocumentSnapshot doc = await appDocRef.get();
    int currentScreenTime = doc.exists ? doc.get('screenTime') ?? 0 : 0;
    int newScreenTime = currentScreenTime + screenTime ~/ 1000 ~/ 60; // Convert milliseconds to minutes

    await appDocRef.set({
      'lastTimeUsed': lastTimeUsed,
      'screenTime': newScreenTime,
    }, SetOptions(merge: true));
  }
}
