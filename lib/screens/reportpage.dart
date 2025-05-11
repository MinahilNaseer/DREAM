import 'package:flutter/material.dart';
import 'package:dream/screens/DyscalculiaReportList.dart';
import 'package:dream/screens/DysgraphiaReportList.dart';
import 'package:dream/screens/DyslexiaReportsList.dart';
import 'package:dream/widgets/ReportCard.dart';
import 'package:dream/utils/DialogUtils.dart';

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
            ReportCard(
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
                  DialogUtils.showError(context, "Child data is missing!");
                }
              },
            ),
            const SizedBox(height: 16),
            ReportCard(
              title: "Dysgraphia Report",
              onTap: () {
                if (childData != null && childData!['childId'] != null) {
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
                  DialogUtils.showError(context, "Child data is missing!");
                }
              },
            ),
            const SizedBox(height: 16),
            ReportCard(
              title: "Dyslexia Report",
              onTap: () {
                if (childData != null && childData!['childId'] != null) {
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
                  DialogUtils.showError(context, "Child data is missing!");
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
