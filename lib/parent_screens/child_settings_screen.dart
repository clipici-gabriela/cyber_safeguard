import 'package:cyber_safeguard/applications/applications_list.dart';
import 'package:cyber_safeguard/widgets/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChildSettingsScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const ChildSettingsScreen({super.key, required this.user});

  @override
  State<ChildSettingsScreen> createState() => _ChildSettingsScreenState();
}

class _ChildSettingsScreenState extends State<ChildSettingsScreen> {
  Stream<DocumentSnapshot> fetchScreenTimeData(String childId) {
    return FirebaseFirestore.instance
        .collection('Apps')
        .doc(childId)
        .snapshots();
  }

  Future<void> updateScreenTimeAllocation(
      String childId, int timeAllocation) async {
    await FirebaseFirestore.instance
        .collection('Apps')
        .doc(childId)
        .update({'timeAllocation': timeAllocation});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.user['firstName'],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          CustomCard(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ApplicationList(
                  childId: widget.user['id'],
                ),
              ));
            },
            icon: Icons.settings,
            text: 'Application Settings',
          ),
          Card(
            margin: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            elevation: 4,
            child: ExpansionTile(
              leading: Icon(Icons.screen_lock_portrait_outlined,
                  color: Colors.blue.shade900),
              title: const Text(
                'Screen Time Control',
                style: TextStyle(color: Color.fromARGB(255, 13, 71, 165)),
              ),
              children: [
                StreamBuilder<DocumentSnapshot>(
                  stream: fetchScreenTimeData(widget.user['id']),
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
                    if (snapshot.hasData && snapshot.data!.exists) {
                      var screenTimeData =
                          snapshot.data!.data() as Map<String, dynamic>;
                      int timeAllocation = screenTimeData['timeAllocation'] ?? 0;
                      TextEditingController timeController =
                          TextEditingController(
                        text: timeAllocation.toString(),
                      );
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(
                                  'Total Usage: ${screenTimeData['totalDeviceScreenTime']} minutes'),
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
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          vertical: 10.0,
                                          horizontal: 15.0,
                                        ),
                                      ),
                                      onSubmitted: (value) async {
                                        int newTime =
                                            int.tryParse(value) ?? 0;
                                        await updateScreenTimeAllocation(
                                            widget.user['id'], newTime);
                                        setState(() {
                                          screenTimeData['timeAllocation'] =
                                              newTime;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return const Center(
                        child: Text('No screen time data found'),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
