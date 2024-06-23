// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cyber_safeguard/messages_configuration/notification_sender.dart';

class AddNewTask extends StatefulWidget {
  const AddNewTask({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AddNewTaskState();
  }
}

class _AddNewTaskState extends State<AddNewTask> {
  final _formKey = GlobalKey<FormState>();

  String _enteredTask = '';
  String? _assignedChild;

  TimeOfDay? _pickedTime;

  List<String>? childrenList;

  @override
  void initState() {
    super.initState();
    String parentUserId = FirebaseAuth.instance.currentUser!.uid;

    getChildrenNames(parentUserId).then((namesList) {
      setState(() {
        childrenList = namesList;
      });
    });
  }

  Future<List<String>> getChildrenNames(String parentUserId) async {
    String parentId = FirebaseAuth.instance.currentUser!.uid;
    List<String> childrenNames = [];

    var relationshipQuery = await FirebaseFirestore.instance
        .collection('Relationships')
        .where('parentId', isEqualTo: parentId)
        .get();

    for (var doc in relationshipQuery.docs) {
      var childId = doc['childId'];
      var childSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(childId)
          .get();
      if (childSnapshot.exists) {
        Map<String, dynamic> childData = childSnapshot.data()!;
        if (childData.containsKey('firstName')) {
          childrenNames.add(childData['firstName'] as String);
        }
      }
    }
    return childrenNames;
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay initialTime = TimeOfDay.now();
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime != null &&
        (pickedTime.hour > initialTime.hour ||
            (pickedTime.hour == initialTime.hour &&
                pickedTime.minute > initialTime.minute))) {
      setState(() {
        _pickedTime = pickedTime;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please pick a future time for today.")),
      );
    }
  }

  void _submit() async {
    final isValid = _formKey.currentState!.validate();

    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields and pick a time'),
        ),
      );
      return;
    }

    final parentUser = FirebaseAuth.instance.currentUser;

    _formKey.currentState!.save();

    final now = DateTime.now();
    final deadlineDateTime = DateTime(
        now.year, now.month, now.day, _pickedTime!.hour, _pickedTime!.minute);

    final taskData = {
      'parentID': parentUser!.uid,
      'description': _enteredTask,
      'assignedTo': _assignedChild,
      'deadline': Timestamp.fromDate(deadlineDateTime),
      'completed': false,
    };

    try {
      await FirebaseFirestore.instance.collection('Tasks').add(taskData);
      
      // Send notification to the assigned child
      await sendNotificationToChild(_assignedChild!, taskData['description'] as String);

      Navigator.pop(context, true);
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? 'Failed to add task')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add task: $e')),
      );
    }
  }

  Future<void> sendNotificationToChild(String childName, String taskDescription) async {
    final userQuerySnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where('firstName', isEqualTo: childName)
        .get();

    if (userQuerySnapshot.docs.isNotEmpty) {
      final userDoc = userQuerySnapshot.docs[0];
      final fcmToken = userDoc.data()['fcmToken'];

      if (fcmToken != null) {
        final notificationSender = NotificationSender();
        await notificationSender.sendNotification(
          fcmToken,
          context,
          'New Task Assigned',
          'You have a new task: $taskDescription',
        );
      } else {
        print("No FCM token for user.");
      }
    } else {
      print("No user found with the given first name.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Task'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, keyboardSpace + 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Task',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  autocorrect: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the task';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _enteredTask = value!;
                  },
                ),
                const SizedBox(height: 20),
                FutureBuilder<List<String>>(
                  future: getChildrenNames(FirebaseAuth.instance.currentUser!.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (snapshot.hasData) {
                      var childrenNames = snapshot.data!;

                      if (_assignedChild == null ||
                          !childrenNames.contains(_assignedChild)) {
                        _assignedChild = childrenNames.isNotEmpty
                            ? childrenNames.first
                            : null;
                      }

                      return DropdownButtonFormField<String>(
                        value: _assignedChild,
                        decoration: InputDecoration(
                          labelText: 'Assign to',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        items: childrenNames
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _assignedChild = value!;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please assign the task';
                          }
                          return null;
                        },
                      );
                    } else {
                      return const Text('No children available');
                    }
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      _pickedTime == null
                          ? 'No time selected'
                          : 'Picked Time: ${_pickedTime!.format(context)}',
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () => _selectTime(context),
                      child: const Text('Pick Time'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Add Task'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
