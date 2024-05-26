import 'dart:typed_data';

class AppInfo {
  final String name;
  final String packageName;
  final int screenTime; // in minutes
  final DateTime lastTimeUsed;
  final int timeAllocation; // in minutes


  AppInfo({
    required this.name,
    required this.packageName,
    required this.screenTime,
    required this.lastTimeUsed,
    required this.timeAllocation,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': packageName,
      'screenTime': screenTime,
      'lastTimeUsed': lastTimeUsed.toIso8601String(),
      'timeAllocation': timeAllocation,
    };
  }
}