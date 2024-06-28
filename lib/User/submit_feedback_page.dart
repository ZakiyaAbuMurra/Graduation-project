import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recyclear/utils/app_colors.dart';
import 'package:reviews_slider/reviews_slider.dart';

class SubmitFeedbackPage extends StatefulWidget {
  const SubmitFeedbackPage({super.key});

  @override
  _SubmitFeedbackPageState createState() => _SubmitFeedbackPageState();
}

class _SubmitFeedbackPageState extends State<SubmitFeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackDescriptionController = TextEditingController();
  bool isAnonymous = false;
  String selectedEmoji = '';
  User? get currentUser => FirebaseAuth.instance.currentUser;

  void _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      if (_feedbackDescriptionController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill the required field'),
            backgroundColor: AppColors.red,
          ),
        );
        return;
      }

      final feedbackData = {
        'feedback_description': _feedbackDescriptionController.text,
        'timestamp': DateTime.now(),
        'selected_emoji': selectedEmoji,
      };

      if (!isAnonymous && currentUser != null) {
        String userName = 'Anonymous';
        String userEmail = currentUser!.email ?? 'anonymous@example.com';

        // Fetch the custom name field from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .get();

        if (userDoc.exists) {
          userName = userDoc.get('name') ?? 'Anonymous';
        }

        print("User Name: $userName");
        print("User Email: $userEmail");

        feedbackData['name'] = userName;
        feedbackData['email'] = userEmail;
      }

      FirebaseFirestore.instance.collection('users_feedback').add(feedbackData);

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
                  'Submit Feedback',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16.0),
                _buildTextField(
                  controller: _feedbackDescriptionController,
                  hintText: 'Please give us your feedback',
                  fieldName: 'Feedback Description',
                  border: const OutlineInputBorder(),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  iconData: Icons.feedback,
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
                  child: Column(
                    children: [
                      const SizedBox(height: 8.0),
                      const Text(
                        'How do you rate our App?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Center(
                        child: ReviewSlider(
                          initialValue: 4,
                          options: const [
                            'Terrible',
                            'Bad',
                            'Okay',
                            'Good',
                            'Great'
                          ],
                          onChange: (int value) {
                            setState(() {
                              selectedEmoji =
                                  ['😡', '😟', '😐', '😊', '😃'][value];
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: _submitRequest,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: AppColors.white,
                        backgroundColor: AppColors.primary,
                        elevation: 8,
                        shadowColor: AppColors.grey,
                      ),
                      child: const Text('Send Feedback'),
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: isAnonymous,
                          onChanged: (bool? value) {
                            setState(() {
                              isAnonymous = value ?? false;
                            });
                          },
                        ),
                        const Text('Send Anonymously'),
                      ],
                    ),
                  ],
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
}
