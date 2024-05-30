import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recyclear/cubits/auth_cubit/auth_cubit.dart';
import 'package:recyclear/utils/app_colors.dart';
import 'package:recyclear/utils/route/app_routes.dart';
import 'package:recyclear/views/widgets/main_button.dart';

class AddBinForm extends StatefulWidget {
  const AddBinForm({super.key});

  @override
  State<AddBinForm> createState() => _AddBinFormState();
}

class _AddBinFormState extends State<AddBinForm> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _colorController = TextEditingController();
  final _heightController = TextEditingController();
  final _widthController = TextEditingController();
  final _typeController = TextEditingController();
  final _humidityController = TextEditingController();
  final _tempController = TextEditingController();
  final _levelController = TextEditingController();
  final _assignController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _getBinId();
  }
  bool _isVisible = false;
  bool _isVisible_con = false;

  bool isLogin = true;

 Future <int> fetchBinId()async{
   final querySnapshot = await FirebaseFirestore.instance
      .collection('bins')
      .orderBy('binID', descending: true)
      .limit(1)
      .get();
   if (querySnapshot.docs.isNotEmpty) {
    return querySnapshot.docs.first['binID'];
  } else {
    return -1;
  }
 }

  Future<void> _getBinId() async {
    int highestBinId = await fetchBinId();
    _idController.text = (highestBinId + 1).toString();
  }

  Future<void> _addNewBin() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('bins').add({
          'binID': int.parse(_idController.text),
          'location': GeoPoint(
            double.parse(_latitudeController.text),
            double.parse(_longitudeController.text),
          ),
          'color': _colorController.text,
          'Height': double.parse(_heightController.text),
          'Humidity': 0,
          'fill-level':0,
          'temp':0,
          'pickDate': Timestamp.now(),
          'Width': double.parse(_widthController.text),
          'Material': _typeController.text,
          'notifiyHumidity': double.parse(_humidityController.text),
          'notifiyTemperature': double.parse(_tempController.text),
          'notifyLevel': double.parse(_levelController.text),
          'assignTo': _assignController.text,
          'status':'empty',
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('New bin added successfully!')),
        );
        // Clear the form
        _latitudeController.clear();
        _longitudeController.clear();
        _colorController.clear();
        _heightController.clear();
        _widthController.clear();
        _typeController.clear();
        _humidityController.clear();
        _tempController.clear();
        _levelController.clear();
        _assignController.clear();
        _getBinId(); // Update the bin ID for the next entry
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add new bin please Fill all bin Information')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bin ID',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            readOnly: true,
            controller: _idController,
            decoration: InputDecoration(
             
              hintText: _idController.text,
              hintStyle: const TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.bold
              ),
              filled: true, // Add a fill color
              fillColor: Colors.grey[200], // Light grey fill color
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0), // Rounded corners
                borderSide: BorderSide.none, // No border
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0), // Padding inside the text field
            ),
            style: const TextStyle(
              fontSize: 16.0, // Slightly larger font size
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bin Latitude',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _latitudeController,
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.location_on, // Example icon
                color: Colors.grey, // Icon color
              ),
              hintText: 'Enter the Latitude',
              filled: true, // Add a fill color
              fillColor: Colors.grey[200], // Light grey fill color
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0), // Rounded corners
                borderSide: BorderSide.none, // No border
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0), // Padding inside the text field
            ),
            style: const TextStyle(
              fontSize: 16.0, // Slightly larger font size
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bin Longitude',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _longitudeController,
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.location_on, // Example icon
                color: Colors.grey, // Icon color
              ),
              hintText: 'Enter the Longitude',
              contentPadding: EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 12.0), // Padding inside the text field
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                    8.0), // Rounded corners for the input field
              ),
              fillColor: Colors.grey[200], // A subtle fill color
              filled: true, // Enable the fill color
              
            ),
          ),
           
          const SizedBox(height: 8),
          Text(
            'Bin Color',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _colorController,
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.color_lens, // Example icon
                color: Colors.grey, // Icon color
              ),
              hintText: 'Enter the Bin Color',
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 12.0), // Padding inside the text field
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                    8.0), // Rounded corners for the input field
              ),
              fillColor: Colors.grey[200], // A subtle fill color
              filled: true,
              
            ),
           
          ),
          const SizedBox(height: 8),
          Text(
            'Bin Height',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _heightController,
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.height, // Example icon
                color: Colors.grey, // Icon color
              ),
              hintText: 'Enter Bin Heghit',
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 12.0), // Padding inside the text field
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                    8.0), // Rounded corners for the input field
              ),
              fillColor: Colors.grey[200], // A subtle fill color
              filled: true,
            ),
          ),
           const SizedBox(height: 8),
          Text(
            'Bin Width',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
           TextFormField(
            controller: _widthController,
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.horizontal_rule, // Example icon
                color: Colors.grey, // Icon color
              ),
        
              hintText: 'Enter Bin Width',
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 12.0), // Padding inside the text field
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                    8.0), // Rounded corners for the input field
              ),
              fillColor: Colors.grey[200], // A subtle fill color
              filled: true,
            ),
          ),

           const SizedBox(height: 8),
          Text(
            'Waste Type',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _typeController,
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.recycling, // Example icon
                color: Colors.grey, // Icon color
              ),
              hintText: 'Enter Waste Type',
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 12.0), // Padding inside the text field
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                    8.0), // Rounded corners for the input field
              ),
              fillColor: Colors.grey[200], // A subtle fill color
              filled: true,
            ),
          ),

           const SizedBox(height: 8),
          Text(
            'Max Humidity',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _humidityController,
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.water_drop, // Example icon
                color: Colors.grey, // Icon color
              ),
              hintText: 'Enter the Maximum Humidity Value',
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 12.0), // Padding inside the text field
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                    8.0), // Rounded corners for the input field
              ),
              fillColor: Colors.grey[200], // A subtle fill color
              filled: true,
            ),
          ),
           const SizedBox(height: 8),
          Text(
            'Max Temperature',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _tempController,
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.sunny, // Example icon
                color: Colors.grey, // Icon color
              ),
              hintText: 'Enter the Maximum Temperature Value',
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 12.0), // Padding inside the text field
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                    8.0), // Rounded corners for the input field
              ),
              fillColor: Colors.grey[200], // A subtle fill color
              filled: true,
            ),
          ),
           const SizedBox(height: 8),
          Text(
            'Max Fill-Level',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _levelController,
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.height, // Example icon
                color: Colors.grey, // Icon color
              ),
              hintText: 'Enter the Maximum Fill-level Value',
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 12.0), // Padding inside the text field
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                    8.0), // Rounded corners for the input field
              ),
              fillColor: Colors.grey[200], // A subtle fill color
              filled: true,
            ),
          ),

           const SizedBox(height: 8),
          Text(
            'Assignd To',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _assignController,
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.person_2, // Example icon
                color: Colors.grey, // Icon color
              ),
              hintText: 'Enter the Driver Name',
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 12.0), // Padding inside the text field
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                    8.0), // Rounded corners for the input field
              ),
              fillColor: Colors.grey[200], // A subtle fill color
              filled: true,
            ),
          ),

          
          const SizedBox(height: 15),

          MainButton(
            onPressed: _addNewBin,
            title: "Add New Bin",
          ),


          
          
        ],
      ),
    );
  }


}
