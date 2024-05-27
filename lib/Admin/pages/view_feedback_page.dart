import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';  // Add this import for date formatting

class ViewFeedbackPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Feedback'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users_feedback').snapshots(),
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
              user: data['user'] ?? 'Anonymous',
              feedback: data['feedback description'] ?? 'No feedback',
              emoji: data['selected_emoji'] ?? '😊',
              timestamp: (data['timestamp'] as Timestamp?)?.toDate(), // Convert Timestamp to DateTime
            );
          }).toList();
          return ListView.builder(
            itemCount: feedbackList.length,
            itemBuilder: (context, index) {
              final feedbackItem = feedbackList[index];
              return Card(
                margin: const EdgeInsets.all(10.0),
                child: Padding(
                  padding:const  EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User: ${feedbackItem.user}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text('Emoji: ${feedbackItem.emoji}'),
                      const SizedBox(height: 5),
                      Text('Timestamp: ${feedbackItem.timestamp != null ? DateFormat('yyyy-MM-dd – kk:mm').format(feedbackItem.timestamp!) : 'No timestamp'}'),
                      const SizedBox(height: 5),
                      const Text('Feedback:'),
                      const SizedBox(height: 5),
                      Text(feedbackItem.feedback),
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

class FeedbackItem {
  final String user;
  final String feedback;
  final String emoji;
  final DateTime? timestamp;

  FeedbackItem({
    required this.user,
    required this.feedback,
    required this.emoji,
    required this.timestamp,
  });
}
