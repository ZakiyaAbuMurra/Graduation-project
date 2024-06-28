/*
 this code sets up the initial state of the
 home screen for a Flutter application that
  monitors bin heights using Firestore and 
  notification services.
*/
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
  @override
  void initState() {
    super.initState();
    //initApp();
  }

  // void initApp() async {
  //   // Initialize notification service
  //   await NotificationService().initializeNotification();
  //   debugPrint('Before the start Monitoring Bin');
  //   // Start monitoring bin heights
  //   FirestoreService.instance.monitorBinHeightAndNotify();
  //   debugPrint('After the start Monitoring Bin');
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bin Monitor'),
      ),
      body: Center(
        child: Text('Monitoring bins...'),
      ),
    );
  }
}
