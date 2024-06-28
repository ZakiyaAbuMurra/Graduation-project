import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditDriverPage extends StatefulWidget {
  final DocumentSnapshot driver;

  const EditDriverPage({Key? key, required this.driver}) : super(key: key);

  @override
  _EditDriverPageState createState() => _EditDriverPageState();
}

class _EditDriverPageState extends State<EditDriverPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _photoUrlController;
  late TextEditingController _areaController;
  late TextEditingController _truckNumberController;

  String? originalName;
  String? originalPhone;
  String? originalEmail;
  String? originalPhotoUrl;
  String? originalArea;
  String? originalTruckNumber;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.driver['name']);
    _phoneController = TextEditingController(text: widget.driver['phone']);
    _emailController = TextEditingController(text: widget.driver['email']);
    _photoUrlController = TextEditingController(text: widget.driver['photoUrl']);
    _areaController = TextEditingController(text: widget.driver['area']);
    _truckNumberController = TextEditingController(text: widget.driver['trucknumber']);

    originalName = widget.driver['name'];
    originalPhone = widget.driver['phone'];
    originalEmail = widget.driver['email'];
    originalPhotoUrl = widget.driver['photoUrl'];
    originalArea = widget.driver['area'];
    originalTruckNumber = widget.driver['trucknumber'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _photoUrlController.dispose();
    _areaController.dispose();
    _truckNumberController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      if (_nameController.text != originalName ||
          _phoneController.text != originalPhone ||
          _emailController.text != originalEmail ||
          _photoUrlController.text != originalPhotoUrl ||
          _areaController.text != originalArea ||
          _truckNumberController.text != originalTruckNumber) {
        try {
          await FirebaseFirestore.instance.collection('users').doc(widget.driver.id).update({
            'name': _nameController.text,
            'phone': _phoneController.text,
            'email': _emailController.text,
            'photoUrl': _photoUrlController.text,
            'area': _areaController.text,
            'trucknumber': _truckNumberController.text,
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Driver updated successfully')),
          );
          Navigator.of(context).pop();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update driver: $e')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No changes to update')),
        );
      }
    }
  }

  Future<void> _deleteDriver() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Driver'),
          content: const Text('Are you sure you want to delete this driver?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance.collection('users').doc(widget.driver.id).delete();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Navigate back to the previous screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Driver deleted successfully')),
                  );
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete driver: $e')),
                  );
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Driver'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _photoUrlController.text.isNotEmpty
                              ? NetworkImage(_photoUrlController.text)
                              : const AssetImage('assets/images/avatar.png') as ImageProvider,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: 'Phone',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _photoUrlController,
                        decoration: InputDecoration(
                          labelText: 'Photo URL',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a photo URL';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _areaController,
                        decoration: InputDecoration(
                          labelText: 'Area',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an area';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _truckNumberController,
                        decoration: InputDecoration(
                          labelText: 'Truck Number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a truck number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 80), // space for the buttons
                    ],
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 40), // Increased bottom padding
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        backgroundColor: Colors.green,
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _deleteDriver,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        backgroundColor: Colors.red,
                      ),
                      child: const Text(
                        'Delete Driver',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
