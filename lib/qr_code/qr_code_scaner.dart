import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanQRCode extends StatefulWidget {
  const ScanQRCode({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ScanQRCodeState();
  }
}

class _ScanQRCodeState extends State<ScanQRCode> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      controller.pauseCamera();
      final parts = scanData.code!.split(';');
      final childUid = parts[0];
      final childName = parts[1];

      final String parentUid = FirebaseAuth.instance.currentUser!.uid;

      final batch = FirebaseFirestore.instance.batch();
      final childDocRef =
          FirebaseFirestore.instance.collection('Users').doc(childUid);

      batch.update(childDocRef, {
        'parentUid': parentUid,
      });

      final parentDocRef =
          FirebaseFirestore.instance.collection('Users').doc(parentUid);

      batch.set(
          parentDocRef,
          {
            'Children': FieldValue.arrayUnion([
              {'uid': childUid, 'name': childName}
            ]),
          },
          SetOptions(merge: true));

      await batch.commit().then((value) {
        Navigator.pop(context);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.red,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
          const Expanded(
            flex: 5,
            child: Center(
              child: Text('Scan a code'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
