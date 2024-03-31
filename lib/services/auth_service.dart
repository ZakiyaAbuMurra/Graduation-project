import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recyclear/services/firestore_services.dart';
import 'package:recyclear/utils/api_paths.dart';

abstract class AuthServices {
  Future<bool> signInWithEmailAndPassword(String email, String password);
  Future<bool> signUpWithEmailAndPassword(String email, String password,
      String name, String phone, String photoUrl);
  Future<void> signOut();
  Future<User?> currentUser();
}

class AuthServicesImpl implements AuthServices {
  // Singleton Design Pattern
  final firebaseAuth = FirebaseAuth.instance;
  final firestoreServices = FirestoreService.instance;

  @override
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    final userCredential = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    User? user = userCredential.user;
    if (user != null) {
      return true;
    }
    return false;
  }

  @override
  Future<void> signOut() async {
    firebaseAuth.signOut();
  }

  @override
  Future<bool> signUpWithEmailAndPassword(String email, String password,
      String name, String phone, String photoUrl) async {
    try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;
      if (user != null) {
        String uniqueID =
            _generateUniqueID(); // Implement this function based on your needs
        await firestoreServices.setData(path: ApiPaths.user(user.uid), data: {
          'uid': user.uid, // Keep using Firebase Auth UID for direct mapping
          'uniqueID': uniqueID, // Your auto-generated unique ID
          'email': user.email,
          'name': name,
          'phone': phone,
          'photoUrl': photoUrl,
        });
        return true;
      }
    } catch (e) {
      print(e); // Handle any errors appropriately
      return false;
    }
    return false;
  }

// Example function to generate a unique ID (can be replaced with any ID generation logic you prefer)
  String _generateUniqueID() {
    var rng = Random();
    return List.generate(10, (index) => rng.nextInt(10)).join();
  }

  @override
  Future<User?> currentUser() {
    return Future.value(firebaseAuth.currentUser);
  }
}
