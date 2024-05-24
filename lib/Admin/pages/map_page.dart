
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:recyclear/utils/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class MapSample extends StatefulWidget {

  const MapSample();

  @override
  State<MapSample> createState() => _MapSampleState();
}

class _MapSampleState extends State<MapSample> {

  List<DocumentSnapshot<Map<String, dynamic>>> binInfo = [];
  bool _locationServiceEnabled = false;
  LocationPermission? _locationPermission;
  Position? _currentPosition;
  bool isDenied =false;


  /////////////////////////////////////////// Test Real Time, Firestore database part
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.reference().child('sensors/data');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _date = '';
  int _fillLevel = 0;
  double _humidity = 0.0;
  double _temperature = 0.0;
  String _time = '';
  int _binId = -1;





 
  
  void fetchSensorData() async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('bins').get();
    setState(() {
      binInfo = snapshot.docs;
    });

  }
  Future<DocumentSnapshot> getUserData() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    return doc;
  } else {
    throw Exception('No user signed in');
  }
}
 
    final _databaseRef = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    fetchSensorData();
    checkLocationPermission();
      _databaseReference.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      if (data != null) {
        setState(() {
          _date = data['date'] ?? '';
          _fillLevel = data['fill-level'] ?? 0;
          _humidity = (data['humidity'] ?? 0).toDouble();
          _temperature = (data['temperature'] ?? 0).toDouble();
          _time = data['time'] ?? '';
          _binId = data['binId'] ?? 0;
        });
        print('\\\\\\\\\\\\\\\\\\\\');
        print('Data retrieved: $_date, $_fillLevel, $_humidity, $_temperature, $_time');
        updateFirestoreData();
      } else {
        print('\\\\\\\\\\\\\\\\\\\\');

        print('No data found in the snapshot.');
      }
    }, onError: (error) {
      print('\\\\\\\\\\\\\\\\\\\\');

      print('Error: $error');
    });

    
   
  }

    Future<void> checkLocationPermission() async {
    _locationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!_locationServiceEnabled) {
      // Location services are not enabled, prompt the user to enable them.
      // You can use a dialog or navigate to a settings page for this.
      return;
    }

    _locationPermission = await Geolocator.checkPermission();
    if (_locationPermission == LocationPermission.denied) {
     
      _locationPermission = await Geolocator.requestPermission();
      if (_locationPermission != LocationPermission.whileInUse &&
          _locationPermission != LocationPermission.always) {
            
      
            print('variable 2');
            print(isDenied);
        return;
      }
    }

    // Permission granted, get the current position.
    _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    setState(() {
      isDenied = false;
    });
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


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Sensor Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: $_binId', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Date: $_date', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Fill Level: $_fillLevel', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Humidity: $_humidity', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Temperature: $_temperature', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Time: $_time', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }

  FutureBuilder<DocumentSnapshot<Object?>> userData() {
    return FutureBuilder<DocumentSnapshot>(
    future: getUserData(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const CircularProgressIndicator();
      } else if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      } else if (snapshot.hasData) {
        var userData = snapshot.data?.data() as Map<String, dynamic>;
        return SizedBox(
          child: content(binInfo,userData),
        );
      } else {
        return Text('No user data found');
      }
    },
  );
  }
 Widget content(List<DocumentSnapshot<Map<String, dynamic>>> bin,var userData) {
  return FlutterMap(
    options: MapOptions(
      initialCenter: LatLng(userData['locationLat'], userData['locationLon']),
    ),
    children: [
      openStreetMapTileLayer,
      MarkerLayer(markers: [
        // Marker(
        //   point:  LatLng(userData['locationLat'], userData['locationLon']),
        //   width: 60,
        //   height: 80,
        //   alignment: Alignment.center,
        //   child: IconButton(
        //     icon: const Icon(Icons.location_pin),
        //     onPressed: () {
        //       if (bin.isNotEmpty) {
        //         showDialog(
        //           context: context,
        //           builder: (BuildContext context) {
        //             return AlertDialog(
        //               title: SizedBox(
        //                 width: MediaQuery.of(context).size.width,
        //                 height: MediaQuery.of(context).size.height * 0.05,
        //                 child: Row(
        //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                   children: [
        //                     const Text(
        //                       "Bin Information",
        //                       style: TextStyle(
        //                         color: AppColors.lightBlack,
        //                         fontSize: 20,
        //                         fontWeight: FontWeight.bold,
        //                       ),
        //                     ),
        //                     IconButton(
        //                       onPressed: () {
        //                         Navigator.of(context).pop();
        //                       },
        //                       icon: const Icon(Icons.cancel),
        //                     )
        //                   ],
        //                 ),
        //               ),
        //               content: Column(
        //                 children: [
        //                   Row(
        //                     children: [
        //                       Image.asset(
        //                         'assets/images/binIcon.png',
        //                         height: MediaQuery.of(context).size.height * 0.15,
        //                         width: MediaQuery.of(context).size.width * 0.15,
        //                       ),
        //                       Padding(
        //                         padding: EdgeInsets.only(
        //                             left: MediaQuery.of(context).size.width * 0.03),
        //                         child: Column(
        //                           crossAxisAlignment: CrossAxisAlignment.start,
        //                           children: [
        //                             const Text(
        //                               'Location',
        //                               style: TextStyle(
        //                                 fontSize: 20,
        //                                 fontWeight: FontWeight.bold,
        //                                 color: AppColors.lightBlack,
        //                               ),
        //                             ),
        //                             Text(
        //                               bin.first.id, // Now safe to access
        //                               style: const TextStyle(
        //                                 fontSize: 14,
        //                                 fontWeight: FontWeight.bold,
        //                                 color: AppColors.grey,
        //                               ),
        //                             ),
        //                           ],
        //                         ),
        //                       ),
        //                     ],
        //                   ),
        //                   const Row(
        //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                     children: [
        //                     Text("Fill-Level", style: TextStyle(
        //                       fontWeight: FontWeight.bold,
        //                       color: AppColors.lightBlack,
        //                       fontSize: 18,
        //                     ),),
        //                     Text("Humidity", style: TextStyle(
        //                       fontWeight: FontWeight.bold,
        //                       color: AppColors.lightBlack,
        //                       fontSize: 18,
        //                     ),),

        //                   ],),
        //                          Row(
        //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                     children: [
        //                     Text(bin.first.get(0), style: const TextStyle(
        //                       fontWeight: FontWeight.bold,
        //                       color: AppColors.lightBlack,
        //                       fontSize: 18,
        //                     ),),
        //                     const Text("Humidity", style: TextStyle(
        //                       fontWeight: FontWeight.bold,
        //                       color: AppColors.lightBlack,
        //                       fontSize: 18,
        //                     ),),

        //                   ],),
        //                 ],
        //               ),
        //             );
        //           },
        //         );
        //       } else {
        //         print("No bins available");
        //       }
        //     },
        //   ),
        // ),
      ]),
    ],
  );
}

}

TileLayer get openStreetMapTileLayer => TileLayer(
        urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
        userAgentPackageName: 'com.example.app',
);