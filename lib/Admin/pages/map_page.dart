import 'package:cloud_firestore/cloud_firestore.dart';
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

 Future<void> fetchBinLocations() async {
    try {
      // Fetch the bin data from Firestore
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance.collection('bins').get();

      // Save the documents to the list and create markers
      setState(() {
        binInfo = querySnapshot.docs;
        for (var bin in binInfo) {
          print('/////////////////////////////');
          print(bin.data());
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
      print('/////////////////////////////');

      print(_markers.length);

      });
    } catch (e) {
      print('Error fetching bin locations: $e');
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
  }


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: 
     GoogleMap(
      initialCameraPosition: _kGooglePlex,
       markers: Set<Marker>.of(_markers),
       onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },

      
    ));
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }
}