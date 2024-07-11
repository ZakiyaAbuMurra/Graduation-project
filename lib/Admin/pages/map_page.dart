import 'dart:convert';
import 'dart:ffi';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' as latlong;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

import 'package:recyclear/services/auth_service.dart';
import 'package:recyclear/services/firestore_services.dart';
import 'package:recyclear/services/general_services.dart';
import 'package:recyclear/services/map_service.dart';
import 'package:recyclear/services/notification_service.dart';
import 'package:recyclear/utils/app_colors.dart';
import 'package:recyclear/views/widgets/main_button.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add this line

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  GoogleMapController? controller;
  List<DocumentSnapshot<Map<String, dynamic>>> binInfo = [];
  final List<Marker> _markers = [];
  final List<latlong.LatLng> routeList = [];
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference().child('sensors/data');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Set<Polyline> _polylines = {};
  Set<Polyline> _shortestPolylines = {};
  final prefrance = SharedPreferences.getInstance();
  final AuthServices authServices = AuthServicesImpl();
  

  String _date = '';
  int year = 0;
  int month = 0;
  int day = 0;
  int hour = 0;
  int minute = 0;
  int second = 0;
  double _fillLevel = 0;
  double _humidity = 0.0;
  double _temperature = 0.0;
  String _time = '';
  int _binId = -1;
  String? _markerId;
  int _markerIndex = 0;
  GeoPoint? location;
  String addressloc = '';
  String localLocation = '';
  bool showCard = false;
  LatLng _currentPosition = LatLng(31.9574, 35.1886);
  LatLng locroute = LatLng(31.9014, 35.1999);
  double routeDistance = 0.0;
  int routeTime = 0;
  String? type;
  String driverArea = '';
  bool getShortestRoute = false;
  String binArea = '';

  double notifiyHumidity = 0.0;
  double notifiyTemperature = 0.0;
  double notifiyLevel = 0.0; 

  StreamSubscription<DatabaseEvent>? _databaseSubscription;
  final List<Map<String, dynamic>> _markerData = [];
  final List<Map<String,dynamic>> _routs = [];
  late Map<String, dynamic> _latestData;
  User? user = FirebaseAuth.instance.currentUser;





  // Future<void> _getUserType() async {
  //   try {
  //     // Get current user
  //     User? user = FirebaseAuth.instance.currentUser;
  //     if (user == null) {
  //       print('No user signed in');
  //       return;
  //     }

  //     // Get user document from Firestore
  //     DocumentSnapshot userDoc = await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(user.uid)
  //         .get();

  //     if (userDoc.exists) {
  //       setState(() {
          
  //         type = userDoc['type']; 
  //         if(userDoc['type'].toString().toLowerCase() == 'driver'){
  //          driverArea = userDoc['area'];
  //         }
          
  //       });
  //     } else {
  //       print('User document does not exist');
  //     }
  //   } catch (e) {
  //     print('Error fetching user type: $e');
  //   }
  // }

  List<LatLng> decodePolyline(String encoded) {
  List<LatLng> polyline = [];
  int index = 0, len = encoded.length;
  int lat = 0, lng = 0;

  while (index < len) {
    int b, shift = 0, result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1F) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
    lat += dlat;

    shift = 0;
    result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1F) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
    lng += dlng;

    LatLng p = LatLng(lat / 1E5, lng / 1E5);
    polyline.add(p);
  }

  return polyline;
}

