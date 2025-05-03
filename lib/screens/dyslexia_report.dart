import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dream/global.dart'; // includes currentSelectedChildId

class DyslexiaReportPage extends StatelessWidget {
  const DyslexiaReportPage({super.key});

  Future<String?> _fetchReportFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in.');
    if (currentSelectedChildId == null) throw Exception('No child selected.');

    final childDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('children')
        .doc(currentSelectedChildId)
        .get();

    if (!childDoc.exists) {
      throw Exception('Child document not found.');
    }

    // Get the report directly from Firestore
    final existingReport = childDoc.data()?['dyslexia_report'];
    if (existingReport != null) {
      return existingReport;
    }

    return "No report available yet.";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(
        backgroundColor: Colors.teal.shade300,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Dyslexia Report",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<String?>(
        future: _fetchReportFromFirestore(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  color: Colors.red.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Error: ${snapshot.error}",
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text("No report available."),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      snapshot.data!,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
