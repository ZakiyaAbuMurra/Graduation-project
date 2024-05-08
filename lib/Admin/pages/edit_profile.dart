import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recyclear/utils/app_colors.dart';
import 'package:image_picker/image_picker.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  late String photoUrl = '';

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('users').doc(user!.uid).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Text('User data not found');
          }

          Map<String, dynamic> userData =
              snapshot.data!.data() as Map<String, dynamic>;
          photoUrl = userData['photoUrl'] ?? '';

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              GestureDetector(
                onTap: () {
                  if (photoUrl.isNotEmpty) {
                    _showOptionsDialog();
                  } else {
                    _selectImage();
                  }
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.primary,
                            width: 5), // Define border properties
                      ),
                      child: CircleAvatar(
                        radius: MediaQuery.of(context).size.width *
                            0.165, // Set radius based on device width
                        backgroundColor: AppColors.white,
                        backgroundImage: photoUrl.isNotEmpty
                            ? Image.memory(
                                base64Decode(photoUrl),
                                fit: BoxFit.cover,
                              ).image
                            : null,
                        child: photoUrl.isEmpty
                            ? const Icon(Icons.add_a_photo)
                            : null,
                      ),
                    ),
                    Visibility(
                      visible: false,
                      child: Positioned(
                        right: 0,
                        bottom: 0,
                        child: IconButton(
                          onPressed: () {
                            _showOptionsDialog();
                          },
                          icon: const Icon(Icons.camera_alt),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                userData['name'] != null && userData['name'].isNotEmpty
                    ? userData['name'].split(' ').map((word) {
                        if (word.isNotEmpty) {
                          return word[0].toUpperCase() + word.substring(1);
                        } else {
                          return '';
                        }
                      }).join(' ')
                    : '',
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8.0),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Name'),
                subtitle: Text(userData['name'] ?? ''),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  _showModifyPopup(
                      context, 'name', userData['name'] ?? '', userData);
                },
              ),
              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('Phone'),
                subtitle: Text(userData['phone'] ?? ''),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  _showModifyPopup(
                      context, 'phone', userData['phone'] ?? '', userData);
                },
              ),
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Email'),
                subtitle: Text(userData['email'] ?? ''),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {},
              ),
              ListTile(
                leading: const CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.lock, color: AppColors.white),
                ),
                title: const Text(
                  'Change Password',
                  style: TextStyle(color: AppColors.primary),
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  _showModifyPasswordPopup(context);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _showOptionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Action'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Option to view image
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                  _viewImage();
                },
                child: const Text('View Image'),
              ),
              // Option to modify image
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                  _selectImage();
                },
                child: const Text('Modify Image'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _viewImage() {
    if (photoUrl.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SizedBox(
              width: 300,
              height: 300,
              child: Image.memory(
                base64Decode(photoUrl),
                fit: BoxFit.cover,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _selectImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      // Read the image file
      final File imageFile = File(pickedImage.path);

      // Upload image to Firestore
      String newPhotoUrl = await _uploadImageToFirestore(imageFile);

      // Update photoUrl in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'photoUrl': newPhotoUrl}).then((_) {
        print('Photo updated successfully');
        // Trigger rebuild to update UI
        setState(() {
          photoUrl = newPhotoUrl; // Update class-level variable
        });
      }).catchError((error) {
        print('Failed to update photo: $error');
      });
    }
  }

  Future<String> _uploadImageToFirestore(File imageFile) async {
    // Read the image file
    List<int> imageBytes = await imageFile.readAsBytes();

    // Convert bytes to base64 string
    String base64Image = base64Encode(imageBytes);

    return base64Image;
  }

  void _showModifyPopup(BuildContext context, String field, String initialValue,
      Map<String, dynamic> userData) async {
    TextEditingController textFieldController = TextEditingController();
    textFieldController.text = initialValue;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Modify $field'),
          content: TextField(
            controller: textFieldController,
            decoration: InputDecoration(
              hintText: 'Enter new $field',
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                String modifiedData = textFieldController.text;
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .update({field: modifiedData}).then((_) {
                  print('$field updated successfully');
                  // Update local userData after successful update
                  userData[field] = modifiedData;
                  // Trigger rebuild to update UI
                  setState(() {});
                }).catchError((error) {
                  print('Failed to update $field: $error');
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showModifyPasswordPopup(BuildContext context) {
    TextEditingController currentPasswordController = TextEditingController();
    TextEditingController newPasswordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Enter current password',
                ),
              ),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Enter new password',
                ),
              ),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Confirm new password',
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                String currentPassword = currentPasswordController.text;
                String newPassword = newPasswordController.text;
                String confirmPassword = confirmPasswordController.text;

                if (newPassword != confirmPassword) {
                  // Passwords do not match
                  return;
                }

                try {
                  // Reauthenticate the user with their current password
                  AuthCredential credential = EmailAuthProvider.credential(
                    email: FirebaseAuth.instance.currentUser!.email!,
                    password: currentPassword,
                  );
                  await FirebaseAuth.instance.currentUser!
                      .reauthenticateWithCredential(credential);

                  // Update the user's password
                  await FirebaseAuth.instance.currentUser!
                      .updatePassword(newPassword);

                  // Password updated successfully
                  print('Password updated successfully');
                } catch (error) {
                  // Failed to reauthenticate or update password
                  print('Failed to update password: $error');
                }

                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
