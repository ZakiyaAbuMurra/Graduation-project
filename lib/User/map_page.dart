import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:recyclear/utils/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class MapSample extends StatefulWidget {
  final double latitude;
  final double longitude;
  const MapSample({super.key, required this.latitude, required this.longitude});

  @override
  State<MapSample> createState() => _MapSampleState();
}

class _MapSampleState extends State<MapSample> {
  late double _latitude;
  late double _longitude;
  List<DocumentSnapshot<Map<String, dynamic>>> binInfo = [];
  // String _assignTo = '';
  // int _height = 0;
  // String _id ='';
  // String _pickDate='';
  // String _status ='';
  // String _Material='';
  // int _width = 0;
  // String _color ='';
  // int _fillLevel = 0;
  // int _humidity = 0;
  // int _temp = temp;

  void fetchSensorData() async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('bins').get();
    setState(() {
      binInfo = snapshot.docs;
    });
  }

  final _databaseRef = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    fetchSensorData();
    _latitude = widget.latitude;
    _longitude = widget.longitude;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(child: content(binInfo));
  }

  Widget content(List<DocumentSnapshot<Map<String, dynamic>>> bin) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(_latitude, _longitude),
        initialZoom: 11,
        interactionOptions:
            InteractionOptions(flags: ~InteractiveFlag.doubleTapZoom),
      ),
      children: [
        openStreetMapTileLayer,
        MarkerLayer(markers: [
          Marker(
            point: LatLng(_latitude, _longitude),
            width: 60,
            height: 80,
            alignment: Alignment.center,
            child: IconButton(
              icon: const Icon(Icons.location_pin),
              onPressed: () {
                if (bin.isNotEmpty) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.05,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Bin Information",
                                style: TextStyle(
                                  color: AppColors.lightBlack,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                icon: const Icon(Icons.cancel),
                              )
                            ],
                          ),
                        ),
                        content: Column(
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  'assets/images/binIcon.png',
                                  height:
                                      MediaQuery.of(context).size.height * 0.15,
                                  width:
                                      MediaQuery.of(context).size.width * 0.15,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width *
                                          0.03),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Location',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.lightBlack,
                                        ),
                                      ),
                                      Text(
                                        bin.first.id, // Now safe to access
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Fill-Level",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.lightBlack,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  "Humidity",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.lightBlack,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  bin.first.get(0),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.lightBlack,
                                    fontSize: 18,
                                  ),
                                ),
                                const Text(
                                  "Humidity",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.lightBlack,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  print("No bins available");
                }
              },
            ),
          ),
        ]),
      ],
    );
  }
}

TileLayer get openStreetMapTileLayer => TileLayer(
      urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
      userAgentPackageName: 'com.example.app',
    );
