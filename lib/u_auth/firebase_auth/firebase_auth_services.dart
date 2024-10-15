import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signUpWithEmailAndPassword(String email, String password, String name, String birthdate, String relation, String gender) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = credential.user;

      if (user != null) {
        // Store additional user information in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'birthdate': birthdate,
          'relation': relation,
          'gender': gender,
          'email': email,
        });
      }
      return user;
    } catch (e) {
      print("Some error occurred: $e");
      return null;
    }
  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } catch (e) {
      print("Some error occurred: $e");
      return null;
    }
  }
}
