import 'package:flutter/material.dart';
import 'package:dream/screens/GenericReportList.dart';
import 'package:dream/screens/dysgraphia_report.dart';

class DysgraphiaReportListPage extends StatelessWidget {
  final Map<String, dynamic> childData;
  final String childId;

  const DysgraphiaReportListPage({
    Key? key,
    required this.childData,
    required this.childId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GenericReportListPage(
      childData: childData,
      childId: childId,
      reportCollectionName: 'dysgraphia_reports',
      reportKey: 'report',
      appBarTitle: 'Dysgraphia Reports',
      appBarColor: Colors.blueAccent,
      targetPageBuilder: (reportText, timestamp) => DysgraphiaReportPage(
        childData: childData,
        childId: childId,
        reportText: reportText,
        timestamp: timestamp,
      ),
    );
  }
}
