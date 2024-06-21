import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recyclear/utils/app_colors.dart';

class UserInfoCards extends StatelessWidget {
  UserInfoCards({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('type', isEqualTo: 'driver')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final userInfo = snapshot.data!.docs.map((doc) {
          return {
            'name': doc['name'],
            'phone': doc['phone'],
            'email': doc['email'],
            'photoUrl': doc['photoUrl'],
            'area': doc['area'],
            'trucknumber': doc[
                'trucknumber'], // make sure this matches the field name in Firestore
          };
        }).toList();

        print('++++++++++++++ ${userInfo}');
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: userInfo.map((info) {
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                child: Container(
                  width: 250,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white,
                        Color.fromARGB(255, 210, 247, 226)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: CircleAvatar(
                          backgroundColor: Color.fromARGB(255, 68, 255, 121),
                          radius: 30,
                          backgroundImage: info['photoUrl'] != null &&
                                  info['photoUrl'].isNotEmpty
                              ? NetworkImage(info['photoUrl'])
                              : const AssetImage('assets/images/avater.png')
                                  as ImageProvider,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Divider(),
                      Row(
                        children: [
                          const Text(
                            'Name: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${info['name']}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blueGrey.shade900,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text(
                            'Phone: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${info['phone']}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text(
                            'Truck: ', // Change 'truck' to 'trucknumber'
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${info['trucknumber']}', // make sure this matches the field name in Firestore
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text(
                            'Area: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${info['area']}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blueGrey.shade900,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
