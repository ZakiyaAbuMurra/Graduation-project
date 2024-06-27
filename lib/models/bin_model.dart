import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class BinModel {
  final String assignedTo;
  final double height;
  final String id;
  final Timestamp lastPackUp;
  final Timestamp changes;
  final String address;
  final String status;
  final String wasteType;
  final double width;
  final double humidity;
  final String color;
  final double fillLevel;
  final double notifiyHumidity;
  final double notifiTemp;
  final double notifiyLevel;
  final double temp;
  final GeoPoint location;
  final int binID;
      // dateTime: DateTime.fromMillisecondsSinceEpoch(map['dateTime']),
//      dateTime: DateTime.fromMillisecondsSinceEpoch(map['dateTime']),

  BinModel({
    required this.assignedTo,
   required this.height,
   required this.binID,
    required this.id,
    required this.changes,
    required this.lastPackUp,
    required this.address,
    required this.status,
    required this.wasteType,
    required this.width,
    required this.color,
    required this.temp,
    required this.fillLevel,
    required this.humidity,
    required this.notifiTemp,
    required this.notifiyHumidity,
    required this.notifiyLevel,
    required this.location,
  });

  factory BinModel.fromMap(Map<String, dynamic> map, String documentId) {
    return BinModel(
      assignedTo: map['assignTo'] as String? ?? 'default assignedTo',
      height: (map['Height'] as num).toDouble(),
      id: documentId,
      binID: (map['binID'] as num).toInt(),
      lastPackUp: map['pickDate'] as Timestamp,
      address: map['location '] as String? ?? 'default location',
      status: map['status'] as String? ?? 'default status',
      wasteType: map['Material'] as String? ?? 'default waste type',
      width: (map['Width'] as num).toDouble(),
      color: map['color'] as String? ?? 'default color',
      fillLevel: (map['fill-level'] as num).toDouble(),
      humidity: (map['Humidity'] as num).toDouble(),
      temp: (map['temp'] as num).toDouble(),
      notifiTemp: (map['notifiyTemperature'] as num).toDouble(),
      notifiyHumidity: (map['notifiyHumidity'] as num).toDouble(),
      notifiyLevel: (map['notifyLevel'] as num).toDouble(),
      location: map['location'] as GeoPoint? ?? const GeoPoint(0, 0),
      changes: map['changes'] as Timestamp

    );
  }

  // Convert a WasteBinModel instance into a map
  Map<String, dynamic> toMap() {
    return {
      'assignTo': assignedTo,
      'Height': height,
      'id':
          id, // This might not be necessary if the ID is already in the document path
      'pickDate': lastPackUp,
      'address': address,
      'status': status,
      'Material': wasteType,
      'Width': width,
      'color': color,
      'fill-level': fillLevel,
      'Humidity': humidity,
      'temp': temp,
      'notifiyTemperature': notifiTemp,
      'notifiyHumidity': notifiyHumidity,
      'notifyLevel': notifiyLevel,
      'location':location,
      'changes': changes,
      'binID': binID
    };
  }
}
