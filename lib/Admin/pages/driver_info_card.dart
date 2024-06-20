import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
                      colors: [Colors.white, Colors.blue.shade50],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
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
                              : AssetImage('assets/images/avater.png')
                                  as ImageProvider,
                        ),
                      ),
                      SizedBox(height: 10),
                      Divider(),
                      Row(
                        children: [
                          Text(
                            'Name: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey.shade700,
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
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            'Phone: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey.shade700,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${info['phone']}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blueGrey.shade900,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            'Truck: ', // Change 'truck' to 'trucknumber'
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey.shade700,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${info['trucknumber']}', // make sure this matches the field name in Firestore
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blueGrey.shade900,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            'Area: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey.shade700,
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

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        title: Text('User Info Cards'),
      ),
      body: UserInfoCards(),
    ),
  ));
}
