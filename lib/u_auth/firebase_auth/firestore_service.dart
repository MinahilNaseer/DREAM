import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      return await _db.collection('users').doc(user.uid).get();
    }
    throw Exception("User not found");
  }

  Future<void> updateUserData(Map<String, dynamic> data) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _db.collection('users').doc(user.uid).update(data);
    } else {
      throw Exception("User not found");
    }
  }
}
