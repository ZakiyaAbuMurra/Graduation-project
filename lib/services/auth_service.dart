import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recyclear/services/firestore_services.dart';
import 'package:recyclear/utils/api_paths.dart';

abstract class AuthServices {
  Future<bool> signInWithEmailAndPassword(String email, String password);
  Future<bool> signUpWithEmailAndPassword(
      String email,
      String password,
      String name,
      String phone,
      String photoUrl,
      String type,
      String area,
      String trucknumber);

  Future<void> sendPasswordResetEmail(String email);
  // Add a method signature for getUserType
  Future<String?> getUserType(String uid);
  Future<void> signOut();
  Future<User?> currentUser();
}

class AuthServicesImpl implements AuthServices {
  // Singleton Design Pattern
  final firebaseAuth = FirebaseAuth.instance;
  final firestoreServices = FirestoreService.instance;

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<String?> getUserType(String uid) async {
    try {
      // Use the FirestoreService to get the user document
      final userDoc = await firestoreServices.getDocument(
        path: 'users/$uid',
        builder: (data, documentID) {
          // Assuming 'type' is a field in the document
          return data['type'] as String?;
        },
      );

      // userDoc will be of type String? which is the user's type
      return userDoc;
    } catch (e) {
      print('Error getting user type: $e');
      // Handle any exceptions here
      return null;
    }
  }

  @override
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      // Attempt to sign in the user with Firebase Authentication
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;
      if (user != null) {
        // Fetch the user's type from Firestore after a successful sign-in
        String? userType = await getUserType(user.uid);
        if (userType != null) {
          return true;
        }
      }
      return false;
    } on FirebaseAuthException catch (e) {
      print('Failed to sign in with email and password: ${e.message}');
      return false;
    } catch (e) {
      print('An unexpected error occurred: $e');
      return false;
    }
  }

  @override
  Future<void> signOut() async {
    firebaseAuth.signOut();
  }

  @override
  Future<bool> signUpWithEmailAndPassword(
      String email,
      String password,
      String name,
      String phone,
      String photoUrl,
      String type,
      String area,
      String trucknumber) async {
    try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;
      if (user != null) {
        String uniqueID =
            _generateUniqueID(); // Implement this function based on your needs
        await firestoreServices.setData(path: ApiPaths.users(user.uid), data: {
          'uid': user.uid, // Keep using Firebase Auth UID for direct mapping
          'uniqueID': uniqueID, // Your auto-generated unique ID
          'email': user.email,
          'name': name,
          'phone': phone,
          'photoUrl': photoUrl,
          'type': type,
          'area': area,
          'trucknumber': trucknumber,
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