// Function to get route from OSRM
Future<List<LatLng>> getRouteDriver(LatLng start, latlong.LatLng end) async {
  final url = 'http://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full';

  final response = await http.get(Uri.parse(url)).timeout(Duration(seconds: 30));

  if (response.statusCode == 200) {
    Map<String, dynamic> data = json.decode(response.body);
    String encodedPolyline = data['routes'][0]['geometry'];
    return decodePolyline(encodedPolyline);
  } else {
    throw Exception('Failed to load route');
  }
}


  Future<void> _initializeMap() async {
     List<Polyline> newPolylines = [];


    for (latlong.LatLng location in routeList) {
      List<LatLng> routePoints = await getRouteDriver(_currentPosition, location);
      newPolylines.add(Polyline(
          polylineId: PolylineId(location.toString()),
          visible: true,
          points: routePoints,
          color: Colors.blue,
          width: 4
        ));

     
    }
    if(mounted){
       setState(() {
        
        _shortestPolylines.addAll(newPolylines);
      });
    }
    
  }
  Future<void> fetchBinLocations() async {
    try {
      // Create a stream to listen for updates
      FirebaseFirestore.instance.collection('bins').snapshots().listen((querySnapshot) {
        if(mounted){
           setState(() {
          binInfo = querySnapshot.docs;

          _markers.clear();
          _markerData.clear();

          for (var bin in binInfo) {
            // Check if _markerData already contains the docId
            var existingIndex = _markerData.indexWhere((element) => element['docId'] == bin.id);

            if (existingIndex != -1) {
              setState(() {
                _markerData[existingIndex] = {
                  'docId': bin.id,
                  'height': bin.data()?['Height'],
                  'humidity': bin.data()?['Humidity'],
                  'material': bin.data()?['Material'],
                  'width': bin.data()?['Width'],
                  'color': bin.data()?['color'],
                  'fill-level': bin.data()?['fill-level'],
                  'location': bin.data()?['location'],
                  'status': bin.data()?['status'],
                  'temp': bin.data()?['temp'],
                  'date': bin.data()?['pickDate'],
                  'ID': bin.data()?['binID'],
                  'area': bin.data()?['area'],
                };
              });
            } else {
              setState(() {
                _markerData.add({
                  'docId': bin.id,
                  'height': bin.data()?['Height'],
                  'humidity': bin.data()?['Humidity'],
                  'material': bin.data()?['Material'],
                  'width': bin.data()?['Width'],
                  'color': bin.data()?['color'],
                  'fill-level': bin.data()?['fill-level'],
                  'location': bin.data()?['location'],
                  'status': bin.data()?['status'],
                  'temp': bin.data()?['temp'],
                  'date': bin.data()?['pickDate'],
                  'ID': bin.data()?['binID'],
                  'area': bin.data()?['area'],
                });
              });
            }

            GeoPoint geoPoint = bin.data()?['location'];
            _markers.add(
              Marker(
                markerId: MarkerId(bin.id),
                position: LatLng(geoPoint.latitude, geoPoint.longitude),
                onTap: () async => await _tappedMarker(bin.id),
              ),
            );
          }
        });

        }
       

      });
    } catch (e) {
      print('Error fetching bin locations: $e');
    }
  }


  void getAddress() async {
    String address = await getAddressFromLatLng(location!, 'address');
    String locat = await getAddressFromLatLng(location!, "name");
   // print("Address: $address");
    if (mounted) {
      setState(() {
        addressloc = address;
        localLocation = locat;
      });
    }
  }


  Future<void> addDataToHistory() async {
    try {
      await _firestore.collection('binsHistory').add({
        'binId': _binId,
        'fill-level': _fillLevel,
        'humidity': _humidity,
        'temperature': _temperature,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Data added to history successfully.');
    } catch (e) {
      print('Error adding data to history: $e');
    }
  }

  LatLng convertGeoPointToLatLng(GeoPoint geoPoint) {
    return LatLng(geoPoint.latitude, geoPoint.longitude);
  }

  Future<void> _tappedMarker(String docId) async {
   // fetchBinLocations();

    if (mounted) {
      setState(() {

        _markerId = docId;
        _markerIndex =
            _markerData.indexWhere((marker) => marker['docId'] == _markerId);
        location = _markerData[_markerIndex]['location'];
        locroute =
            convertGeoPointToLatLng(_markerData[_markerIndex]['location']);
        double distance = calculateDistance(_currentPosition, locroute);
        routeDistance = distance;
        routeTime = calculateEstimatedTime(_currentPosition, locroute);
       // print("//////////////////// ${distance}");
        showCard = true;
       // fetchBinLocations();

      });
      _getRoute();

      getAddress();
      _fetchLatestBinHistory();
    }
  }

  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  Future<String> getAddressFromLatLng(GeoPoint location, String area) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(location.latitude, location.longitude);
      String address;

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        if (area == "address") {
          address = "${place.locality},${place.name}";
        } else if (area == "name") {
          address = "${place.name}";
        } else {
          address = '';
        }
        return address;
      } else {
        return "No address found";
      }
    } catch (e) {
      print(e);
      return "Error occurred while fetching address";
    }
  }


  Future<List<LatLng>> getRouteCoordinates(LatLng start, LatLng end) async {
    final response = await http.get(Uri.parse(
        'http://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson'));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var route = data['routes'][0]['geometry']['coordinates'] as List;
      return route.map((point) => LatLng(point[1], point[0])).toList();
    } else {
      throw Exception('Failed to load route');
    }
  }



  double calculateDistance(LatLng start, LatLng end) {
    const earthRadius = 6371; // Radius of the earth in km

    double dLat = _degreeToRadian(end.latitude - start.latitude);
    double dLon = _degreeToRadian(end.longitude - start.longitude);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreeToRadian(start.latitude)) *
            cos(_degreeToRadian(end.latitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c; // Distance in km

    return distance;
  }

  double _degreeToRadian(double degree) {
    return degree * pi / 180;
  }

  int calculateEstimatedTime(LatLng start, LatLng end) {
    // Calculate distance between points using Haversine formula (in kilometers)
    double distanceInKm = calculateDistance(start, end);

    // Assume average speed in kilometers per hour (km/h)
    double averageSpeedKmh = 35; // 60 km/h

    // Calculate estimated time in hours
    double estimatedTimeHours = distanceInKm / averageSpeedKmh;

    // Convert hours to minutes and round to nearest integer
    int estimatedTimeMinutes = (estimatedTimeHours * 60).round();

    return estimatedTimeMinutes;
  }

  Future<void> _getRoute() async {
    List<LatLng> route =
        await getRouteCoordinates(_currentPosition, locroute as LatLng);
      if(mounted){
    setState(() {
      _polylines.add(Polyline(
        polylineId: PolylineId('route'),
        points: route,
        color: Colors.blue,
        width: 5,
      ));
    });
      }
  }

 

  Future<void> _fetchLatestBinHistory() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('binsHistory')
          .where('binId', isEqualTo: _markerData[_markerIndex]['ID'])
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();
      print(
          "//////////////////////////////   ${_markerData[_markerIndex]['ID'].toString()}");
      print(
          "//////////////////////////////   ${_markerData[_markerIndex]['docId'].toString()}");

      if (querySnapshot.docs.isNotEmpty) {
        if (mounted) {
          setState(() {
            _latestData =
                (querySnapshot.docs.first.data() as Map<String, dynamic>?)!;
            print(_latestData['fill-level']);
          });
        }
      } else {
        if (mounted) {
          setState(() {
            print('Null _lastData');
          });
        }
      }
    } catch (e) {
      print('Error fetching data: $e');
      if (mounted) {
        setState(() {
          print('Null _lastData');
        });
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serciveEnabled;
    LocationPermission permission;

    serciveEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serciveEnabled) {
      return Future.error("Location service are disabled");
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Location Permissions are denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          "Location permissions are permanently denied, we cannot request permissions.");
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
      if(mounted){
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _markers.add(
        Marker(
          markerId: MarkerId('CurrnetLocation'),
          position: LatLng(position.latitude, position.longitude),
        ),
      );
      print(
          "///////////////////////////////// ${position.latitude}\n ${position.longitude}");
    });
      }
    GeoPoint locationCurrent = GeoPoint(position.latitude, position.longitude);
    String current = await getAddressFromLatLng(locationCurrent, "name");
    print("//////////////////////////////////// Current = ${current}\n");

    _cameraToPosition(_currentPosition);

    print(_markers.length);
    controller?.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentPosition, zoom: 8)));
  }

  Future<void> _cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _controller.future;
    CameraPosition _newCameraPosition = CameraPosition(target: pos, zoom: 8);

    await controller
        .animateCamera(CameraUpdate.newCameraPosition(_newCameraPosition));
  }


