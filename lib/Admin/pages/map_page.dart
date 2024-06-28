import 'dart:convert';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

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
import 'package:recyclear/utils/app_colors.dart';
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
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference().child('sensors/data');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Set<Polyline> _polylines = {};
  final prefrance = SharedPreferences.getInstance();
  final AuthServices authServices = AuthServicesImpl();

  String _date = '';
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
  LatLng _currentPosition = LatLng(31.9014, 35.1999);
  LatLng locroute = LatLng(31.9014, 35.1999);
  double routeDistance = 0.0;
  int routeTime = 0;
  String type = '';

  StreamSubscription<DatabaseEvent>? _databaseSubscription;
  final List<Map<String, dynamic>> _markerData = [];
  late Map<String, dynamic> _latestData;
  User? user = FirebaseAuth.instance.currentUser;

  Future<void> fetchBinLocations() async {
    try {
      // Fetch the bin data from Firestore
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('bins').get();

      // Save the documents to the list and create markers
      setState(() {
        binInfo = querySnapshot.docs;

        for (var bin in binInfo) {
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
            'ID': bin.data()?['binID']
          });

          GeoPoint geoPoint = bin.data()?['location'];
          _markers.add(
            Marker(
              markerId: MarkerId(bin.id),
              position: LatLng(geoPoint.latitude, geoPoint.longitude),
              onTap: () => _tappedMarker(bin.id),
            ),
          );
        }
      });
    } catch (e) {
      print('Error fetching bin locations: $e');
    }
  }

  void getAddress() async {
    String address = await getAddressFromLatLng(location!, 'address');
    String locat = await getAddressFromLatLng(location!, "name");
    print("Address: $address");
    if (mounted) {
      setState(() {
        addressloc = address;
        localLocation = locat;
      });
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

  void _tappedMarker(String docId) {
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
        print("//////////////////// ${distance}");
        showCard = true;
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

  Future<List<LatLng>> getPolyLinePoints() async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        "AIzaSyAzC8P3c9sFtFYnB836O1r7Av0t063b9G4",
        PointLatLng(_currentPosition.latitude, _currentPosition.longitude),
        PointLatLng(location!.latitude, location!.longitude),
        travelMode: TravelMode.driving);

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print("////////////////////////// result List is empty");
    }
    return polylineCoordinates;
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
    setState(() {
      _polylines.add(Polyline(
        polylineId: PolylineId('route'),
        points: route,
        color: Colors.blue,
        width: 5,
      ));
    });
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

  Future<void> getType() async {
    print("-----------------------------------------------");
    if (user != null) {
      final userType = await authServices.getUserType(user!.uid);
      if (userType != null) {
        print("User Typeeeeeeeeeee: $userType");
        type = userType;
        print("typeeeeeeeeeeeeeeeeeeeeeeeeee ${type}");
      } else {
        print("User Type is null");
      }
    } else {
      print("No user in firbase");
    }
  }

  @override
  void initState() {
    super.initState();

    getType();
    _getCurrentLocation();
    fetchBinLocations();

    _databaseSubscription = _databaseReference.onValue.listen((event) async {
      try {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        if (data != null) {
          print("Data received:");
          print("Bin ID: ${data['binId']}");
          print("Date: ${data['date']}");
          print("Fill Level: ${data['fill-level']}");
          print("Humidity: ${data['humidity']}");
          print("Temperature: ${data['temperature']}");
          print("Time: ${data['time']}");

          if (mounted) {
            setState(() {
              if (data['fill-level'] >= 30) {
                FirebaseFirestore.instance
                    .collection('bins')
                    .where('binID', isEqualTo: data['binId'])
                    .get()
                    .then((querySnapshot) {
                  for (var doc in querySnapshot.docs) {
                    doc.reference.update({'status': 'full'}).then((_) {
                      print(
                          "Bin status updated to 'full' for bin ID: ${data['binId']}");
                    }).catchError((error) {
                      print("Failed to update bin status: $error");
                    });
                  }
                }).catchError((error) {
                  print("Failed to retrieve bin: $error");
                });
              } else {
                FirebaseFirestore.instance
                    .collection('bins')
                    .where('binID', isEqualTo: data['binId'])
                    .get()
                    .then((querySnapshot) {
                  for (var doc in querySnapshot.docs) {
                    doc.reference.update({'status': 'empty'}).then((_) {
                      print(
                          "Bin status updated to 'empty' for bin ID: ${data['binId']}");
                    }).catchError((error) {
                      print("Failed to update bin status: $error");
                    });
                  }
                }).catchError((error) {
                  print("Failed to retrieve bin: $error");
                });
              }

              _binId = data['binId'];
              _date = data['date'];
              _fillLevel = data['fill-level'] is int
                  ? (data['fill-level'] as int).toDouble()
                  : data['fill-level'];
              _humidity = data['humidity'] is int
                  ? (data['humidity'] as int).toDouble()
                  : data['humidity'];
              _temperature = data['temperature'] is int
                  ? (data['temperature'] as int).toDouble()
                  : data['temperature'];
              _time = data['time'];
            });
          }

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
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition:
                CameraPosition(target: _currentPosition, zoom: 8),
            markers: Set<Marker>.of(_markers),
            polylines: _polylines,
            myLocationEnabled: true,
            mapType: MapType.normal,
            onMapCreated: (GoogleMapController controller) {
              controller = controller;
              _controller.complete(controller);
            },
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
                                                              : 'Empty',
                                                          style: TextStyle(
                                                            color: _markerData[_markerIndex]
                                                                            [
                                                                            'status']
                                                                        .toString()
                                                                        .toLowerCase() ==
                                                                    'full'
                                                                ? AppColors.red
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
                                              setState(() {
                                                showCard = false;
                                              });
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
              : const SizedBox()
        ],
      ),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
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
                            Text(
                              _markerData[_markerIndex]['ID'].toString(),
                              style: const TextStyle(
                                color: Color.fromARGB(255, 110, 108, 108),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  rowWidget(_latestData['fill-level'].toString(), 'Fill-Level',
                      _latestData['humidity'].toString(), "Humidity"),
                  Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.015),
                    child: rowWidget(
                        _latestData['temperature'].toString(),
                        'Temperature',
                        _markerData[_markerIndex]['material'],
                        "Material"),
                  ),

                  //   Padding(
                  //   padding:  EdgeInsets.only(top: MediaQuery.of(context).size.height*0.015),
                  //   child: rowWidget(_markerData[_markerIndex]['width'].toString(),'Width',_markerData[_markerIndex]['height'].toString(),"Height")
                  // ),
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
