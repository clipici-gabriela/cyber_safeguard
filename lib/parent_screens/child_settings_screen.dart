import 'package:flutter/material.dart';

class ChildSettingsScreen extends StatefulWidget {
  final String user;

  const ChildSettingsScreen({super.key, required this.user});

  @override
  State<ChildSettingsScreen> createState() => _ChildSettingsScreenState();
}

class _ChildSettingsScreenState extends State<ChildSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.user),),
    );
  }
}
