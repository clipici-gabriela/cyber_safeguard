import 'package:cloud_firestore/cloud_firestore.dart';
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
      DocumentSnapshot childDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(relDoc['childId'])
          .get();
      if (childDoc.exists) {
        Map<String, dynamic> childData =
            childDoc.data() as Map<String, dynamic>;
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
                return ListTile(
                  title: Text("${child['firstName']}"),
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
