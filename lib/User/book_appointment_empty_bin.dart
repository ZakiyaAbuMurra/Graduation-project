import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:recyclear/utils/app_colors.dart';

class BookAppointmentPage extends StatefulWidget {
  const BookAppointmentPage({super.key});

  @override
  _BookAppointmentPageState createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _binNumberController = TextEditingController();
  final _binLocationController = TextEditingController();
  final _countryController = TextEditingController();

  User? get currentUser => FirebaseAuth.instance.currentUser;

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

  void _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      // Check if any of the text controllers are empty
      if (_countryController.text.isEmpty ||
          _descriptionController.text.isEmpty ||
          _dateController.text.isEmpty ||
          _timeController.text.isEmpty ||
          _binNumberController.text.isEmpty ||
          _binLocationController.text.isEmpty) {
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

      FirebaseFirestore.instance.collection('bin_empty_requests').add({
        'description': _descriptionController.text,
        'date': _dateController.text,
        'time': _timeController.text,
        'bin number': _binNumberController.text,
        'bin location': _binLocationController.text,
        'user_id': FirebaseAuth.instance.currentUser!.uid,
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _timeController.text = picked.format(context);
      });
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
                  'Book an Appointment',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 8.0),
                const Text(
                  'Notify us to empty your bin',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16.0),
                _buildTextField(
                  controller: _descriptionController,
                  hintText: 'Please describe the issue...',
                  fieldName: 'Description',
                  border: const OutlineInputBorder(),
                  iconData: Icons.description,
                ),
                const SizedBox(height: 16.0),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: _buildTextField(
                      controller: _dateController,
                      hintText: 'Select a date',
                      fieldName: 'Date',
                      border: const OutlineInputBorder(),
                      iconData: Icons.date_range_outlined,
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                GestureDetector(
                  onTap: () => _selectTime(context),
                  child: AbsorbPointer(
                    child: _buildTextField(
                      controller: _timeController,
                      hintText: 'Select a time',
                      fieldName: 'Time',
                      border: const OutlineInputBorder(),
                      iconData: Icons.access_time,
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                _buildTextField(
                  controller: _binNumberController,
                  hintText: 'Please type the bin number',
                  fieldName: 'Bin Number',
                  border: const OutlineInputBorder(),
                  iconData: Icons.numbers,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 3,
                ),
                const SizedBox(height: 16.0),
                _buildCountryDropdown(),
                const SizedBox(height: 16.0),
                _buildTextField(
                  controller: _binLocationController,
                  hintText: 'Please type the bin location',
                  fieldName: 'Bin Location',
                  border: const OutlineInputBorder(),
                  iconData: Icons.location_on,
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
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
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
              counterText: '',
              prefixIcon: Icon(iconData),
            ),
            keyboardType: keyboardType,
            maxLength: maxLength,
            inputFormatters: inputFormatters,
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
