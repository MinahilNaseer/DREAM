import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GenericReportListPage extends StatelessWidget {
  final Map<String, dynamic> childData;
  final String childId;
  final String reportCollectionName;
  final String reportKey;
  final String appBarTitle;
  final Color appBarColor;
  final Widget Function(String reportText, DateTime? timestamp) targetPageBuilder;

  const GenericReportListPage({
    Key? key,
    required this.childData,
    required this.childId,
    required this.reportCollectionName,
    required this.reportKey,
    required this.appBarTitle,
    required this.appBarColor,
    required this.targetPageBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle,style: const TextStyle(
          color: Colors.white,
        ),),
        backgroundColor: appBarColor,
        
      ),
      backgroundColor: const Color(0xFFF4F4F4),
      body: uid == null
          ? const Center(child: Text("User not authenticated"))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('children')
                  .doc(childId)
                  .collection(reportCollectionName)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
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
                    final reportData =
                        reports[index].data() as Map<String, dynamic>;
                    final String reportText =
                        reportData[reportKey] ?? 'No report text.';
                    final Timestamp? timestamp = reportData['timestamp'];

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => targetPageBuilder(
                              reportText,
                              timestamp?.toDate(),
                            ),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Report #${reports.length - index}",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: appBarColor,
                                ),
                              ),
                              if (timestamp != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    "Generated: ${timestamp.toDate()}",
                                    style: const TextStyle(
                                        fontSize: 13, color: Colors.grey),
                                  ),
                                ),
                              const SizedBox(height: 12),
                              Text(
                                reportText,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
