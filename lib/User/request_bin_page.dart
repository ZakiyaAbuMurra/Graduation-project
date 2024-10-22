import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recyclear/utils/app_colors.dart';

class RequestBinPage extends StatefulWidget {
  const RequestBinPage({super.key});

  @override
  _RequestBinPageState createState() => _RequestBinPageState();
}

class _RequestBinPageState extends State<RequestBinPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _countryController = TextEditingController();
  final _commentsController = TextEditingController();

  List<String> palestineCountries = [
    'Jerusalem',
    'Hebron',
    'Ramallah',
    'Birzeit',
    'Nablus',
    'Bethlehem',
    'Jenin',
    'Tulkarm',
    'Qalqilya',
    'Salfit',
    'Tubas',
    'Jericho',
    'Gaza',
    'Rafah',
    'Khan Younis',
    'Deir al-Balah',
    'Beit Lahia',
    'Jabalia'
  ];

  User? get currentUser => FirebaseAuth.instance.currentUser;

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      // Check if any of the text controllers are empty
      if (_nameController.text.isEmpty ||
          _phoneNumberController.text.isEmpty ||
          _emailController.text.isEmpty ||
          _addressController.text.isEmpty ||
          _countryController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill all the required fields'),
            backgroundColor: AppColors.red,
          ),
        );
        return;
      }

      String userName = 'Anonymous';
      String userEmail = currentUser?.email ?? 'anonymous@example.com';

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      if (userDoc.exists) {
        userName = userDoc.get('name') ?? 'Anonymous';
      }

      FirebaseFirestore.instance.collection('bin_requests').add({
        'name': _nameController.text,
        'phoneNumber': _phoneNumberController.text,
        'email': _emailController.text,
        'address': _addressController.text,
        'country': _countryController.text,
        'comments': _commentsController.text,
        'User name': userName,
        'User email': userEmail,
        'timestamp': DateTime.now(),
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: MediaQuery.of(context).size.width * 0.4,
                    child: Image.asset(
                      'assets/images/success_image.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                const Text(
                  '      Request Sent Successfully',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8.0),
                const Text(
                  'We will reply to you as soon as possible.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8.0),
                const Text(
                  '       Thank you for contacting us!',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Return to previous page
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: AppColors.white,
                  backgroundColor: AppColors.primary,
                  elevation: 8,
                  shadowColor: AppColors.grey,
                ),
                child: const Text(
                  'Got it',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/greenRecyclear.png',
          height: 40,
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Send a message to the support center',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 8.0),
                const Text(
                  'Request to have a bin',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16.0),
                _buildTextField(
                  controller: _nameController,
                  hintText: 'Enter your full name',
                  fieldName: 'Full Name',
                  border: const OutlineInputBorder(),
                  iconData: Icons.person,
                ),
                const SizedBox(height: 16.0),
                _buildTextField(
                  controller: _phoneNumberController,
                  hintText: 'Enter your phone number',
                  fieldName: 'Contact Phone Number',
                  border: const OutlineInputBorder(),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    // Check if the entered value contains only numbers
                    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                  iconData: Icons.phone,
                ),
                const SizedBox(height: 16.0),
                _buildTextField(
                  controller: _emailController,
                  hintText: 'Enter your Email',
                  fieldName: 'Email Address',
                  border: const OutlineInputBorder(),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your email address';
                    }
                    // Check if the entered value is a valid email address
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                  iconData: Icons.email,
                ),
                const SizedBox(height: 16.0),
                _buildCountryDropdown(),
                const SizedBox(height: 16.0),
                _buildTextField(
                  controller: _addressController,
                  hintText: 'Enter your address',
                  fieldName: 'Address',
                  border: const OutlineInputBorder(),
                  iconData: Icons.location_on,
                ),
                const SizedBox(height: 16.0),
                _buildTextField(
                  controller: _commentsController,
                  hintText: 'Additional Comments',
                  fieldName: 'Comments',
                  border: const OutlineInputBorder(),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  iconData: Icons.comment,
                  optional: true,
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _submitRequest,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: AppColors.white,
                    backgroundColor: AppColors.primary,
                    elevation: 8,
                    shadowColor: AppColors.grey,
                  ),
                  child: const Text(
                    'Send Request',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required String fieldName,
    required OutlineInputBorder border,
    TextInputType? keyboardType,
    int? maxLines,
    String? Function(String?)? validator,
    required IconData iconData,
    bool optional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              fieldName,
              style: const TextStyle(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (!optional)
              const Text(
                ' *',
                style: TextStyle(
                  color: AppColors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8.0),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: AppColors.grey.withOpacity(0.9),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: AppColors.grey),
              border: border,
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
              ),
              filled: true,
              fillColor: AppColors.white,
              prefixIcon: Icon(iconData),
            ),
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: (value) {
              if (!optional && (value == null || value.isEmpty)) {
                return hintText;
              }
              return validator != null ? validator(value) : null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCountryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'Country',
              style: TextStyle(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              ' *',
              style: TextStyle(
                color: AppColors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: AppColors.grey.withOpacity(0.9),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: _countryController.text.isNotEmpty
                ? _countryController.text
                : null,
            icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
            iconSize: 24,
            elevation: 16,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
              filled: true,
              fillColor: AppColors.white,
            ),
            onChanged: (String? newValue) {
              setState(() {
                _countryController.text = newValue!;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select your country';
              }
              return null;
            },
            items: palestineCountries
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
