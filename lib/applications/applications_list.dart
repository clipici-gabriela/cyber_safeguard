import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ApplicationList extends StatefulWidget {
  final String childId;
  const ApplicationList({super.key, required this.childId});

  @override
  State<ApplicationList> createState() => _ApplicationListState();
}

class _ApplicationListState extends State<ApplicationList> {
  bool appShow = true;

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

  Future<void> updateAppTrackingStatus(
      String childId, String appId, bool status) async {
    await FirebaseFirestore.instance
        .collection('Apps')
        .doc(childId)
        .collection('UserApps')
        .doc(appId)
        .update({'showApp': status});
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
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ExpansionTile(
                    leading: const Icon(Icons.apps),
                    title: Text(app['name']),
                    children: <Widget>[
                      ListTile(
                        title:
                            Text('Screen Time: ${app['screenTime']} minutes'),
                      ),
                      ListTile(
                        title: Text('Last Time Used: ${app['lastTimeUsed']}'),
                      ),
                      ListTile(
                        title: Text(
                            'Time Allocation: ${app['timeAllocation']} minutes'),
                      ),
                      Row(
                        children: [
                          const Text('Track app: '),
                          TextButton(
                            onPressed: () async {
                              setState(() {
                                appShow = !appShow;
                              });

                              await updateAppTrackingStatus(
                                  widget.childId, app['packageName'], appShow);
                            },
                            child: Text(
                              appShow ? 'Yes' : 'No',
                              style: TextStyle(
                                  color: appShow ? Colors.green : Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
