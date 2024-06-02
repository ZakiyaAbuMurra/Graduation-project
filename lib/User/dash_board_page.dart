import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class UserDashBoard extends StatefulWidget {
  const UserDashBoard({super.key});

  @override
  State<UserDashBoard> createState() => _UserDashBoardState();
}

class _UserDashBoardState extends State<UserDashBoard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Image.asset(
                'assets/images/Recycling_Bin_Colours.png',
                width: MediaQuery.of(context).size.width,
                height: 200, // Adjust height as needed
                fit: BoxFit.cover,
              ),
              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  padding: const EdgeInsets.all(10),
                  child: const Text(
                    'Importance of Recycling: Awareness Brochure',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('blogs').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No blogs available'));
                }

                final blogs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: blogs.length,
                  itemBuilder: (context, index) {
                    final blog = blogs[index];
                    final blogData = blog.data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(blogData['title'] ?? 'No Title'),
                        subtitle: Text(blogData['content'] ?? 'No Content'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

    );
  }
}
