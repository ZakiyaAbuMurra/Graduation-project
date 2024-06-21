import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recyclear/models/chat_message_model.dart';
import 'package:recyclear/services/chat_services.dart';
part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(ChatInitial());

  final chatServices = ChatServices();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(String text) async {
    emit(ChatMessageSending());
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }
      final userDocument =
          await _firestore.collection('users').doc(user.uid).get();
      final userData = userDocument.data();
      if (userData == null) {
        throw Exception('User data not found');
      }

      final senderId = user.uid;
      final senderName = userData['name'] ?? 'Anonymous';
      final senderPhotoUrl = userData['photoUrl'] ?? '';

      final message = MessageModel(
        id: DateTime.now().toIso8601String(),
        senderId: senderId,
        senderName: senderName,
        senderPhotoUrl: senderPhotoUrl,
        message: text,
        dateTime: DateTime.now(),
      );

      await chatServices.sendMessage(message);
      emit(ChatMessageSent());
    } catch (e) {
      emit(ChatMessageSendFailure(e.toString()));
    }
  }

  void getMessages() {
    final messagesStream = chatServices.getMessages();
    print("Fetched messages: $messagesStream"); // Debugging line

    messagesStream.listen(
      (messages) {
        emit(ChatSuccess(messages));
      },
      onError: (error) => emit(ChatFailure(error.toString())),
    );
  }
}
