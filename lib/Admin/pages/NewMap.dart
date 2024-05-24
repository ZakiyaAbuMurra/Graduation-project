import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchBinLocations();
  }


  @override
  Widget build(BuildContext context) {
 
    return Scaffold(
      body: Container(
        child: ListView.builder(
          itemCount: _binLocations.length,
          itemBuilder: (BuildContext context, int index) {
            final location = _binLocations[index];
            return ListTile(
              title: FutureBuilder(
                future: _getAddress(location.geoPoint.latitude, location.geoPoint.longitude),
                builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text('Loading...');
                  } else {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return Text(snapshot.data ?? 'No address found');
                    }
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }
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



