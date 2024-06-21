import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:recyclear/utils/app_colors.dart';

class ManageCouponProblems extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Coupon Problems'),
        backgroundColor: AppColors.primary,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('coupons_problem')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No Problems Found'));
          }
          var problemDocs = snapshot.data!.docs;
          List<CouponProblem> couponProblemList = problemDocs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            return CouponProblem(
              contactPhoneNumber:
                  data['Contact phone Number'] ?? 'No contact number',
              problemDescription:
                  data['Problem description'] ?? 'No description',
              timestamp: (data['timestamp'] as Timestamp).toDate(),
            );
          }).toList();

          return ListView.builder(
            itemCount: couponProblemList.length,
            itemBuilder: (context, index) {
              final couponProblem = couponProblemList[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.phone,
                              color: Colors.black, size: 30),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              couponProblem.contactPhoneNumber,
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
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.description,
                              color: Colors.black, size: 24),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Problem Description:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        couponProblem.problemDescription,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.date_range,
                                  color: Colors.black, size: 24),
                              const SizedBox(width: 10),
                              const Text(
                                'Reported On:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            DateFormat('yyyy-MM-dd – kk:mm')
                                .format(couponProblem.timestamp),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class CouponProblem {
  final String contactPhoneNumber;
  final String problemDescription;
  final DateTime timestamp;

  CouponProblem({
    required this.contactPhoneNumber,
    required this.problemDescription,
    required this.timestamp,
  });
}

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        title: Text('Coupon Problems'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ManageCouponProblems(),
      ),
    ),
  ));
}
