import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:recyclear/services/location_controller.dart';
import 'package:recyclear/sharedPreferences.dart';
import 'package:recyclear/utils/app_colors.dart';
import 'package:image_picker/image_picker.dart';

class NewMap extends StatefulWidget {
  const NewMap({super.key});

  @override
  State<NewMap> createState() => _NewMapState();
}

class _NewMapState extends State<NewMap> {
  //final PopupController _popupController = PopupController();
  late List<BinLocation> _binLocations=[];
  bool locationEnabled = true;
  double locationLongitude = 0.0;
  double locationLatitude = 0.0;

  final LocationController location = Get.put<LocationController>(LocationController());
    User? user = FirebaseAuth.instance.currentUser;

Future<void> _fetchBinLocations() async {
  List<BinLocation> binLocations = [];

  try {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('bins').get();

    snapshot.docs.forEach((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      binLocations.add(BinLocation.fromMap(data));
    });
  } catch (e) {
    print('Error fetching bin locations: $e');
  }

  setState(() {
    _binLocations = binLocations;
  });
}

 Future<String> _getAddress(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks != null && placemarks.isNotEmpty) {
        return placemarks[0].name ?? '';
      } else {
        return 'No address found';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

    Future<void> _saveUserLocation() async {
    if (user != null) {
      try {
        GeoPoint geoPoint = GeoPoint(location.userLocation.value?.latitude ?? 0.0, location.userLocation.value?.longitude ?? 0.0);

        await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
          'location': geoPoint,
        }, SetOptions(merge: true));

        print("///////////////////////////");

        print('User location saved successfully');
      } catch (e) {
                print("///////////////////////////");

        print('Error saving user location: $e');
      }
    } else {
              print("///////////////////////////");

      print('No user logged in');
    }
  }

  
Future<void> _getUserLocation() async {
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
        if (userDoc.exists) {
          GeoPoint geoPoint = userDoc['location'];
          setState(() {
            locationLatitude = geoPoint.latitude;
            locationLongitude = geoPoint.longitude;
          });
          print('User location: (${geoPoint.latitude}, ${geoPoint.longitude})');
        } else {
          print('User document does not exist');
        }
      } catch (e) {
        print('Error fetching user location: $e');
      }
    } else {
      print('No user logged in');
    }
  }


  @override
  void initState() {
    super.initState();

    // locationEnabled = sharedPreferences.getLocationStatus()!;
    // locationLatitude = sharedPreferences.getLatitude()!;
    // locationLongitude = sharedPreferences.getLongitude()!;
    _fetchBinLocations();
   //_saveUserLocation();
    _getUserLocation();
   
  }


  @override
  Widget build(BuildContext context) {
 
    return Scaffold(
      body: Container(
        
        child: Center(
          child: content()
        ),
      
      ),
    );
  }

  

  Widget content() {
    return  FlutterMap(options: const MapOptions(

    ) , children: [
      openStreetMapTileLayer,
      MarkerLayer(markers: [
      Marker(point:  LatLng(locationLatitude,locationLongitude),
      height: 50,
      width: 50,
      alignment: Alignment.centerLeft,
       child: const Icon(Icons.location_pin,size: 60,color: AppColors.red,))

      ])


    ]);

  }
  TileLayer get openStreetMapTileLayer => TileLayer(
        urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
        userAgentPackageName: 'com.example.app',
);


}

class BinLocation {
  final GeoPoint geoPoint;

  BinLocation({required this.geoPoint});

  factory BinLocation.fromMap(Map<String, dynamic> data) {
    return BinLocation(
      geoPoint: data['location'],
    );
  }
}



