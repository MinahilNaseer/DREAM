import 'package:flutter/material.dart';
import '../widgets/listwidgetprofile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _gender = 'Male'; // Default value
  String _email = ''; // For storing user's email
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // Fetch user data from Firestore
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _email = user.email!.split('@')[0]; // Get user's email and remove the domain part

        DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore.instance
            .collection('users') // Replace with your actual collection
            .doc(user.uid) // Assuming user's UID is the document ID
            .get();

        if (userDoc.exists) {
          setState(() {
            _gender = userDoc.data()?['gender'] ?? 'Male'; // Get gender from Firestore
            _isLoading = false; // Stop loading once data is fetched
          });
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() {
        _isLoading = false; // Stop loading even if there's an error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 240, 225, 225), // Transparent background for the AppBar
        elevation: 0, // Remove the shadow under the AppBar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.purple, size: 30,), // Back icon
          onPressed: () {
            Navigator.pop(context, 'backToHome'); // Use pop to go back to the previous page
          },
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator()) // Show loading indicator while fetching data
            : Column(
                children: [
                  const Text(
                    'Profile',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: Color(0xFF0D47A1),
                    ),
                  ),
                  // Upper Part with Profile Image
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Image.asset(
                          _gender == 'Female'
                              ? 'assets/images/girl-pic.png' // If gender is Female, load girl-pic
                              : 'assets/images/boy-pic.png',  // If gender is Male or any other value, load boy-pic
                          height: 240,
                          width: 240,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Welcome, $_email', // Display "Welcome" with user's email (without domain)
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom Part that takes up the rest of the screen
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Edit Personal Information
                          CustomListTile(
                            icon: Icons.edit,
                            title: "Edit Personal Information",
                            onTap: () {
                              // Handle edit personal information functionality
                              Navigator.pushNamed(context, "/edit");
                            },
                          ),
                          const Divider(),
                          const SizedBox(height: 20),
                          CustomListTile(
                            icon: Icons.insert_chart_outlined,
                            title: "Reports / Results",
                            onTap: () {
                               Navigator.pushNamed(context, "/reports");
                            },
                          ),
                          const Divider(),
                          const SizedBox(height: 20),
                          CustomListTile(
                            icon: Icons.help_outline,
                            title: "Help",
                            onTap: () {
                              Navigator.pushNamed(context, "/help");
                            },
                          ),
                          const Divider(),
                          const SizedBox(height: 20),
                          CustomListTile(
                            icon: Icons.logout,
                            title: "Logout",
                            onTap: () {
                              FirebaseAuth.instance.signOut();
                              Navigator.pushNamed(context, "/login");
                              // Handle logout functionality
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}