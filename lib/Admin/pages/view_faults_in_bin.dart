import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:recyclear/models/fault_in_bin_model.dart';
import 'package:recyclear/utils/app_colors.dart';

class ViewFaultsBins extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Faults in bins'),
        backgroundColor: AppColors.primary,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('fault_in_bin').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No Reported faults in bins'));
          }

          var feedbackDocs = snapshot.data!.docs;
          List<FaultBins> faultBinList = feedbackDocs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            return FaultBins(
              description: data['description'] ?? 'No description provided',
              Country_name: data['Country name'] ?? 'Unknown',
              Neighborhood_name: data['Neighborhood name'] ?? 'Unknown',
              phoneNumber: data['phoneNumber'] ?? 'N/A',
            );
          }).toList();

          return ListView.builder(
            itemCount: faultBinList.length,
            itemBuilder: (context, index) {
              final faultBins = faultBinList[index];
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
                            faultBins.description,
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
                            'Problem description:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            faultBins.description,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Country:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            faultBins.Country_name,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Neighborhood:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            faultBins.Neighborhood_name,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Phone Number:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            faultBins.phoneNumber,
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
