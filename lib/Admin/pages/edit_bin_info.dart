import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BinDetailsPage extends StatefulWidget {
  final String binId;

  BinDetailsPage({required this.binId});

  @override
  _BinDetailsPageState createState() => _BinDetailsPageState();
}

class _BinDetailsPageState extends State<BinDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  late DocumentSnapshot binData;
  late TextEditingController _binIDController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  late TextEditingController _colorController;
  late TextEditingController _heightController;
  late TextEditingController _widthController;
  late TextEditingController _materialController;
  late TextEditingController _notifyHumidityController;
  late TextEditingController _notifyTemperatureController;
  late TextEditingController _notifyLevelController;
  late TextEditingController _assignToController;
  late String status;
  bool _isLoading = true;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _fetchBinData();
  }

  Future<void> _fetchBinData() async {
    binData = await FirebaseFirestore.instance
        .collection('bins')
        .doc(widget.binId)
        .get();
    _initializeControllers();
    setState(() {
      _isLoading = false;
    });
  }

  void _initializeControllers() {
    _binIDController = TextEditingController(text: binData['binID'].toString());
    _latitudeController =
        TextEditingController(text: binData['location'].latitude.toString());
    _longitudeController =
        TextEditingController(text: binData['location'].longitude.toString());
    _colorController = TextEditingController(text: binData['color']);
    _heightController =
        TextEditingController(text: binData['Height'].toString());
    _widthController = TextEditingController(text: binData['Width'].toString());
    _materialController = TextEditingController(text: binData['Material']);
    _notifyHumidityController =
        TextEditingController(text: binData['notifiyHumidity'].toString());
    _notifyTemperatureController =
        TextEditingController(text: binData['notifiyTemperature'].toString());
    _notifyLevelController =
        TextEditingController(text: binData['notifyLevel'].toString());
    _assignToController = TextEditingController(text: binData['assignTo']);
    status = binData['status'];
  }

  Future<void> _updateBin() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance
            .collection('bins')
            .doc(widget.binId)
            .update({
          'binID': int.parse(_binIDController.text),
          'location': GeoPoint(
            double.parse(_latitudeController.text),
            double.parse(_longitudeController.text),
          ),
          'color': _colorController.text,
          'Height': double.parse(_heightController.text),
          'Width': double.parse(_widthController.text),
          'Material': _materialController.text,
          'notifiyHumidity': double.parse(_notifyHumidityController.text),
          'notifiyTemperature': double.parse(_notifyTemperatureController.text),
          'notifyLevel': double.parse(_notifyLevelController.text),
          'assignTo': _assignToController.text,
          'status': status,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bin updated successfully!')),
        );
        setState(() {
          _isEditing = false;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update bin.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bin Details'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _updateBin();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    if (constraints.maxWidth > 600) {
                      // Web layout
                      return Column(
                        children: [
                          Expanded(
                            child: GridView.count(
                              crossAxisCount: 3,
                              childAspectRatio: 3,
                              crossAxisSpacing: 5,
                              mainAxisSpacing: 4,
                              children: [
                                _buildCard('Bin ID', _binIDController,
                                    Icons.delete, TextInputType.number),
                                _buildCard(
                                    'Latitude',
                                    _latitudeController,
                                    Icons.location_on,
                                   const TextInputType.numberWithOptions(
                                        decimal: true)),
                                _buildCard(
                                    'Longitude',
                                    _longitudeController,
                                    Icons.location_on,
                                   const TextInputType.numberWithOptions(
                                        decimal: true)),
                                _buildCard('Color', _colorController,
                                    Icons.color_lens),
                                _buildCard(
                                    'Height',
                                    _heightController,
                                    Icons.height,
                                   const TextInputType.numberWithOptions(
                                        decimal: true)),
                                _buildCard(
                                    'Width',
                                    _widthController,
                                    Icons.straighten,
                                    const TextInputType.numberWithOptions(
                                        decimal: true)),
                                _buildCard('Material', _materialController,
                                    Icons.category),
                                _buildCard(
                                    'Notify Humidity',
                                    _notifyHumidityController,
                                    Icons.water_drop,
                                   const  TextInputType.numberWithOptions(
                                        decimal: true),
                                    false),
                                _buildCard(
                                    'Notify Temperature',
                                    _notifyTemperatureController,
                                    Icons.thermostat,
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                    false),
                                _buildCard(
                                    'Notify Level',
                                    _notifyLevelController,
                                    Icons.bar_chart,
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                    false),
                                _buildCard('Assign To', _assignToController,
                                    Icons.person),
                              ],
                            ),
                          ),
                        ],
                      );
                    } else {
                      // Mobile layout
                      return Column(
                        children: [
                          Expanded(
                            child: ListView(
                              children: [
                                _buildCard('Bin ID', _binIDController,
                                    Icons.delete, TextInputType.number),
                                _buildCard(
                                    'Latitude',
                                    _latitudeController,
                                    Icons.location_on,
                                    const TextInputType.numberWithOptions(
                                        decimal: true)),
                                _buildCard(
                                    'Longitude',
                                    _longitudeController,
                                    Icons.location_on,
                                    const TextInputType.numberWithOptions(
                                        decimal: true)),
                                _buildCard('Color', _colorController,
                                    Icons.color_lens),
                                _buildCard(
                                    'Height',
                                    _heightController,
                                    Icons.height,
                                    const TextInputType.numberWithOptions(
                                        decimal: true)),
                                _buildCard(
                                    'Width',
                                    _widthController,
                                    Icons.straighten,
                                    const TextInputType.numberWithOptions(
                                        decimal: true)),
                                _buildCard('Material', _materialController,
                                    Icons.category),
                                _buildCard(
                                    'Notify Humidity',
                                    _notifyHumidityController,
                                    Icons.water_drop,
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                    false),
                                _buildCard(
                                    'Notify Temperature',
                                    _notifyTemperatureController,
                                    Icons.thermostat,
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                    false),
                                _buildCard(
                                    'Notify Level',
                                    _notifyLevelController,
                                    Icons.bar_chart,
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                    false),
                                _buildCard('Assign To', _assignToController,
                                    Icons.person),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
            ),
    );
  }

  Widget _buildCard(
      String label, TextEditingController controller, IconData icon,
      [TextInputType? keyboardType, bool isEditable = true]) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Center(
          child: TextFormField(
            controller: controller,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(color: Colors.black), // Label color
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              filled: true,
              fillColor:
                  _isEditing && isEditable ? Colors.white : Colors.grey[200],
            ),
            style:const TextStyle(
                color: Colors.black), // Text color inside the TextFormField
            keyboardType: keyboardType,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter $label';
              }
              return null;
            },
            enabled: _isEditing && isEditable,
          ),
        ),
      ),
    );
  }
}
