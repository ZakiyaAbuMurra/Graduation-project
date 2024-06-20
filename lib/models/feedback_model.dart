
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