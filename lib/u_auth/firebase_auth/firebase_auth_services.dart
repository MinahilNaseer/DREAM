import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Registers a parent and adds a child profile
  Future<User?> signUpWithEmailAndChild({
    required String email,
    required String password,
    required String relation,
    required String childName,
    required String childBirthdate,
    required String childGender,
  }) async {
    try {
      // Create the parent account
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = credential.user;

      if (user != null) {
        // Store parent info (excluding parent gender)
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'relation': relation,
          'password': password,
          'uid': user.uid,
          'createdAt': Timestamp.now(),
        });

        // Store child info in a subcollection called "children"
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('children')
            .add({
          'name': childName,
          'birthdate': childBirthdate,
          'gender': childGender,
          'createdAt': Timestamp.now(),
        });
      }

      return user;
    } catch (e) {
      print("Error during registration: $e");
      return null;
    }
  }

  /// Signs in the user using email and password
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
