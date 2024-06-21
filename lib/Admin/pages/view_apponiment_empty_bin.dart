import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:recyclear/utils/app_colors.dart';

class ManageBinEmptyRequests extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Bin Empty Requests'),
        backgroundColor: AppColors.primary,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bin_empty_requests')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No Requests Found'));
          }
          var requestDocs = snapshot.data!.docs;
          List<BinEmptyRequest> binEmptyRequestList = requestDocs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            return BinEmptyRequest(
              description: data['description'] ?? 'No description',
              date: data['date'] ?? 'No date',
              time: data['time'] ?? 'No time',
              binNumber: data['bin number'] ?? 'No bin number',
              binLocation: data['bin location'] ?? 'No bin location',
              userId: data['user_id'] ?? 'Unknown user',
            );
          }).toList();

          return ListView.builder(
            itemCount: binEmptyRequestList.length,
            itemBuilder: (context, index) {
              final binEmptyRequest = binEmptyRequestList[index];
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
                          const Icon(Icons.delete,
                              color: Colors.black, size: 30),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Bin Number: ${binEmptyRequest.binNumber}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: AppColors.primary,
                              ),
                              overflow: TextOverflow.ellipsis,
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
                          Row(
                            children: [
                              const Icon(Icons.description,
                                  color: Colors.black, size: 24),
                              const SizedBox(width: 10),
                              const Text(
                                'Description:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  binEmptyRequest.description,
                                  style: const TextStyle(fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  color: Colors.black, size: 24),
                              const SizedBox(width: 10),
                              const Text(
                                'Location:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  binEmptyRequest.binLocation,
                                  style: const TextStyle(fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.access_time,
                                  color: Colors.black, size: 24),
                              const SizedBox(width: 10),
                              const Text(
                                'Date and Time:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '${binEmptyRequest.date} at ${binEmptyRequest.time}',
                                  style: const TextStyle(fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
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

class BinEmptyRequest {
  final String description;
  final String date;
  final String time;
  final String binNumber;
  final String binLocation;
  final String userId;

  BinEmptyRequest({
    required this.description,
    required this.date,
    required this.time,
    required this.binNumber,
    required this.binLocation,
    required this.userId,
  });
}
