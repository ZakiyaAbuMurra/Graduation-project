import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GeneralServices{

    Future<void> _getUserType(String type, String driverArea) async {
    try {
      // Get current user
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('No user signed in');
        return;
      }

      // Get user document from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        
          
          type = userDoc['type']; 
          if(userDoc['type'].toString().toLowerCase() == 'driver'){
           driverArea = userDoc['area'];
          }
          
        
      } else {
        print('User document does not exist');
      }
    } catch (e) {
      print('Error fetching user type: $e');
    }
  }

}