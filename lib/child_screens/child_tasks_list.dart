// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cyber_safeguard/models/task.dart';
import 'package:cyber_safeguard/messages_configuration/notification_sender.dart';

class TasksList extends StatefulWidget {
  const TasksList({super.key});

  @override
  State<TasksList> createState() => _TasksListState();
}

class _TasksListState extends State<TasksList> {
  String childUserId = '';
  String name = '';

  @override
  void initState() {
    super.initState();
    _fetchChildUserIdAndName();
  }

  Future<void> _fetchChildUserIdAndName() async {
    childUserId = FirebaseAuth.instance.currentUser!.uid;

    DocumentSnapshot childUserDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(childUserId)
        .get();
    name = childUserDoc['firstName'];

    setState(() {});
  }

  Future<void> sendNotificationToParent(Task task) async {
    final parentUserDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(task.parentId)
        .get();

    if (parentUserDoc.exists) {
      final parentData = parentUserDoc.data()!;
      final fcmToken = parentData['fcmToken'];

      if (fcmToken != null) {
        final notificationSender = NotificationSender();
        await notificationSender.sendNotification(
          fcmToken,
          context,
          'Task Completed',
          'Your child has completed the task: ${task.description}',
        );
      } else {
        print("No FCM token for parent.");
      }
    } else {
      print("No parent found with the given ID.");
    }
  }

  void _toggleTaskCompletion(Task task) async {
    try {
      await FirebaseFirestore.instance
          .collection('Tasks')
          .doc(task.id)
          .update({'completed': !task.completed});

      if (!task.completed) {
        sendNotificationToParent(task);
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update task: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SafeSteps'),
        backgroundColor: const Color.fromARGB(255, 117, 213, 243),
      ),
      body: childUserId.isEmpty || name.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Tasks')
                  .where('assignedTo', isEqualTo: name)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No tasks found'));
                }

                final tasks = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Task.fromFirestore(doc.id, data);
                }).toList();

                return ListView.separated(
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return ListTile(
                      title: Text(task.description),
                      trailing: Text(task.deadline.format(context)),
                      leading: IconButton(
                        icon: const Icon(Icons.check_circle_outline),
                        onPressed: () {
                          _toggleTaskCompletion(task);
                        },
                        color: task.completed ? Colors.green : Colors.grey,
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(),
                  itemCount: tasks.length,
                );
              },
            ),
    );
  }
}