Map<String, dynamic>? binData;

  Future <void> getNotifiedData2(int binID) async{

    binData = await MapServices.getNotifiedData(binID);
    if (binData!=null){
      if(mounted){
        setState(() {
          
      notifiyHumidity =  binData?['notifiyHumidity'] is int
                  ? (binData?['notifiyHumidity'] as int).toDouble()
                  : binData?['notifiyHumidity']; 
                 
      notifiyLevel =  binData?['notifyLevel'] is int
                  ? (binData?['notifyLevel'] as int).toDouble()
                  : binData?['notifyLevel'];
      notifiyTemperature =   binData?['notifiyTemperature'] is int
                  ? (binData?['notifiyTemperature'] as int).toDouble()
                  : binData?['notifiyTemperature'];
  
        });
    
      }

    }else{
      print('bin data is null');
    }

  }

    @override
  void initState() {
    super.initState();
   
 

       //  initApp();
    
 
    // Fetch initial data or perform any setup logic
    fetchBinLocations();

    // Setup database subscription
 _databaseSubscription = _databaseReference.onValue.listen((event) async {
      try {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
     
        if (data != null) {
          print("Data received:");
          print("Bin ID: ${data['binId']}");
          print("DateTime: ${DateTime(data['year'],data['month'],
          data['day'],data['hour'],data['minute'])}");
          print("Fill Level: ${data['fill-level']}");
          print("Humidity: ${data['humidity']}");
          print("Temperature: ${data['temperature']}");






         // print("Time: ${data['time']}");

             FirebaseFirestore.instance
                    .collection('bins')
                    .where('binID', isEqualTo: data['binId'] as int)
                    .get()
                    .then((querySnapshot) {
                  for (var doc in querySnapshot.docs) {
                     print("---------------------------------------------- ${Timestamp.fromDate(DateTime(data['year'],data['month']))}");

                    doc.reference.update({'fill-level': data['fill-level'], 
                    'Humidity':data['humidity'],
                    'temp':data['temperature'],
                    'changes':Timestamp.fromDate(DateTime(data['year'],data['month'],

                    data['day'],data['hour'],data['minute']))},
                    ).then((_) {
                      print(
                          "Bin: ${data['binId']} data updated");
                    }).catchError((error) {
                      print("Failed to update bin status: $error");
                    });
                  }
                }).catchError((error) {
                  print("Failed to retrieve bin: $error");
                });


          if (mounted) {
            await getNotifiedData2(data['binId']);
            setState(() {

            print(notifiyLevel);

            


         


              

              _binId = data['binId'] as int;
              year = data['year'];
              month = data['month'];
              day = data['day'];
              hour = data['hour'];
              minute = data['minute'];
              _fillLevel = data['fill-level'] is int
                  ? (data['fill-level'] as int).toDouble()
                  : data['fill-level'];
              _humidity = data['humidity'] is int
                  ? (data['humidity'] as int).toDouble()
                  : data['humidity'];
              _temperature = data['temperature'] is int
                  ? (data['temperature'] as int).toDouble()
                  : data['temperature'];
              //_time = data['time'];
            });

              addDataToHistory();
          }
           Map<String, String?> userType = await MapServices.getUserType();
           if(mounted){
             setState(() {
              type = userType['type'];
              driverArea = userType['driverArea']!;
            });
           }

          for (var bin in binInfo){
            if(bin.data()?['binID'] as int == data['binId'] as int && bin.data()?['area'] == driverArea){
              if(mounted){
                setState(() {
                  binArea = bin.data()?['area'];
                });
              }
              

               print("---------------------------------------------- ${type}, ${driverArea}");

            }
          }
            print("====================================================== ${binArea}");

            if(binArea == driverArea){



                          print("----------------------------------------- status is area");

              if (data['fill-level'] != 0 && data['fill-level'] != 357 && data['fill-level'] <= notifiyLevel  ) {
                if(type.toString().toLowerCase() == 'driver'){
                  
                  print("------------------");

                print("----------------------------------------- status is fill");

                  

                  await MapServices.initApp(driverArea);
                     NotificationService().saveNotification(
              'Fill Level Alert',
              'The bin ${data['binId']} is now ${data['fill-level']}cm Fill Level',
              driverArea,
              "fill-level"
            );
                }
              

                FirebaseFirestore.instance
                    .collection('bins')
                    .where('binID', isEqualTo: data['binId'])
                    .get()
                    .then((querySnapshot) {
                  for (var doc in querySnapshot.docs) {
                    doc.reference.update({'status': 'full'}).then((_) {
                      if( _markerData[_markerIndex]['ID'] == data['binId']){
                        _markerData[_markerIndex]['status'] = 'Full';
                      }
                     
                      print(
                          "Bin status updated to 'full' for bin ID: ${data['binId']}");
                    }).catchError((error) {
                      print("Failed to update bin status: $error");
                    });
                  }
                }).catchError((error) {
                  print("Failed to retrieve bin: $error");
                });
              } else if(data['fill-level'] == 0 || data['fill-level'] == 357){
                                print("----------------------------------------- status is lidar");

                 // MapServices.initApp(driverArea);
                     NotificationService().saveNotification(
              'Ultrasonic Faliure Alert',
              'The bin ${data['binId']} has a ultrasonic Faliure',
              driverArea,
              "ultrasonic"
            );
                   FirebaseFirestore.instance
                    .collection('bins')
                    .where('binID', isEqualTo: data['binId'])
                    .get()
                    .then((querySnapshot) {
                  for (var doc in querySnapshot.docs) {
                    doc.reference.update({'status': 'failure'}).then((_) {
                       if( _markerData[_markerIndex]['ID'] == data['binId']){
                        _markerData[_markerIndex]['status'] = 'Failure';
                      }
                      print(
                          "Bin status updated to 'failure: Ultrasonic' for bin ID: ${data['binId']}");
                    }).catchError((error) {
                      print("Failed to update bin status: $error");
                    });
                  }
                }).catchError((error) {
                  print("Failed to retrieve bin: $error");
                });

              }else if(data['humidity'] == -2000 || data['temperature'] == -2000){
                                print("----------------------------------------- status is DHT");

                     NotificationService().saveNotification(
              'DHT Faliure Alert',
              'The bin ${data['binId']} has a DHT Faliure',
              driverArea,
              "DHT"
            );

                       FirebaseFirestore.instance
                    .collection('bins')
                    .where('binID', isEqualTo: data['binId'])
                    .get()
                    .then((querySnapshot) {
                  for (var doc in querySnapshot.docs) {
                    doc.reference.update({'status': 'failure'}).then((_) {
                       if( _markerData[_markerIndex]['ID'] as int == data['binId'] as int){
                        _markerData[_markerIndex]['status'] = 'Failure';
                      }
                      print(
                          "Bin status updated to 'failure: DHT' for bin ID: ${data['binId']}");
                    }).catchError((error) {
                      print("Failed to update bin status: $error");
                    });
                  }
                }).catchError((error) {
                  print("Failed to retrieve bin: $error");
                });
              }else if(data['humidity']>= notifiyHumidity){
                print("----------------------------------------- status is humidity");

                   NotificationService().saveNotification(
              'Humidity Alert',
              'The bin ${data['binId']} reached ${data['humidity']} humidity',
              driverArea,
              "humidity"
            );

              }else if(data['temperature'] >= notifiyTemperature){
                print("----------------------------------------- status is temperature");

                  NotificationService().saveNotification(
              'Temperature Alert',
              'The bin ${data['binId']} reached ${data['temperature']} Temperature',
              driverArea,
              "temp"
            );

              }
              
              else {
               print("--------------------------------------- ${data['fill-level']}");

                if(data['fill-level'] as int >=80 && data['fill-level'] as int <=100){
                  print("--------------------------------------- fill level entered");
                  FirebaseFirestore.instance
                    .collection('bins')
                    .where('binID', isEqualTo: data['binId'] as int)
                    .get()
                    .then((querySnapshot) {
                  for (var doc in querySnapshot.docs) {
                    doc.reference.update({'pickDate': Timestamp.fromDate(DateTime(data['year'],data['month'],

                    data['day'],data['hour'],data['minute']))}).then((_) {
                       if( _markerData[_markerIndex]['ID'] == data['binId']){
                        
                          
                                     _markerData[_markerIndex]['date'] = Timestamp.fromDate(DateTime(data['year'],data['month'],

                    data['day'],data['hour'],data['minute']));
                            
                          
                          
                        
               
                      }
                      print(
                          "Bin pickupdate updated to ${_markerData[_markerIndex]['date']} for bin ID: ${data['binId']}");
                    }).catchError((error) {
                      print("Failed to update bin status: $error");
                    });
                  }
                });
                  
                  
                }
                print("----------------------------------------- status is Empty");
                await MapServices.deleteDocumentByBinId(data['binId']);
                FirebaseFirestore.instance
                    .collection('bins')
                    .where('binID', isEqualTo: data['binId'] as int)
                    .get()
                    .then((querySnapshot) {
                  for (var doc in querySnapshot.docs) {
                    doc.reference.update({'status': 'not full'}).then((_) {
                       if( _markerData[_markerIndex]['ID'] == data['binId']){
                        _markerData[_markerIndex]['status'] = 'Not Full';
                      }
                      print(
                          "Bin status updated to 'not full' for bin ID: ${data['binId']}");
                    }).catchError((error) {
                      print("Failed to update bin status: $error");
                    });
                  }
                }).catchError((error) {
                  print("Failed to retrieve bin: $error");
                });
              }
        }
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
    // Cancel subscription to avoid memory leaks
    _databaseSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Stack(
            children: [
              GoogleMap(
                initialCameraPosition:
                    CameraPosition(target: _currentPosition, zoom: 8),
                markers: Set<Marker>.of(_markers),
                polylines: getShortestRoute == true? _shortestPolylines:_polylines,
                myLocationEnabled: true,
                mapType: MapType.normal,
                onMapCreated: (GoogleMapController controller) {
                  controller = controller;
                  _controller.complete(controller);
                },
              ),
            ],
          ),
          _markerId != null
              ? Align(
                  alignment: Alignment.bottomCenter,
                  child: showCard == true
                      ? SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.4,
                          child: Card(
                            color: AppColors.white,
                            //shape: ShapeBorder(),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * 0.4,
                              color: Colors.white,
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.09,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.025),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.recycling_outlined,
                                                color: AppColors.primary,
                                                size: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.075,
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    top: MediaQuery.of(context)
                                                            .size
                                                            .height *
                                                        0.015,
                                                    left: MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.02),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      "Recycling Point",
                                                      style: TextStyle(
                                                        color:
                                                            AppColors.primary,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        const Text(
                                                          "Status: ",
                                                          style: TextStyle(
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      110,
                                                                      108,
                                                                      108),
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        Text(
                                                          _markerData[_markerIndex]
                                                                          [
                                                                          'status']
                                                                      .toString()
                                                                      .toLowerCase() ==
                                                                  'full'
                                                              ? 'Full'
                                                              : _markerData[_markerIndex]
                                                                          [
                                                                          'status']
                                                                      .toString()
                                                                      .toLowerCase() ==
                                                                  'failure'? 'Failure':'Empty',
                                                          style: TextStyle(
                                                            color: _markerData[_markerIndex]
                                                                            [
                                                                            'status']
                                                                        .toString()
                                                                        .toLowerCase() ==
                                                                    'full'
                                                                ? AppColors.red:
                                                                _markerData[_markerIndex]
                                                                          [
                                                                          'status']
                                                                      .toString()
                                                                      .toLowerCase() ==
                                                                  'failure'? Colors.orangeAccent
                                                                : AppColors
                                                                    .green,
                                                            //fontWeight: FontWeight.bold,
                                                            fontSize: 14,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                            onPressed: () {
                                              if(mounted){
                                              setState(() {
                                                showCard = false;
                                              });
                                              }
                                            },
                                            icon: Icon(
                                              Icons.cancel,
                                              size: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.07,
                                            ))
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.045),
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.08,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.43,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            border: Border.all(
                                                color: AppColors.primary),
                                            color: AppColors.green
                                                .withOpacity(0.2),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                left: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.03),
                                            child: Row(
                                              children: [
                                                Image.asset(
                                                  "assets/images/distance.png",
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.09,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.09,
                                                ),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          left: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.03),
                                                      child: Text(
                                                        routeDistance
                                                            .toStringAsPrecision(
                                                                3),
                                                        style: const TextStyle(
                                                          color:
                                                              AppColors.black,
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    const Text(
                                                      "Distance",
                                                      style: TextStyle(
                                                        color: AppColors
                                                            .lineColors,
                                                        fontSize: 14,
                                                      ),
                                                    )
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.03,
                                            right: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.045),
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.08,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.41,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            border: Border.all(
                                                color: AppColors.primary),
                                            color: AppColors.green
                                                .withOpacity(0.2),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                left: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.03),
                                            child: Row(
                                              children: [
                                                Image.asset(
                                                  "assets/images/clock.png",
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.05,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.05,
                                                ),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          left: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.025),
                                                      child: Text(
                                                        routeTime.toString() +
                                                            "min",
                                                        style: const TextStyle(
                                                          color:
                                                              AppColors.black,
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          left: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.015),
                                                      child: const Text(
                                                        "Estimated Time",
                                                        style: TextStyle(
                                                          color: AppColors
                                                              .lineColors,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top:
                                            MediaQuery.of(context).size.height *
                                                0.02,
                                        bottom:
                                            MediaQuery.of(context).size.height *
                                                0.02),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.065,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                            color: AppColors.primary),
                                        color: AppColors.green.withOpacity(0.2),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            size: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.035,
                                            color: AppColors.primary,
                                          ),
                                          Text(
                                            addressloc,
                                            style: const TextStyle(
                                                color: AppColors.black,
                                                fontSize: 14),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.045),
                                        child: Container(
                                          alignment: Alignment.center,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.085,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.43,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.08),
                                            border: Border.all(
                                                color: AppColors.primary),
                                            color: AppColors.white,
                                          ),
                                          child: ElevatedButton(
                                            onPressed: () {
                                              binInformation();
                                            },
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      AppColors
                                                          .white), // Background color
                                              foregroundColor:
                                                  MaterialStateProperty.all(Colors
                                                      .white), // Text and icon color
                                              shape: MaterialStateProperty.all(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.07),
                                                ),
                                              ),
                                            ),
                                            child: const Text(
                                              "Learn More",
                                              style: TextStyle(
                                                color: AppColors.green,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.045),
                                        child: Container(
                                          alignment: Alignment.center,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.085,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.43,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.08),
                                            border: Border.all(
                                                color: AppColors.primary),
                                            color: AppColors.white,
                                          ),
                                          child: ElevatedButton(
                                            onPressed: () {
                                              //ToDo
                                              if (type == 'user' &&
                                                  _markerData[_markerIndex]
                                                              ['status']
                                                          .toString()
                                                          .toLowerCase() ==
                                                      'full') {
                                                // showDialog(context: context, builder: builder)
                                              } else {
                                                print("Navigate successfuly");
                                              }
                                            },
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      AppColors
                                                          .white), // Background color
                                              foregroundColor:
                                                  MaterialStateProperty.all(Colors
                                                      .white), // Text and icon color
                                              shape: MaterialStateProperty.all(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.07),
                                                ),
                                              ),
                                            ),
                                            child: Container(
                                              child: const Text(
                                                "Navigate",
                                                style: TextStyle(
                                                  color: AppColors.green,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : const SizedBox())
              : const SizedBox(),

          type?.toLowerCase() == 'driver'?Align(
            alignment: AlignmentDirectional.bottomCenter,
            child: Padding(
              padding:  EdgeInsets.only(bottom: MediaQuery.of(context).size.height*0.02),
              child: showCard == false? Container(
                height: MediaQuery.of(context).size.height*0.06,
                width: MediaQuery.of(context).size.width*0.5,
                color: AppColors.primary,
                child: MainButton(title: "Get Routes",onPressed: () async{
                 List? routesCollection =  await MapServices.getDocumentByUniqueKey();
                 print("-------------------------------- get route length ${routesCollection?.length}" );

                 if(routesCollection!.isNotEmpty){
                  for(var route in routesCollection){
                    if(route['area'] == driverArea){
                      if(routeList.contains(MapServices.convertGeoPointToLatLng(route['location'])) == false){
                    routeList.add( ( MapServices.convertGeoPointToLatLng(route['location'])) );
                    print(routeList);
                      }
                 
                    await _initializeMap();
                    
                  }
                  print(routeList.length);
                  }

                  
                 }

                  if(mounted){
                    setState(() {
                      getShortestRoute = true;
                      
                    });
                  }
                },),
              ):SizedBox(),
            ),
          ):SizedBox(),
        ],
      ),
    );
  }

  Widget rowWidget(String text1, String text2, String text3, String text4) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(
        width: MediaQuery.of(context).size.width * 0.33,
        height: MediaQuery.of(context).size.height * 0.09,
        decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(5),
            boxShadow: const [
              BoxShadow(
                color: AppColors.grey,
                offset: Offset(3, 3),
                blurRadius: 5.0,
                spreadRadius: 2.0,
              ),
            ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(text1,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.black,
                  fontWeight: FontWeight.bold,
                )),
            Text(
              text2,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 110, 108, 108)),
            )
          ],
        ),
      ),
      Container(
        width: MediaQuery.of(context).size.width * 0.33,
        height: MediaQuery.of(context).size.height * 0.09,
        decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(5),
            boxShadow: const [
              BoxShadow(
                color: AppColors.grey,
                offset: Offset(3, 3),
                blurRadius: 5.0,
                spreadRadius: 2.0,
              ),
            ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(text3,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.black,
                  fontWeight: FontWeight.bold,
                )),
            Text(
              text4,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 110, 108, 108)),
            )
          ],
        ),
      ),
    ]);
  }

  void binInformation() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Bin Information",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black),
                ),
                IconButton(
                  icon: Icon(Icons.cancel),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.65,
              child: Column(
                children: [
                  Row(
                    children: [
                      Image.asset("assets/images/binIcon.png",
                          height: MediaQuery.of(context).size.height * 0.15,
                          width: MediaQuery.of(context).size.width * 0.15),
                      Padding(
                        padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.height * 0.02),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localLocation,
                              style: const TextStyle(
                                  color: AppColors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                const Text(
                                 'Bin ID: ',
                                  style:  TextStyle(
                                    color: Color.fromARGB(255, 110, 108, 108),
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  _markerData[_markerIndex]['ID'].toString(),
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 110, 108, 108),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  rowWidget(_markerData[_markerIndex]['fill-level'].toString(), 'Fill-Level',
                      _markerData[_markerIndex]['humidity'].toString(), "Humidity"),
                  Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.015),
                    child: rowWidget(
                        _markerData[_markerIndex]['temp'].toString(),
                        'Temperature',
                        _markerData[_markerIndex]['material'],
                        "Material"),
                  ),
                  Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.015),
                      child: rowWidget(
                          _markerData[_markerIndex]['color'],
                          'Color',
                          _markerData[_markerIndex]['status'],
                          "Status")),
                  Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.015),
                    child: Container(
                        height: MediaQuery.of(context).size.height * 0.08,
                        width: MediaQuery.of(context).size.width * 0.8,
                        decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.grey,
                                offset: Offset(3, 3),
                                blurRadius: 5.0,
                                spreadRadius: 2.0,
                              ),
                            ]),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                "Last Pickup Time",
                                style: TextStyle(
                                    color: AppColors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(_markerData[_markerIndex]['date']
                                  .toDate()
                                  .toString())
                            ])),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.02),
                    child: Image.asset(
                      "assets/images/greenRecyclear.png",
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  
}