import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GenerateQRCode extends StatefulWidget {
  const GenerateQRCode({super.key});

  @override
  State<StatefulWidget> createState() {
    return _GenerateQRCodeState();
  }
}

class _GenerateQRCodeState extends State<GenerateQRCode> {
  final User? user = FirebaseAuth.instance.currentUser;
  String qrData = "";

    @override
  void initState() {
    super.initState();
    fetchChildData();
  }

  Future<void> fetchChildData() async {
    if (user != null) {
      DocumentSnapshot childDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user!.uid)
          .get();
      Map<String, dynamic> childData = childDoc.data() as Map<String, dynamic>;
      setState(() {
        qrData = "${user!.uid};${childData['firstName']}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: qrData.isNotEmpty ?
        QrImageView(
          data: qrData,
          version: QrVersions.auto,
          size: 200.0,
        )
        : const CircularProgressIndicator(),
      ),
    );
  }
}
