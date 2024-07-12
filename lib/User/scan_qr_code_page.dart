import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recyclear/services/map_service.dart';
import 'package:recyclear/services/notification_service.dart';
import 'package:recyclear/utils/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QRCodeScannerView extends StatefulWidget {
  const QRCodeScannerView({super.key});

  @override
  State<StatefulWidget> createState() => _QRCodeScannerViewState();
}

class _QRCodeScannerViewState extends State<QRCodeScannerView> {
  bool _showDialog = false;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  bool isProcessing = false; // Flag to prevent multiple increments
  DateTime? lastScanTime; // To keep track of the last successful scan time


  StreamSubscription<DatabaseEvent>? _databaseSubscription;
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference().child('sensors/data');
        final FirebaseFirestore _firestore = FirebaseFirestore.instance;
          List<DocumentSnapshot<Map<String, dynamic>>> binInfo = [];


      Map<String, dynamic>? binData;
  double notifiyHumidity = 0.0;
  double notifiyTemperature = 0.0;
  double notifiyLevel = 0.0; 
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


  @override
  void initState() {
    super.initState();
    _checkFirstTimeUser('QRCodeScannerView');

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
              'The bin ${data['binId']} is now ${100 - data['fill-level']}cm Fill Level',
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
  void dispose() {
    // Cancel subscription to avoid memory leaks
    _databaseSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showDialog && WidgetsBinding.instance != null) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        _showIntroDialog(context);
        if(mounted){
setState(() {
          _showDialog = false;
        });
        }
        
      });
    }
    return Scaffold(
      appBar: AppBar(title: const Text('QR Code Scanner')),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.red,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (result != null)
                  ? Text('Scanned Data: ${result!.code}')
                  : const Text('Scan a code'),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!isProcessing) {
        if(mounted){
          setState(() {
          result = scanData;
          isProcessing =
              true; // Set the flag to true to prevent multiple increments
        });

        }
        
        // Process the scanned data
        _processScannedData(scanData.code);
      }
    });
  }

  void _processScannedData(String? scannedData) async {
    if (scannedData != null) {
      try {
        // Pause the camera to prevent multiple scans
        controller?.pauseCamera();

        int binId = int.parse(
            scannedData); // Assuming the scanned data is the bin ID as an integer
        await _retrieveBinHistoryAndUpdatePoints(binId);

        // Optionally resume the camera after a delay
        Future.delayed(const Duration(seconds: 2), () {
          if(mounted){
   setState(() {
            isProcessing = false; // Reset the flag
          });
          }
       
          controller?.resumeCamera();
        });
      } catch (e) {
        print('Error processing scanned data: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error processing scanned data')),
        );
        if(mounted){
          setState(() {
          isProcessing = false; // Reset the flag on error
        });

        }
        
      }
    }
  }

  void _showIntroDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'QR Scan Guidelines',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Image.asset(
                    'assets/images/qr-scan.gif',
                    height: 30,
                    width: 30,
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Welcome to Recyclear App! To earn points, follow these steps:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              const Text(
                '1. After discarding your recyclables, scan the QR code on the bin within 2 minutes.',
              ),
              const SizedBox(height: 8.0),
              const Text(
                '2. Ensure the QR code is clearly visible and within the scan area.',
              ),
              const SizedBox(height: 8.0),
              const Text(
                '3. You will earn points for every successful scan.',
              ),
              const SizedBox(height: 16.0),
              Center(
                child: Image.asset(
                  'assets/images/qr.png',
                  height: 150,
                  width: 150,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: AppColors.white,
                backgroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.grey),
              ),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _checkFirstTimeUser(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String email = user.email!;
      String uniqueKey = '$email-$key';
      bool isFirstTime = prefs.getBool(uniqueKey) ?? true;

      if (isFirstTime) {
        await prefs.setBool(uniqueKey, false);
        if(mounted){
           setState(() {
          _showDialog = true;
        });

        }
       
      }
    }
  }

  Future<void> _retrieveBinHistoryAndUpdatePoints(int binId) async {
    try {
      QuerySnapshot binHistorySnapshot = await FirebaseFirestore.instance
          .collection('binsHistory')
          .where('binId', isEqualTo: binId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (binHistorySnapshot.docs.isNotEmpty) {
        Map<String, dynamic> binHistoryData =
            binHistorySnapshot.docs.first.data() as Map<String, dynamic>;
        Timestamp binTimestamp = binHistoryData['timestamp'];
        DateTime binTime = binTimestamp.toDate();
        DateTime currentTime = DateTime.now();

        // Check if the time difference is within the error margin (e.g., 2 minutes)
        if (currentTime.difference(binTime).inMinutes.abs() <= 2) {
          if (lastScanTime == null ||
              currentTime.difference(lastScanTime!).inMinutes.abs() > 2) {
            await _incrementUserPoints();
            lastScanTime = currentTime; // Update last scan time
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content:
                      Text('You can only scan once within the error margin.')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Time difference is more than 5 minutes.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No history found for this bin.')),
        );
      }
    } catch (e) {
      print('Error retrieving bin history: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error retrieving bin history.')),
      );
    }
  }

  Future<void> _incrementUserPoints() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'points': FieldValue.increment(10), // Example: increment points by 10
      });

      // Optionally, show a success message or update the UI
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Points added successfully!')),
      );
    } catch (e) {
      print('Error updating user points: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating user points.')),
      );
    }
  }


}
