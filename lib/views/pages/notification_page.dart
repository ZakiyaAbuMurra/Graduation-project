
import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  final List<Map<String, String?>> notifications;

  NotificationsScreen(this.notifications);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Received Notifications'),
      ),
      body: notifications.isEmpty
          ? Center(child: Text('No notifications received yet.'))
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return ListTile(
                  title: Text(notification['title'] ?? 'No Title'),
                  subtitle: Text(notification['body'] ?? 'No Body'),
                  // Optionally, use the payload to do something when the notification is tapped
                  onTap: () {
                    // For example, navigate to a specific screen
                  },
                );
              },
            ),
    );
  }
}