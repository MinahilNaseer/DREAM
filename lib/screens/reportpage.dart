import 'package:flutter/material.dart';
import 'package:dream/screens/DyscalculiaReportList.dart';
import 'package:dream/screens/dysgraphia_report.dart';
import 'package:dream/screens/dyslexia_report.dart';
import 'DysgraphiaReportList.dart';
import 'DyslexiaReportsList.dart';

class ReportSelectionPage extends StatelessWidget {
  final Map<String, dynamic>? childData;
  const ReportSelectionPage({super.key, this.childData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 225, 225),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 240, 225, 225),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.purple, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Reports",
          style: TextStyle(
            color: Colors.purple,
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildReportCard(
              context,
              title: "Dyscalculia Report",
              onTap: () {
                if (childData != null && childData!['childId'] != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DyscalculiaReportListPage(
                        childData: childData!,
                        childId: childData!['childId'],
                      ),
                    ),
                  );
                } else {
                  _showErrorDialog(context, "Child data is missing!");
                }
              },
            ),
            const SizedBox(height: 16),
            _buildReportCard(
              context,
              title: "Dysgraphia Report",
              onTap: () {
                if (childData != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DysgraphiaReportListPage(
                        childData: childData!,
                        childId: childData!['childId'],
                      ),
                    ),
                  );
                } else {
                  _showErrorDialog(context, "Child data is missing!");
                }
              },
            ),
            const SizedBox(height: 16),
            _buildReportCard(
              context,
              title: "Dyslexia Report",
              onTap: () {
                if (childData != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DyslexiaReportsListPage(
                        childData: childData!,
                        childId: childData!['childId'],
                      ),
                    ),
                  );
                } else {
                  _showErrorDialog(context, "Child data is missing!");
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(BuildContext context,
      {required String title, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.purple.shade50,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.purple,
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.purple),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }
}
