import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future<User?> signUpWithEmailAndChild({
    required String email,
    required String password,
    required String relation,
    required String childName,
    required String childBirthdate,
    required String childGender,
  }) async {
    try {

      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = credential.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'relation': relation,
          'uid': user.uid,
          'createdAt': Timestamp.now(),
        });
        // Add child info and capture the DocumentReference
        DocumentReference childRef = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('children')
            .add({
          'name': childName,
          'birthdate': childBirthdate,
          'gender': childGender,
          'createdAt': Timestamp.now(),
        });

        // Update the child document with its own ID as 'childId'
        await childRef.update({
          'childId': childRef.id,
        });
      }

      return user;
    } catch (e) {
      print("Error during registration: $e");
      return null;
    }
  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      print("Error during sign-in: $e");
      return null;
    }
  }
}
