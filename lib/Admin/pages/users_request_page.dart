import 'package:flutter/material.dart';

class UsersRequest extends StatefulWidget {
  const UsersRequest({super.key});

  @override
  State<UsersRequest> createState() => _UsersRequestState();
}

class _UsersRequestState extends State<UsersRequest> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Users Pages'),
    ); 
  }
}
