import 'package:dream/u_auth/firebase_auth/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController(); // Password controller
  String? _gender;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc = await _firestoreService.getUserData();
      if (userDoc.exists) {
        _nameController.text = userDoc.data()?['name'] ?? '';
        _passwordController.text = userDoc.data()?['password'] ?? ''; // Load the password
        _gender = userDoc.data()?['gender'] ?? '';
        setState(() {});
      }
    } catch (e) {
      print("Error loading user data: $e");
    }
  }

  Future<void> _updateUserData() async {
    final updatedData = {
      'name': _nameController.text,
      'gender': _gender,
      'password': _passwordController.text, // Directly assign the new password
    };

    try {
      // Update Firestore user data
      await _firestoreService.updateUserData(updatedData);

      // Update the user's password in Firebase Auth
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Update password
        await user.updatePassword(_passwordController.text);
        // Sign out the user after updating
        await FirebaseAuth.instance.signOut();

        // Sign in again with the updated password
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: user.email!, // Reuse the current email for signing back in
          password: _passwordController.text,
        );

        _showSnackBar("Updated Info");
        Navigator.pop(context); // Return to the ProfilePage after saving
      }
    } catch (e) {
      print("Error updating user data: $e");
      _showSnackBar("Error updating user info");
    }
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3), // Duration for which the SnackBar will be displayed
      behavior: SnackBarBehavior.floating, // Make it floating above the content
      backgroundColor: Colors.purple.withOpacity(0.7), // Decreased opacity for the SnackBar
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Your Information',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple, // Purple color for the title
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30), // Rounded corners for the container
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // Shadow position
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(_nameController, 'Name'),
                    const SizedBox(height: 16),
                    _buildGenderDropdown(),
                    const SizedBox(height: 16),
                    _buildTextField(_passwordController, 'Password', TextInputType.visiblePassword), // Show password as normal text
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple, // Button color
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30), // Button padding
                        ),
                        onPressed: _updateUserData,
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, [TextInputType keyboardType = TextInputType.text]) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30), // Match the rounded corners
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.purple), // Focus color
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: keyboardType,
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _gender,
      hint: const Text('Select Gender'),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30), // Match the rounded corners
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: ['Male', 'Female', 'Other']
          .map((gender) => DropdownMenuItem(value: gender, child: Text(gender)))
          .toList(),
      onChanged: (value) {
        setState(() {
          _gender = value;
        });
      },
    );
  }
}
