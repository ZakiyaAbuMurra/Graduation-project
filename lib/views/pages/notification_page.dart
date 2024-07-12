import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  final Stream<QuerySnapshot> notificationStream;

  NotificationsScreen(this.notificationStream);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Received Notifications'),
      ),
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: widget.notificationStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                    child: Text('No notifications received yet.'));
              }
              var notifications = snapshot.data!.docs;
              return ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  var notification =
                      notifications[index].data() as Map<String, dynamic>;
                  var timestamp = notification['timestamp'] as Timestamp?;
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 15.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.notifications,
                                  color: Colors.black, size: 30),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  notification['title'] ?? 'No Title',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            notification['body'] ?? 'No Body',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            timestamp != null
                                ? DateFormat('yyyy-MM-dd – kk:mm')
                                    .format(timestamp.toDate())
                                : 'No Timestamp',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  void setLoading(bool loading) {
    setState(() {
      _isLoading = loading;
    });
  }
}
