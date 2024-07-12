import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:recyclear/models/feedback_model.dart';
import 'package:recyclear/utils/app_colors.dart';

class ViewFeedbackPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Feedback'),
        backgroundColor: AppColors.primary,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('users_feedback').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No Feedback Found'));
          }
          var feedbackDocs = snapshot.data!.docs;
          List<FeedbackItem> feedbackList = feedbackDocs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            return FeedbackItem(
              user: data['name'] ?? 'Anonymous',
              feedback: data['feedback description'] ?? 'No feedback',
              emoji: data['selected_emoji'] ?? '😊',
              timestamp: (data['timestamp'] as Timestamp?)
                  ?.toDate(), // Convert Timestamp to DateTime
            );
          }).toList();

          return ListView.builder(
            itemCount: feedbackList.length,
            itemBuilder: (context, index) {
              final feedbackItem = feedbackList[index];
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
                              color: AppColors.black, size: 30),
                          const SizedBox(width: 10),
                          Text(
                            feedbackItem.user,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: AppColors.black,
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
                              const Icon(Icons.emoji_emotions,
                                  color: AppColors.black),
                              const SizedBox(width: 10),
                              Text(
                                'Emoji: ${feedbackItem.emoji}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.access_time,
                                  color: AppColors.black),
                              const SizedBox(width: 10),
                              Text(
                                'Timestamp: ${feedbackItem.timestamp != null ? DateFormat('yyyy-MM-dd – kk:mm').format(feedbackItem.timestamp!) : 'No timestamp'}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Feedback:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            feedbackItem.feedback,
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
