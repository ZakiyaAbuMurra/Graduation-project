class BinModel {
  final String assignedTo;
  final int height;
  final String id;
  final String image;
  final String lastPackUp;
  final String location;
  final String status;
  final String wasteType;
  final int width;

  BinModel({
    required this.assignedTo,
    required this.height,
    required this.id,
    required this.image,
    required this.lastPackUp,
    required this.location,
    required this.status,
    required this.wasteType,
    required this.width,
  });

  factory BinModel.fromMap(Map<String, dynamic> map, String documentId) {
    return BinModel(
      assignedTo: map['assignedTo'] as String? ?? 'default assignedTo',
      height: map['height'] as int? ?? 0,
      id: documentId,
      image: map['image'] as String? ?? 'default_image_url',
      lastPackUp: map['lastPackUp'] as String? ?? 'default_lastPAck',
      location: map['location '] as String? ?? 'default location',
      status: map['status'] as String? ?? 'default status',
      wasteType: map['wasteType'] as String? ?? 'default waste type',
      width: map['width'] as int? ?? 0,
    );
  }

  // Convert a WasteBinModel instance into a map
  Map<String, dynamic> toMap() {
    return {
      'assignedTo': assignedTo,
      'height': height,
      'id':
          id, // This might not be necessary if the ID is already in the document path
      'image': image,
      'lastPackUp': lastPackUp,
      'location': location,
      'status': status,
      'wasteType': wasteType,
      'width': width,
    };
  }
}
