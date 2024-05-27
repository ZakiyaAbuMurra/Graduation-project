import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recyclear/utils/app_colors.dart';

class CouponsProblemPage extends StatefulWidget {
  const CouponsProblemPage({super.key});

  @override
  _CouponsProblemPageState createState() => _CouponsProblemPageState();
}

class _CouponsProblemPageState extends State<CouponsProblemPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneNumberController = TextEditingController();
  final _problemDescriptionController = TextEditingController();

  void _submitRequest() {
    if (_formKey.currentState!.validate()) {
      // Check if any of the text controllers are empty
      if (_phoneNumberController.text.isEmpty ||
          _problemDescriptionController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill all the required fields'),
            backgroundColor: AppColors.red,
          ),
        );
        return;
      }

      FirebaseFirestore.instance.collection('coupons_problem').add({
        'Contact phone Number': _phoneNumberController.text,
        'Problem description': _problemDescriptionController.text,
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
        //backgroundColor: Colors.transparent,
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
                  'Coupons Problem',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
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
                ),
                const SizedBox(height: 16.0),
                _buildTextField(
                  controller: _problemDescriptionController,
                  hintText: 'Please describe the issue...',
                  fieldName: 'Problem Description',
                  border: const OutlineInputBorder(),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                ),
                const SizedBox(height: 16.0),
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
              hintStyle:
                  const TextStyle(color: AppColors.grey), // Hint text style
              border: border,
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
              ),
              filled: true,
              fillColor: AppColors.white,
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
}
