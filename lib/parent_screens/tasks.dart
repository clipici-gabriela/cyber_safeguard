import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cyber_safeguard/models/task.dart';
import 'package:cyber_safeguard/widgets/add_task.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TasksList extends StatefulWidget {
  const TasksList({super.key});

  @override
  State<StatefulWidget> createState() => _TasksListState();
}

class _TasksListState extends State<TasksList> {
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();

    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    String parentId = FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot tasksSnapshot = await FirebaseFirestore.instance
        .collection('Tasks')
        .where('parentID', isEqualTo: parentId)
        .get();

    List<Task> fetchedTasks = tasksSnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return Task.fromFirestore(doc.id, data);
    }).toList();
    setState(() {
      tasks = fetchedTasks;
    });
  }

  void _openAddNewTaskOverlay() async {
    final result = await showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => const AddNewTask(),
    );

    if (result == true) {
      setState(() {
        _fetchTasks();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddNewTaskOverlay,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        child: const Icon(Icons.add_task),
      ),
      appBar: AppBar(
        title: const Text('Tasks'),
      ),
      body: ListView.separated(
        itemBuilder: (BuildContext context, int index) {
          final task = tasks[index];
          return Dismissible(
            key: Key(task.id),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20.0),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) async {
              // Remove the task from Firestore
              await FirebaseFirestore.instance
                  .collection('Tasks')
                  .doc(task.id)
                  .delete();

              // Update the state to remove the task from the list
              setState(() {
                tasks.removeAt(index);
              });

              // Show a snackbar for feedback
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 3),
                  content: Text("${task.description} deleted"),
                ),
              );
            },
            child: ListTile(
              title: Text(task.description),
              subtitle: Text('Assigned to: ${task.assignedTo}'),
              trailing: Text(task.deadline.format(context)),
              leading: task.completed
                  ? const Icon(
                      Icons.check_circle_outline,
                      color: Color.fromARGB(255, 0, 92, 35),
                    )
                  : const Icon(
                      Icons.circle_outlined,
                      color: Colors.red,
                    ),
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemCount: tasks.length,
      ),
    );
  }
}
