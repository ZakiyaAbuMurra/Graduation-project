import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:recyclear/services/firestore_services.dart';
import 'package:recyclear/services/notification_service.dart';

class MapServices {
    static FirebaseFirestore _firestore = FirebaseFirestore.instance;

  
    static Future<void> initApp(String area) async {
    // Initialize notification service
    print('========================================== initApp ${area}');
    await NotificationService().initializeNotification();
    debugPrint('Before the start Monitoring Bin');
    // Start monitoring bin heights
    await FirestoreService.instance.monitorBinHeightAndNotify(area);
    debugPrint('After the start Monitoring Bin');

    
  }

    static Future<Map<String, String?>> getUserType() async {
    try {
      // Get current user
       User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('No user signed in');
        return {};
      }

      // Get user document from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        String? type = userDoc['type'];
        String? driverArea;
        if (type != null && type.toLowerCase() == 'driver') {
          driverArea = userDoc['area'];
        }
        return {'type': type, 'driverArea': driverArea};
      } else {
        print('User document does not exist');
        return {};
      }
    } catch (e) {
      print('Error fetching user type: $e');
      return {};
    }
  }


  static Future<Map<String, dynamic>?> getNotifiedData(int binID) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('bins')
          .where('binID', isEqualTo: binID)
          .get();

      if (snapshot.docs.isNotEmpty) {
        Map<String, dynamic> binData = snapshot.docs.first.data() as Map<String, dynamic>;
        return binData;
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting data: $e');
      return null;
    }
  }

  static latlong.LatLng convertGeoPointToLatLng(GeoPoint geoPoint) {
    return latlong.LatLng(geoPoint.latitude, geoPoint.longitude);
  }

  


  static Future<void> saveRoutesLocation(int binID, GeoPoint location, String area, String type) async {
    try {
      await _firestore.collection('routeLocations').add({
        'binID': binID,
        'location': location,
        'area':area,
      });
    } catch (e) {
      print('Error saving notification: $e');
    }
  }

  static Future<void> deleteDocumentByBinId(int binId) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  CollectionReference collectionRef = firestore.collection('routeLocations');

  Query query = collectionRef.where('binID', isEqualTo: binId);

  QuerySnapshot querySnapshot = await query.get();
  for (QueryDocumentSnapshot doc in querySnapshot.docs) {
    await doc.reference.delete();
  }
  print("---------------------------------------- all docs deleted");
}


static Future<List<dynamic>?> getDocumentByUniqueKey() async {
  CollectionReference collectionRef = FirebaseFirestore.instance.collection('routeLocations');

  QuerySnapshot querySnapshot = await collectionRef.get();

  if (querySnapshot.docs.isNotEmpty) {
    var document = querySnapshot.docs;
    return document;

  } else {
    print('Document not found.');
    return null;
  }
}
  


}