import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';

class ApplicationList extends StatefulWidget {
  final String childId;
  const ApplicationList({super.key, required this.childId});

  @override
  State<ApplicationList> createState() => _ApplicationListState();
}

class _ApplicationListState extends State<ApplicationList> {
  Future<List<Map<String, dynamic>>> fetchUserApp(String childId) async {
    List<Map<String, dynamic>> userApps = [];

    QuerySnapshot appSnapshot = await FirebaseFirestore.instance
        .collection('Apps')
        .doc(childId)
        .collection('UserApps')
        .get();

    for (var doc in appSnapshot.docs) {
      userApps.add(doc.data() as Map<String, dynamic>);
    }

    return userApps;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Settings'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchUserApp(widget.childId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('Something went wrong'),
            );
          }
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var app = snapshot.data![index];
                return ListTile(
                  // leading:
                  //     Image.memory((app['icon'] as ApplicationWithIcon).icon),
                  title: Text(app['name']),
                );
              },
            );
          } else {
            return const Center(
              child: Text('No apps found'),
            );
          }
        },
      ),
    );
  }
}
