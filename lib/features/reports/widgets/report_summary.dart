import 'package:flutter/material.dart';

import 'package:attendance_management_system/features/reports/models/attendance_report.dart';
import 'package:attendance_management_system/features/reports/widgets/report_summary_item.dart';

class ReportSummary extends StatelessWidget {
  final AttendanceReport report;

  const ReportSummary({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ReportSummaryItem(label: 'Students', value: '${report.totalStudents}'),
        ReportSummaryItem(label: 'Sessions', value: '${report.totalSessions}'),
        ReportSummaryItem(
          label: 'Attendance',
          value: '${report.attendancePercentage.toStringAsFixed(1)}%',
        ),
      ],
    );
  }
}
