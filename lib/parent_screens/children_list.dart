import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cyber_safeguard/parent_screens/child_settings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChildrenListScreen extends StatefulWidget {
  const ChildrenListScreen({super.key});

  @override
  State<ChildrenListScreen> createState() => _ChildrenListScreenState();
}

class _ChildrenListScreenState extends State<ChildrenListScreen> {
  final String parentId = FirebaseAuth.instance.currentUser!.uid;

  Future<List<Map<String, dynamic>>> fetchChildren(String parentId) async {
    List<Map<String, dynamic>> children = [];

    QuerySnapshot relationshipQuery = await FirebaseFirestore.instance
        .collection('Relationships')
        .where('parentId', isEqualTo: parentId)
        .get();

    for (var relDoc in relationshipQuery.docs) {
      String childId = relDoc['childId'];
      DocumentSnapshot childDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(relDoc['childId'])
          .get();
      if (childDoc.exists) {
        Map<String, dynamic> childData =
            childDoc.data() as Map<String, dynamic>;
            childData['id'] = childId;
        children.add(childData);
      }
    }

    return children;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchChildren(parentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Something is wrong, please try again later'),
            );
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var child = snapshot.data![index];
                bool isImageAvailable =
                    child['image'] != null && child['image'].isNotEmpty;
                ImageProvider<Object> imageProvider;
                if (isImageAvailable) {
                  imageProvider = NetworkImage(child['image']);
                } else {
                  // Use default image from assets
                  imageProvider =
                      const AssetImage('assests/images/user_image.png');
                }
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ChildSettingsScreen(
                              user: child,
                            )));
                  },
                  child: Card(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 37,
                                backgroundImage: imageProvider,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Text(
                                  child['firstName'].toString().toUpperCase(),
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios_sharp),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: Text("No children found."),
            );
          }
        },
      ),
    );
  }
}
