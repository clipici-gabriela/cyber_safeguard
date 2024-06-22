class AppInfo {
  final String name;
  final String packageName;

  AppInfo({
    required this.name,
    required this.packageName,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'packageName': packageName,

    };
  }
}