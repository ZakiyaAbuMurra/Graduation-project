import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfile extends StatelessWidget {
  const EditProfile({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    // Get the user's nickname and email from the signed-in user's profile
    String? name = user?.displayName;
    String? email = user?.email;
    String? phone = user?.phoneNumber;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // User photo and name
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.green, // Green border color
            child: CircleAvatar(
              radius: 48,
              backgroundColor: Colors.white, // White background color
              backgroundImage:
                  NetworkImage('https://example.com/user-photo.jpg'),
            ),
          ),
          const SizedBox(height: 16.0),
          Text(
            name ?? '', // User name
            style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          // User nickname
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Name'),
            subtitle: Text(name ?? ''),
            trailing:
                const Icon(Icons.arrow_forward_ios), // Trailing arrow icon
            onTap: () {
              // Handle onTap
              _showModifyPopup(context, 'Name');
            },
          ),
          // User phone number
          ListTile(
            leading: const Icon(Icons.phone),
            title: const Text('Phone'),
            subtitle: Text(phone ?? ''),
            trailing:
                const Icon(Icons.arrow_forward_ios), // Trailing arrow icon
            onTap: () {
              // Handle onTap
              _showModifyPopup(context, 'Phone');
            },
          ),
          // User email
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Email'),
            subtitle: Text(email ?? ''),
            trailing:
                const Icon(Icons.arrow_forward_ios), // Trailing arrow icon
            onTap: () {
              // Handle onTap
              _showModifyPopup(context, 'Email');
            },
          ),
          // Change password
          ListTile(
            leading: const CircleAvatar(
              radius: 20,
              backgroundColor: Colors.green,
              child: Icon(Icons.lock, color: Colors.white),
            ),
            title: const Text(
              'Change Password',
              style: TextStyle(color: Colors.green),
            ),
            trailing:
                const Icon(Icons.arrow_forward_ios), // Trailing arrow icon
            onTap: () {
              // Handle onTap
              _showModifyPopup(context, 'Password');
            },
          ),
        ],
      ),
    );
  }

  void _showModifyPopup(BuildContext context, String field) {
    // Initialize controller to handle text field value
    TextEditingController textFieldController = TextEditingController();

    // Retrieve current user data for the specified field
    String? currentData = ''; // Retrieve current data from Firebase

    // Set text field with current data
    textFieldController.text = currentData;
    // Show popup dialog for modifying the respective field
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Modify $field'), // Title of the popup dialog
          content: TextField(
            // TextField for modifying the field
            controller: textFieldController, // Set controller
            decoration: InputDecoration(
              hintText: 'Enter new $field',
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                String modifiedData = textFieldController.text;
                User? currentUser = FirebaseAuth.instance.currentUser;
                if (currentUser != null) {
                  currentUser.updateDisplayName(modifiedData).then((_) {
                    // Update successful
                    print('Display name updated successfully');
                    Navigator.of(context).pop();
                  }).catchError((error) {
                    // Handle error
                    print('Failed to update display name: $error');
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text('Save'), // Save button text
            ),
            TextButton(
              onPressed: () {
                // Handle Cancel button tap
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'), // Cancel button text
            ),
          ],
        );
      },
    );
  }
}
