import 'package:flutter/material.dart';

class driverHome extends StatefulWidget {
  const driverHome({super.key});

  @override
  State<driverHome> createState() => _driverHomeState();
}

class _driverHomeState extends State<driverHome> {

 
  @override
  void initState() {
    super.initState();
    //initApp();
  }

  //   void initApp() async {
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
        title: const Text('Driver Page'),
      ),
      body: const Center(
        child: Text('Driver Pages ! '),
      ),
    );
  }
}
