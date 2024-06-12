import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Function()? onTap;
  final String text;
  final IconData icon;

  const CustomCard({Key? key, required this.onTap, required this.text, required this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5, // Add elevation for a shadow effect
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // Rounded corners
        ),
        child: Padding(
          padding: const EdgeInsets.all(15), // Add padding inside the card
          child: Row(
            children: [
              Icon(
                icon, // You can change the icon based on context
                size: 30,
                color: Colors.blue, // Icon color
              ),
              const SizedBox(width: 10), // Space between icon and text
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87, // Text color
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
