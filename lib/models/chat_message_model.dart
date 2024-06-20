import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String senderPhotoUrl;
  final String message;
  final DateTime dateTime;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderPhotoUrl,
    required this.message,
    required this.dateTime,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    DateTime dateTime;

    // Handle different possible types for dateTime
    if (map['dateTime'] is Timestamp) {
      dateTime = (map['dateTime'] as Timestamp).toDate();
    } else if (map['dateTime'] is int) {
      dateTime = DateTime.fromMillisecondsSinceEpoch(map['dateTime'] as int);
    } else {
      dateTime = DateTime.now(); // Default to now if the type is unexpected
    }

    return MessageModel(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? 'Anonymous',
      senderPhotoUrl: map['senderPhotoUrl'] ?? '',
      message: map['message'] ?? '',
      dateTime: dateTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'senderPhotoUrl': senderPhotoUrl,
      'message': message,
      'dateTime': Timestamp.fromDate(dateTime), // Ensure the dateTime is stored as a Timestamp
    };
  }
}
