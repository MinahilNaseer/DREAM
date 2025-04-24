import 'package:dream/u_auth/firebase_auth/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> childData;
final String childId;
  const EditProfilePage({super.key,required this.childData, required this.childId});

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
  _nameController.text = widget.childData['name'] ?? '';
  _gender = widget.childData['gender'] ?? '';
  // Fetch password from parent document
  FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .get()
      .then((doc) {
    if (doc.exists) {
      setState(() {
        _passwordController.text = doc['password'] ?? '';
      });
    }
  }).catchError((e) {
    print("Error fetching password: $e");
  });
  }

  Future<void> _updateUserData() async {
  final updatedChildData = {
    'name': _nameController.text,
    'gender': _gender,
    'updatedAt': FieldValue.serverTimestamp(),
  };

  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // update child under the current parent
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('children')
          .doc(widget.childId)
          .update(updatedChildData);

      await FirebaseFirestore.instance
    .collection('users')
    .doc(user.uid)
    .update({'password': _passwordController.text});

      // Update password
      await user.updatePassword(_passwordController.text);

      _showSnackBar("Profile updated successfully!");
      Navigator.pop(context);
    }
  } catch (e) {
    print("Error updating profile: $e");
    _showSnackBar("Failed to update profile");
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
                    _buildTextField(_passwordController, 'Password', TextInputType.visiblePassword, true), // Show password as normal text
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

  Widget _buildTextField(
  TextEditingController controller,
  String labelText,
  [TextInputType keyboardType = TextInputType.text,
  bool obscure = false]) {

  return TextField(
    controller: controller,
    keyboardType: keyboardType,
    obscureText: obscure,
    decoration: InputDecoration(
      labelText: labelText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      filled: true,
      fillColor: Colors.white,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.purple),
      ),
    ),
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
