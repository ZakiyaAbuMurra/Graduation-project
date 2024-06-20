import 'package:recyclear/models/chat_message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(MessageModel message) async {
    await _firestore.collection('messages').add(message.toMap());
  }

  Stream<List<MessageModel>> getMessages() {
    return _firestore
        .collection('messages')
        .orderBy('dateTime')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MessageModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
}
