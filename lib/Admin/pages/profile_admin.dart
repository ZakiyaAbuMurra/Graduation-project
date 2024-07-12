import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recyclear/utils/app_colors.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileAdmin extends StatefulWidget {
  const EditProfileAdmin({super.key});

  @override
  State<EditProfileAdmin> createState() => _EditProfileAdminState();
}

class _EditProfileAdminState extends State<EditProfileAdmin> {
  late String photoUrl = '';
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('admin_info')
            .doc(user!.uid)
            .get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('User data not found'));
          }

          Map<String, dynamic> userData =
              snapshot.data!.data() as Map<String, dynamic>;
          photoUrl = userData['photoURL'] ?? '';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
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
                              width: 5,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: kIsWeb
                                ? 100
                                : MediaQuery.of(context).size.width * 0.165,
                            backgroundColor: AppColors.white,
                            backgroundImage: _getImageProvider(photoUrl),
                            child: photoUrl.isEmpty
                                ? const Icon(Icons.add_a_photo, size: 50)
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    userData['displayName'] != null &&
                            userData['displayName'].isNotEmpty
                        ? userData['displayName'].split(' ').map((word) {
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
                  _buildListTile(
                    icon: Icons.person,
                    title: 'Name',
                    subtitle: userData['displayName'] ?? '',
                    onTap: () {
                      _showModifyPopup(context, 'displayName',
                          userData['displayName'] ?? '', userData);
                    },
                  ),
                  _buildListTile(
                    icon: Icons.phone,
                    title: 'Phone',
                    subtitle: userData['phone'] ?? '',
                    onTap: () {
                      _showModifyPopup(
                          context, 'phone', userData['phone'] ?? '', userData);
                    },
                  ),
                  _buildListTile(
                    icon: Icons.email,
                    title: 'Email',
                    subtitle: userData['email'] ?? '',
                    onTap: () {},
                  ),
                  _buildListTile(
                    icon: Icons.lock,
                    title: 'Change Password',
                    subtitle: '',
                    onTap: () {
                      _showModifyPasswordPopup(context);
                    },
                    trailingIcon: const Icon(Icons.arrow_forward_ios),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  ListTile _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailingIcon,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailingIcon ?? const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }

  ImageProvider _getImageProvider(String photoUrl) {
    if (photoUrl.startsWith('http') || photoUrl.startsWith('https')) {
      return NetworkImage(photoUrl);
    } else {
      try {
        return MemoryImage(base64Decode(photoUrl));
      } catch (e) {
        print('Error decoding base64 image: $e');
        return const AssetImage('assets/images/default_avatar.png');
      }
    }
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
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  _viewImage();
                },
                child: const Text('View Image'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
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
              child: Image(
                image: _getImageProvider(photoUrl),
                fit: BoxFit.cover,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
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
    if (kIsWeb) {
      await _selectImageForWeb();
    } else {
      await _selectImageForMobile();
    }
  }

  Future<void> _selectImageForWeb() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      Uint8List imageBytes = await pickedImage.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      await _updatePhotoUrl(base64Image);
    }
  }

  Future<void> _selectImageForMobile() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      final File imageFile = File(pickedImage.path);
      String base64Image = await _uploadImageToFirestore(imageFile);
      await _updatePhotoUrl(base64Image);
    }
  }

  Future<void> _updatePhotoUrl(String newPhotoUrl) async {
    await FirebaseFirestore.instance
        .collection('admin_info')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'photoURL': newPhotoUrl}).then((_) {
      print('Photo updated successfully');
      setState(() {
        photoUrl = newPhotoUrl;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile photo updated')),
        );
      });
    }).catchError((error) {
      print('Failed to update photo: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update photo: $error')),
      );
    });
  }

  Future<String> _uploadImageToFirestore(File imageFile) async {
    List<int> imageBytes = await imageFile.readAsBytes();
    String base64Image = base64Encode(imageBytes);
    return base64Image;
  }

  void _showModifyPopup(BuildContext context, String field, String initialValue,
      Map<String, dynamic> userData) async {
    if (kIsWeb) {
      _showModifyPopupWeb(context, field, initialValue, userData);
    } else {
      _showModifyPopupMobile(context, field, initialValue, userData);
    }
  }

  void _showModifyPopupWeb(BuildContext context, String field,
      String initialValue, Map<String, dynamic> userData) {
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
                    .collection('admin_info')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .update({field: modifiedData}).then((_) {
                  print('$field updated successfully');
                  userData[field] = modifiedData;
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$field updated successfully')),
                  );
                }).catchError((error) {
                  print('Failed to update $field: $error');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update $field: $error')),
                  );
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

  void _showModifyPopupMobile(BuildContext context, String field,
      String initialValue, Map<String, dynamic> userData) {
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
                    .collection('admin_info')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .update({field: modifiedData}).then((_) {
                  print('$field updated successfully');
                  userData[field] = modifiedData;
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$field updated successfully')),
                  );
                }).catchError((error) {
                  print('Failed to update $field: $error');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update $field: $error')),
                  );
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
    if (kIsWeb) {
      _showModifyPasswordPopupWeb(context);
    } else {
      _showModifyPasswordPopupMobile(context);
    }
  }

  void _showModifyPasswordPopupWeb(BuildContext context) {
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Passwords do not match')),
                  );
                  return;
                }

                try {
                  AuthCredential credential = EmailAuthProvider.credential(
                    email: FirebaseAuth.instance.currentUser!.email!,
                    password: currentPassword,
                  );
                  await FirebaseAuth.instance.currentUser!
                      .reauthenticateWithCredential(credential);

                  await FirebaseAuth.instance.currentUser!
                      .updatePassword(newPassword);

                  print('Password updated successfully');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Password updated successfully')),
                  );
                } catch (error) {
                  print('Failed to update password: $error');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Failed to update password: $error')),
                  );
                }

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

  void _showModifyPasswordPopupMobile(BuildContext context) {
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Passwords do not match')),
                  );
                  return;
                }

                try {
                  AuthCredential credential = EmailAuthProvider.credential(
                    email: FirebaseAuth.instance.currentUser!.email!,
                    password: currentPassword,
                  );
                  await FirebaseAuth.instance.currentUser!
                      .reauthenticateWithCredential(credential);

                  await FirebaseAuth.instance.currentUser!
                      .updatePassword(newPassword);

                  print('Password updated successfully');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Password updated successfully')),
                  );
                } catch (error) {
                  print('Failed to update password: $error');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Failed to update password: $error')),
                  );
                }

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
}
