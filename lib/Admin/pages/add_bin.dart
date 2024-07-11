/*
 this code sets up the initial state of the
 home screen for a Flutter application that
  monitors bin heights using Firestore and 
  notification services.
*/
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:recyclear/services/map_service.dart';
import 'package:recyclear/services/notification_service.dart';
import 'package:recyclear/views/widgets/add_bin_form.dart';

class AddBin extends StatefulWidget {
  @override
  _AddBinState createState() => _AddBinState();
}

class _AddBinState extends State<AddBin> {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference().child('sensors/data');  
StreamSubscription<DatabaseEvent>? _databaseSubscription;
  double notifiyHumidity = 0.0;
  double notifiyTemperature = 0.0;
  double notifiyLevel = 0.0; 
 final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot<Map<String, dynamic>>> binInfo = [];


  
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
    String? type;
  String driverArea = '';
  String binArea = '';


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
    Future<void> fetchBinLocations() async {
    try {
      // Fetch the bin data from Firestore
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('bins').get();

      // Save the documents to the list and create markers
      if(mounted){
      setState(() {
        binInfo = querySnapshot.docs;

      }
      );
      }
    } catch (e) {
      print('Error fetching bin locations: $e');
    }
  }
  
  @override
  void initState() {
    super.initState();
    fetchBinLocations();
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
              

         
              } else if(data['fill-level'] == 0 || data['fill-level'] == 357){
                                print("----------------------------------------- status is lidar");

                 // MapServices.initApp(driverArea);
                     NotificationService().saveNotification(
              'Ultrasonic Faliure Alert',
              'The bin ${data['binId']} has a ultrasonic Faliure',
              driverArea,
              "ultrasonic"
            );
                 

              }else if(data['humidity'] == -2000 || data['temperature'] == -2000){
                                print("----------------------------------------- status is DHT");

                     NotificationService().saveNotification(
              'DHT Faliure Alert',
              'The bin ${data['binId']} has a DHT Faliure',
              driverArea,
              "DHT"
            );

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
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                          Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.of(context)
                            .pop(); // Goes back to the previous screen
                      },
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width*0.75,
                      alignment: Alignment
                          .center, // Centers the image within the container
                    
                      // width: double.infinity,
                      child: Image.asset(
                        'assets/images/greenRecyclear.png',
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding:  EdgeInsets.only(
                    left: MediaQuery.of(context).size.width*0.05,
                    top:MediaQuery.of(context).size.height*0.02,
                    bottom: MediaQuery.of(context).size.height*0.02  ),
                  child: Text(
                    'Add Bin Page',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Padding(
                  padding:  EdgeInsets.all(MediaQuery.of(context).size.width*0.03),
                  child: const AddBinForm(),
                ),
        ],)
        ,),),
    );
  }
}
