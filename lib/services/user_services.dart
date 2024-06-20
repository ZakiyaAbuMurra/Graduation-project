import 'package:firebase_auth/firebase_auth.dart';
import 'package:recyclear/models/user_data.dart';
import 'package:recyclear/services/firestore_services.dart';
import 'package:recyclear/utils/api_paths.dart';

class UserServices {
  final _firebaseAuth = FirebaseAuth.instance;
  final _firestoreService = FirestoreService.instance;

  Future<UserData> getUser() async {
    final user = _firebaseAuth.currentUser;
    final userData = await _firestoreService.getDocument(
      path: ApiPaths.users(user!.uid),
      builder: (data, documentId) => UserData.fromMap(data),
    );
    return userData;
  }
}
