import 'package:cyber_safeguard/applications/applications_list.dart';
import 'package:cyber_safeguard/widgets/custom_card.dart';
import 'package:flutter/material.dart';

class ChildSettingsScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const ChildSettingsScreen({super.key, required this.user});

  @override
  State<ChildSettingsScreen> createState() => _ChildSettingsScreenState();
}

class _ChildSettingsScreenState extends State<ChildSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.user['firstName'],
        ),
      ),
      body: Column(
        children: [
          CustomCard(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ApplicationList(
                        childId: widget.user['id'],
                      )));
            },
            icon: Icons.settings,
            text: 'Application Settings',
          ),
          CustomCard(
            onTap: () {},
            icon: Icons.screen_lock_portrait_outlined,
            text: 'Screen Time Control',
          ),
          CustomCard(
            onTap: () {},
            icon: Icons.web,
            text: 'Web Settings',
          ),
        ],
      ),
    );
  }
}
