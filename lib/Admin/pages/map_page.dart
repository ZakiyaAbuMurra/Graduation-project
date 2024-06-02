import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

import 'package:recyclear/models/bin_model.dart'; // Add this line

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  List<DocumentSnapshot<Map<String, dynamic>>> binInfo = [];
  final List<Marker> _markers = [];
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.reference().child('sensors/data');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _date = '';
  double _fillLevel = 0;
  double _humidity = 0.0;
  double _temperature = 0.0;
  String _time = '';
  int _binId = -1;

  StreamSubscription<DatabaseEvent>? _databaseSubscription;

  Future<void> fetchBinLocations() async {
    try {
      // Fetch the bin data from Firestore
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance.collection('bins').get();

      // Save the documents to the list and create markers
      setState(() {
        binInfo = querySnapshot.docs;
        for (var bin in binInfo) {
          GeoPoint geoPoint = bin.data()?['location'];
          _markers.add(
            Marker(
              markerId: MarkerId(bin.id),
              position: LatLng(geoPoint.latitude, geoPoint.longitude),
              infoWindow: InfoWindow(
                title: 'Bin ID: ${bin.data()?['binID']}',
                snippet: 'Status: ${bin.data()?['status']}',
              ),
            ),
          );
        }
      });
    } catch (e) {
      print('Error fetching bin locations: $e');
    }
  }

  Future<void> updateFirestoreData() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('bins')
          .where('binID', isEqualTo: _binId)
          .get();
          print(snapshot.docs.first.data());

      if (snapshot.docs.isNotEmpty) {
        DocumentReference docRef = snapshot.docs.first.reference;
        await docRef.update({
          'date': _date,
          'fill-level': _fillLevel,
          'Humidity': _humidity,
          'temp': _temperature,
          'time': _time,
        });
        print('Firestore document updated successfully.');
      } else {
        print('No document found with binId: $_binId');
      }
    } catch (e) {
      print('Error updating Firestore document: $e');
    }
  }

  Future<void> addDataToHistory() async {
    try {
      await _firestore.collection('binsHistory').add({
        'binId': _binId,
        //'date': _date,
        'fill-level': _fillLevel,
        'humidity': _humidity,
        'temperature': _temperature,
        //'time': _time,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print("/////////////////////////////////");
      print('Data added to history successfully.');
    } catch (e) {
      print("/////////////////////////////////");
      print('Error adding data to history: $e');
    }
  }

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(31.9014, 35.1999),
    zoom: 8,
  );

  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  void initState() {
    super.initState();
    fetchBinLocations();

    _databaseSubscription = _databaseReference.onValue.listen((event) {
      try {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        if (data != null) {
          print("//////////////////////////////");
          print("Data received:");
          print("Bin ID: ${data['binId']}");
          print("Date: ${data['date']}");
          print("Fill Level: ${data['fill-level']}");
          print("Humidity: ${data['humidity']}");
          print("Temperature: ${data['temperature']}");
          print("Time: ${data['time']}");

          if (mounted) {
            setState(() {
              _binId = data['binId'];
              _date = data['date'];
              _fillLevel = data['fill-level']is int ? (data['fill-level'] as int).toDouble() : data['fill-level'];
              _humidity = data['humidity'] is int ? (data['humidity'] as int).toDouble() : data['humidity'];
              _temperature = data['temperature'] is int ? (data['temperature'] as int).toDouble() : data['temperature'];
              _time = data['time'];
            });
          }

          // updateFirestoreData();
          addDataToHistory();
        } else {
          print('Received null data from Firebase Realtime Database.');
        }
      } catch (e) {
        print('Error handling data from Firebase Realtime Database: $e');
      }
    });
  }

  @override
  void dispose() {
    _databaseSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: _kGooglePlex,
        markers: Set<Marker>.of(_markers),
        myLocationEnabled: false,
        mapType: MapType.normal,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }
}
