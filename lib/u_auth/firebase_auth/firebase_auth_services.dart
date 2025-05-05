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
<<<<<<< HEAD

=======
      
>>>>>>> 2917c4e (everything)
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = credential.user;

      if (user != null) {
<<<<<<< HEAD
 
=======
>>>>>>> 2917c4e (everything)
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'relation': relation,
          'uid': user.uid,
          'createdAt': Timestamp.now(),
        });
<<<<<<< HEAD
=======

>>>>>>> 2917c4e (everything)
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
<<<<<<< HEAD
=======

        
>>>>>>> 2917c4e (everything)
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

<<<<<<< HEAD
  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
=======

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
>>>>>>> 2917c4e (everything)
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
