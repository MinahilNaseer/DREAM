import 'package:flutter/material.dart';
import 'package:dream/screens/GenericReportList.dart';
import 'package:dream/screens/dyscalculia_report.dart';

class DyscalculiaReportListPage extends StatelessWidget {
  final Map<String, dynamic> childData;
  final String childId;

  const DyscalculiaReportListPage({
    Key? key,
    required this.childData,
    required this.childId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GenericReportListPage(
      childData: childData,
      childId: childId,
      reportCollectionName: 'dyscalculia_reports',
      reportKey: 'report',
      appBarTitle: 'Dyscalculia Reports',
      appBarColor: Colors.purple,
      targetPageBuilder: (reportText, timestamp) => DyscalculiaReportPage(
        childData: childData,
        childId: childId,
        reportText: reportText,
        timestamp: timestamp,
      ),
    );
  }
}
