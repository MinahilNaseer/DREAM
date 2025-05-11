import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dream/screens/mainmenu.dart';

class DysgraphiaReportPage extends StatelessWidget {
  final Map<String, dynamic> childData;
  final String childId;
  final String reportText;
  final DateTime? timestamp;

  const DysgraphiaReportPage({
    Key? key,
    required this.childData,
    required this.childId,
    required this.reportText,
    this.timestamp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade200,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => MainMenu(childData: childData),
              ),
              (Route<dynamic> route) => false,
            );
          },
        ),
        title: const Text(
          "Dysgraphia Report",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (timestamp != null)
                    Text(
                      "🕒 Report Generated: ${timestamp!.toLocal()}",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    reportText,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
