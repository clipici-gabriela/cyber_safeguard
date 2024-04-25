import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cyber_safeguard/qr_code/qr_code_generater.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AccountInfoScreen extends StatefulWidget {
  const AccountInfoScreen({super.key});

  @override
  State<StatefulWidget> createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  String? imageUrl;

  Future<DocumentSnapshot<Object>?> getUserDocument() async {
    User? user = FirebaseAuth.instance.currentUser;

    DocumentSnapshot<Object> userDocRef = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.uid)
        .get();

    return userDocRef;
  }

  Future<void> updatePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      File imageFile = File(image.path);

      Reference ref = FirebaseStorage.instance
          .ref()
          .child('user_image')
          .child('/${FirebaseAuth.instance.currentUser!.uid}.jpg');

      UploadTask uploadTask = ref.putFile(imageFile);

      await uploadTask.whenComplete(() async {
        String downloadURL = await ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('Users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({'image': downloadURL});

        setState(() {
          imageUrl = downloadURL;
        });
      });
    } else {
      print('no image selected');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getUserDocument(),
      builder: (BuildContext context,
          AsyncSnapshot<DocumentSnapshot<Object>?> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (snapshot.hasData) {
            Map<String, dynamic> userData =
                snapshot.data!.data() as Map<String, dynamic>;
            // bool hasImageField = userData.containsKey('image');
            bool isImageAvailable =
                userData['image'] != null && userData['image'].isNotEmpty;
            ImageProvider<Object> imageProvider;
            if (isImageAvailable) {
              imageProvider = NetworkImage(userData['image']);
            } else {
              // Use default image from assets
              imageProvider = const AssetImage('assests/images/user_image.png');
            }
            return Scaffold(
              appBar: AppBar(
                title: const Text('Account'),
                backgroundColor: const Color.fromARGB(255, 117, 213, 243),
              ),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.only(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    top: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: imageProvider,
                      ),
                      TextButton(
                        onPressed: () async {
                          await updatePhoto();
                        },
                        child: const Text('Update Photo'),
                      ),
                      if (!isImageAvailable)
                        const SizedBox(
                          height: 20,
                        ),
                      Text(
                        'First Name: ${userData['firstName']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Divider(),
                      Text(
                        'Last Name: ${userData['lastName']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Divider(),
                      Text(
                        'Email: ${userData['email']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      if (userData['userType'] == 'child')
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const GenerateQRCode()));
                          },
                          child: const Text('Generate QR Code'),
                        ),
                      ElevatedButton(
                        onPressed: () {
                          FirebaseAuth.instance.signOut();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Account'),
            backgroundColor: const Color.fromARGB(255, 117, 213, 243),
          ),
          body: ElevatedButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor:
                    Theme.of(context).colorScheme.primaryContainer),
            child: const Text('Logout'),
          ),
        );
      },
    );
  }
}
