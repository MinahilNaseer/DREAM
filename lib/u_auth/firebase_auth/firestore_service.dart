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

  Future<void> createUserInFirestore(String name, String birthdate, String relation, String email, String gender) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _db.collection('users').doc(user.uid).set({
          'name': name,
          'birthdate': birthdate,
          'relation': relation,
          'email': email,
          'gender': gender,
          'uid': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        throw Exception("Error adding user to Firestore: $e");
      }
    } else {
      throw Exception("User not found");
    }
  }
}
