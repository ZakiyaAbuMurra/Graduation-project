
class BinRequest {
  final String address;
  final String comments;
  final String email;
  final String name;
  final String phoneNumber;
  final DateTime? timestamp;

  BinRequest({
    required this.address,
    required this.comments,
    required this.email,
    required this.name,
    required this.phoneNumber,
    required this.timestamp,
  });
}