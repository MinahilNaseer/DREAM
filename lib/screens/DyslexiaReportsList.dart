import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DyslexiaReportsListPage extends StatelessWidget {
  final Map<String, dynamic> childData;
  final String childId;

  const DyslexiaReportsListPage({
    Key? key,
    required this.childData,
    required this.childId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final reportsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('children')
        .doc(childId)
        .collection('dyslexia_reports')
        .orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dyslexia Reports',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        //centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF1F6F9),
      body: StreamBuilder<QuerySnapshot>(
        stream: reportsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No reports generated yet."));
          }

          final reports = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final reportData = reports[index].data() as Map<String, dynamic>;
              final reportText = reportData['report_text'] ?? 'No report text.';
              final timestamp = reportData['createdAt'] as Timestamp?;
              final formattedDate = timestamp != null
                  ? DateFormat('yyyy-MM-dd – hh:mm a')
                      .format(timestamp.toDate())
                  : 'Date unknown';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(color: Colors.teal.shade100, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.insert_drive_file, color: Colors.teal),
                        const SizedBox(width: 8),
                        Text(
                          "Report #${reports.length - index}",
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.teal,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          formattedDate,
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.person_outline,
                            size: 18, color: Colors.black54),
                        const SizedBox(width: 6),
                        const Text(
                          "Child's Name:",
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                       const  SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            childData['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: const [
                        Icon(Icons.bar_chart_rounded,
                            size: 18, color: Colors.black54),
                        SizedBox(width: 6),
                        Text("Test Overview:",
                            style:
                                TextStyle(fontSize: 14, color: Colors.black54)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      reportText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 15, height: 1.4),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text("Report #${reports.length - index}"),
                              content: SingleChildScrollView(
                                  child: Text(reportText)),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Close"),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.visibility_outlined,
                            color: Colors.teal),
                        label: const Text("View Full Report",
                            style: TextStyle(color: Colors.teal)),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
