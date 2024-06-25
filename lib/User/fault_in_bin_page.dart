import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recyclear/utils/app_colors.dart';

class FaultInBinPage extends StatefulWidget {
  const FaultInBinPage({super.key});

  @override
  _FaultInBinPageState createState() => _FaultInBinPageState();
}

class _FaultInBinPageState extends State<FaultInBinPage> {
  final _formKey = GlobalKey<FormState>();
  final _neighborhoodNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _problemDescriptionController = TextEditingController();
  final _countryController = TextEditingController();

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
      if (_countryController.text.isEmpty ||
          _neighborhoodNameController.text.isEmpty ||
          _phoneNumberController.text.isEmpty ||
          _problemDescriptionController.text.isEmpty) {
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

      FirebaseFirestore.instance.collection('fault_in_bin').add({
        'Country name': _countryController.text,
        'Neighborhood name': _neighborhoodNameController.text,
        'Contact phone Number': _phoneNumberController.text,
        'Problem description': _problemDescriptionController.text,
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
                  'Fault in a bin',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16.0),
                _buildCountryDropdown(),
                const SizedBox(height: 16.0),
                _buildTextField(
                  controller: _neighborhoodNameController,
                  hintText: 'Enter the neighborhood name',
                  fieldName: 'Neighborhood Name',
                  border: const OutlineInputBorder(),
                  iconData: Icons.location_city,
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
                    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                  iconData: Icons.phone,
                ),
                const SizedBox(height: 16.0),
                _buildTextField(
                  controller: _problemDescriptionController,
                  hintText: 'Please describe the issue...',
                  fieldName: 'Problem Description',
                  border: const OutlineInputBorder(),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  iconData: Icons.description,
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
    required IconData iconData,
    TextInputType? keyboardType,
    int? maxLines,
    String? Function(String?)? validator,
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
              if (value == null || value.isEmpty) {
                return ' $hintText';
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
