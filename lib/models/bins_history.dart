import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryModel {
 
 final String docId;
  final int id;
  final double humidity;
  final double fillLevel;
  final double temp;
  final Timestamp timestamp;


  HistoryModel({
    required this.docId,
    required this.id,
    required this.temp,
    required this.fillLevel,
    required this.humidity,
    required this.timestamp
  });

  factory HistoryModel.fromMap(Map<String, dynamic> map, String documentId) {
    return HistoryModel(
      docId: documentId,
      id: map['binId'],
      fillLevel: (map['fill-level'] as num).toDouble(),
      humidity: (map['humidity'] as num).toDouble(),
      temp: (map['temperature'] as num).toDouble(),
      timestamp: map['timestamp'] as Timestamp,
    );
  }

  // Convert a WasteBinModel instance into a map
  Map<String, dynamic> toMap() {
    return {
      'id':docId,
      'binId':id, // This might not be necessary if the ID is already in the document path
      'fill-level': fillLevel,
      'humidity': humidity,
      'temperature': temp,
    };
  }
}