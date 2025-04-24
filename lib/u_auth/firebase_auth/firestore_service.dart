import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Fetches the logged-in parent's info
  Future<DocumentSnapshot<Map<String, dynamic>>> getParentData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      return await _db.collection('users').doc(user.uid).get();
    }
    throw Exception("User not logged in");
  }

  /// Updates parent-level information
  Future<void> updateParentData(Map<String, dynamic> data) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _db.collection('users').doc(user.uid).update(data);
    } else {
      throw Exception("User not logged in");
    }
  }

  /// Creates a parent user document in Firestore
  Future<void> createParentProfile(String relation, String email, String gender) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _db.collection('users').doc(user.uid).set({
          'relation': relation,
          'email': email,
          //'gender': gender,
          'uid': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        throw Exception("Error creating parent profile: $e");
      }
    } else {
      throw Exception("User not logged in");
    }
  }

  /// Adds a child under the current logged-in parent
  Future<void> addChild({
    required String name,
    required String birthdate,
    required String gender,
  }) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _db.collection('users').doc(user.uid).collection('children').add({
          'name': name,
          'birthdate': birthdate,
          'gender': gender,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        throw Exception("Error adding child: $e");
      }
    } else {
      throw Exception("User not logged in");
    }
  }

  /// Fetch all children under the current parent
  Future<List<Map<String, dynamic>>> getChildren() async {
    User? user = _auth.currentUser;
    if (user != null) {
      QuerySnapshot snapshot = await _db.collection('users').doc(user.uid).collection('children').get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } else {
      throw Exception("User not logged in");
    }
  }
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserData() async {
  return await getParentData(); // Alias to the new method
}

Future<void> updateUserData(Map<String, dynamic> data) async {
  return await updateParentData(data); // Alias to the new method
}

}
