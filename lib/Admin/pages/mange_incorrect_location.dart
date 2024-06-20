import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:recyclear/models/incorrect_location_model.dart';
import 'package:recyclear/utils/app_colors.dart';

class ManageIncoorectLocation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Incorrect location for bins'),
        backgroundColor: AppColors.primary,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('report_incorrect_location')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No Feedback Found'));
          }
          var feedbackDocs = snapshot.data!.docs;
          List<IncorrectLocation> IncorrectLocationList =
              feedbackDocs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            return IncorrectLocation(
              description: data['user'] ?? 'Anonymous',
              feedback: data['feedback description'] ?? 'No feedback',
            );
          }).toList();

          return ListView.builder(
            itemCount: IncorrectLocationList.length,
            itemBuilder: (context, index) {
              final incorrectLocation = IncorrectLocationList[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15.0),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(10.0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.person,
                              color: Color.fromRGBO(76, 175, 80, 1), size: 30),
                          const SizedBox(width: 10),
                          Text(
                            incorrectLocation.description,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, thickness: 1),
                    Container(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Feedback:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            incorrectLocation.feedback,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
