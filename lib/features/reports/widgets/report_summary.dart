import 'package:attendance_management_system/features/dashboard/widgets/stat_card.dart';
import 'package:flutter/material.dart';

import 'package:attendance_management_system/features/reports/models/attendance_report.dart';

class ReportSummary extends StatelessWidget {
  final AttendanceReport report;

  const ReportSummary({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        StatCard(title: 'Students', value: '${report.totalStudents}'),
        StatCard(title: 'Sessions', value: '${report.totalSessions}'),
        StatCard(
          title: 'Attendance',
          value: '${report.attendancePercentage.toStringAsFixed(1)}%',
        ),
      ],
    );
  }
}
