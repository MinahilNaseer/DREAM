import 'package:flutter/material.dart';
import '../widgets/listwidgetprofile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dream/screens/editpage.dart';


class ProfilePage extends StatefulWidget {
  final Map<String, dynamic> childData;

  const ProfilePage({super.key, required this.childData});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String _gender;
  late String _childName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _childName = widget.childData['name'] ?? 'Child';
    _gender = widget.childData['gender'] ?? 'Male';
    _isLoading = false;
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
                          'Welcome, $_childName', // Display "Welcome" with user's email (without domain)
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
                              Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => EditProfilePage(
      childData: widget.childData,
      childId: widget.childData['id'],
    ),
  ),
);
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