class BinModel {
  final String assignedTo;
  final int height;
  final String id;
  final String lastPackUp;
  final String location;
  final String status;
  final String wasteType;
  final int width;
  final int humidity;
  final String color;
  final int fillLevel;
  final int notifiyHumidity;
  final int notifiTemp;
  final int notifiyLevel;
  final int temp;

  BinModel({
    required this.assignedTo,
    required this.height,
    required this.id,
    required this.lastPackUp,
    required this.location,
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
  });

  factory BinModel.fromMap(Map<String, dynamic> map, String documentId) {
    return BinModel(
      assignedTo: map['assignTo'] as String? ?? 'default assignedTo',
      height: map['height'] as int? ?? 0,
      id: documentId,
      lastPackUp: map['pickDate'] as String? ?? 'default_lastPAck',
      location: map['location '] as String? ?? 'default location',
      status: map['status'] as String? ?? 'default status',
      wasteType: map['Material'] as String? ?? 'default waste type',
      width: map['Width'] as int? ?? 0,
      color: map['color'] as String? ?? 'default color',
      fillLevel: map['fill-level'] as int? ?? 0,
      humidity: map['Humidity'] as int? ?? 0,
      temp: map['temp'] as int? ?? 0,
      notifiTemp: map['notifiyTemp'] as int? ?? 0,
      notifiyHumidity: map['notifiyHumidity'] as int? ?? 0,
      notifiyLevel: map['notifiyLevel'] as int? ?? 0,
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
      'location': location,
      'status': status,
      'Material': wasteType,
      'Width': width,
      'color': color,
      'fill-level': fillLevel,
      'Humidity': humidity,
      'temp': temp,
      'notifiyTemp': notifiTemp,
      'notifiyHumidity': notifiyHumidity,
      'notifiyLevel': notifiyLevel,
    };
  }
}
