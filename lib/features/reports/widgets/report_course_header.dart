import 'package:flutter/material.dart';

import 'package:attendance_management_system/features/reports/models/attendance_report.dart';

class ReportCourseHeader extends StatelessWidget {
  final AttendanceReport report;

  const ReportCourseHeader({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          report.courseCode ?? 'Course',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(
          report.courseTitle ?? '',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}