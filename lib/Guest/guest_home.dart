import 'package:flutter/material.dart';

class GuestHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guest Home'),
      ),
      body: Center(
        child: const Text(
          'Welcome, Guest!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
