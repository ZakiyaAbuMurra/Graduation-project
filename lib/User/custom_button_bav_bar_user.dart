import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:recyclear/Admin/pages/edit_profile.dart';
import 'package:recyclear/Admin/pages/map_page.dart';
import 'package:recyclear/User/about_us_page.dart';
import 'package:recyclear/User/dash_board_page.dart';
import 'package:recyclear/User/scan_qr_code_page.dart';
import 'package:recyclear/User/store_page.dart';
import 'package:recyclear/User/term_of_use_page.dart';
import 'package:recyclear/services/map_service.dart';
import 'package:recyclear/services/notification_service.dart';
import 'package:recyclear/utils/app_colors.dart';
import 'package:recyclear/views/pages/requests_page_for_user_and_admain.dart';
import 'package:recyclear/services/firestore_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recyclear/views/pages/login_page.dart';

class CustomBottomNavbarUser extends StatefulWidget {
  const CustomBottomNavbarUser({super.key});

  @override
  State<CustomBottomNavbarUser> createState() => _CustomBottomNavbarUserState();
}

class _CustomBottomNavbarUserState extends State<CustomBottomNavbarUser> {
  int currentPageIndex = 0;
  User? user = FirebaseAuth.instance.currentUser;

  List<Widget> pageList = [
    const MapSample(),
    const UserStore(),
    QRCodeScannerView(),
    const RequestsPage(),
  ];

  String? userName;
  String? userEmail;

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
      if (user != null) {
      _loadUserData();
    }

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
  void dispose() {
    // Cancel subscription to avoid memory leaks
    _databaseSubscription?.cancel();
    super.dispose();
  }



  Future<void> _loadUserData() async {
    // Use the FirestoreService to get the user's data
    final userData = await FirestoreService.instance.getDocument(
      path: 'users/${user!.uid}', // Adjust the path to your users collection
      builder: (data, documentID) => data,
    );

    setState(() {
      userName = userData['name'] as String?;
      userEmail = userData['email'] as String?;
    });
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset(
          'assets/images/greenRecyclear.png',
          height: AppBar().preferredSize.height,
        ),
      ),
      drawer: buildDrawer(),
      bottomNavigationBar: buildBottomNavigationBar(),
      body: pageList[currentPageIndex],
    );
  }

  Widget buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.only(top: 40.0, bottom: 20.0),
            child: ListTile(
              title: Text(
                userName ?? 'Your Name',
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              subtitle: Text(
                userEmail ?? 'email@example.com',
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ListTile(
            title: Center(
              child: Image.asset(
                'assets/images/greenRecyclear.png',
                height: 80,
              ),
            ),
          ),
          const ListTile(
            title: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Welcome to Recyclear App! Here you can track your recycling progress, and manage your recycling activities efficiently. Earn points for recycling and redeem coupons at your favorite stores!. Let’s make the world a greener place together!',
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('Blog'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserDashBoard()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfile()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About Us'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutUsPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Terms of Use'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TermsOfUsePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  NavigationBar buildBottomNavigationBar() {
    return NavigationBar(
      selectedIndex: currentPageIndex,
      onDestinationSelected: (int index) {
        setState(() {
          currentPageIndex = index;
        });
      },
      destinations: const <NavigationDestination>[
        NavigationDestination(
          icon: Icon(Icons.map_outlined),
          selectedIcon: Icon(Icons.map),
          label: 'Map',
        ),
        NavigationDestination(
          icon: Icon(Icons.store_outlined),
          selectedIcon: Icon(Icons.store),
          label: 'Store',
        ),
        NavigationDestination(
          icon: Icon(Icons.scanner_outlined),
          selectedIcon: Icon(Icons.scanner),
          label: 'Scanner',
        ),
        NavigationDestination(
          icon: Icon(Icons.announcement_outlined),
          selectedIcon: Icon(Icons.announcement),
          label: 'Send Requests',
        ),
      ],
    );
  }
}
