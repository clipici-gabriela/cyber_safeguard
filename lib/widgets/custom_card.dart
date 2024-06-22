import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final VoidCallback? onTap;
  final IconData icon;
  final String text;

  const CustomCard({
    Key? key,
    this.onTap,
    required this.icon,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 4,
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: Colors.blue.shade900),
        title: Text(
          text,
          style: TextStyle(color: Colors.blue.shade900),
        ),
        trailing: Icon(Icons.arrow_forward, color: Colors.blue.shade900),
      ),
    );
  }
}
