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
  int timeAllocated = 0;

  Stream<List<Map<String, dynamic>>> fetchUserApp(String childId) {
    return FirebaseFirestore.instance
        .collection('Apps')
        .doc(childId)
        .collection('UserApps')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> appData = doc.data();
        if (appData.containsKey('lastTimeUsed')) {
          appData['lastTimeUsed'] =
              (appData['lastTimeUsed'] as Timestamp).toDate();
        }
        appData['id'] = doc.id; // Add the document ID for update operations
        return appData;
      }).toList();
    });
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

  Future<void> updateTimeAllocation(
      String childId, String appId, int timeAllocation) async {
    await FirebaseFirestore.instance
        .collection('Apps')
        .doc(childId)
        .collection('UserApps')
        .doc(appId)
        .update({'timeAllocation': timeAllocation});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Settings'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: fetchUserApp(widget.childId),
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
                int timeAllocation = app['timeAllocation'] ?? 0;
                TextEditingController timeController = TextEditingController(
                  text: timeAllocation.toString(),
                );
                return Card(
                  color: Colors.blue.shade50,
                  margin: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: ExpansionTile(
                    leading: Icon(Icons.apps, color: Colors.blue.shade900),
                    title: Text(
                      app['name'],
                      style: TextStyle(color: Colors.blue.shade900),
                    ),
                    children: <Widget>[
                      ListTile(
                        title:
                            Text('Screen Time: ${app['screenTime']} minutes'),
                      ),
                      ListTile(
                        title: Text('Last Time Used: ${app['lastTimeUsed']}'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            const Text('Time Allocation: '),
                            Expanded(
                              child: TextField(
                                controller: timeController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: 'Enter minutes',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10.0,
                                    horizontal: 15.0,
                                  ),
                                ),
                                onSubmitted: (value) async {
                                  int newTime = int.tryParse(value) ?? 0;
                                  await updateTimeAllocation(
                                    widget.childId,
                                    app['id'], // Use the document ID here
                                    newTime,
                                  );
                                  setState(() {
                                    app['timeAllocation'] = newTime;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Track app: '),
                          TextButton.icon(
                            onPressed: () async {
                              setState(() {
                                appShow = !appShow;
                              });

                              await FirebaseFirestore.instance
                                  .collection('Apps')
                                  .doc(widget.childId)
                                  .collection('UserApps')
                                  .doc(app['id']) // Use the document ID here
                                  .update({'showApp': appShow});
                            },
                            icon: Icon(
                              appShow ? Icons.check_circle : Icons.cancel,
                              color: appShow ? Colors.green : Colors.red,
                            ),
                            label: Text(
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
