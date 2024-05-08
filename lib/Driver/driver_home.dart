import 'package:flutter/material.dart';

class driverHome extends StatefulWidget {
  const driverHome({super.key});

  @override
  State<driverHome> createState() => _driverHomeState();
}

class _driverHomeState extends State<driverHome> {
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
