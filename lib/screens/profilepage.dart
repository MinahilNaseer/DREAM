import 'package:flutter/material.dart';
import '../widgets/listwidgetprofile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dream/screens/editpage.dart';
import 'package:dream/screens/reportpage.dart';

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
        backgroundColor: const Color.fromARGB(255, 240, 225, 225),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.purple,
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context, 'backToHome');
          },
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
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
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Image.asset(
                          _gender == 'Female'
                              ? 'assets/images/girl-pic.png'
                              : 'assets/images/boy-pic.png',
                          height: 240,
                          width: 240,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Welcome, $_childName',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReportSelectionPage(
                                        childData: widget.childData
                                        ),
                                  ),
                                );
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
                              },
                            ),
                            const Divider(),
                            const SizedBox(height: 20),
                            CustomListTile(
                              icon: Icons.delete_forever,
                              title: "Delete Guardian Account",
                              onTap: _confirmDeleteAccount,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Guardian Account"),
        content: const Text(
            "Are you sure you want to permanently delete your account and all associated child data? This cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _deleteGuardianAccount();
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteGuardianAccount() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final uid = user.uid;
        final childrenSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('children')
            .get();

        for (final doc in childrenSnapshot.docs) {
          await doc.reference.delete();
        }

        await FirebaseFirestore.instance.collection('users').doc(uid).delete();

        await user.delete();

        Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error deleting account: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Failed to delete account. Please reauthenticate or try again."),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}
