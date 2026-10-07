import 'package:flutter/material.dart';

import 'package:attendance_management_system/features/reports/models/attendance_report.dart';
import 'package:attendance_management_system/features/reports/widgets/report_session_tile.dart';

class ReportSessionSection extends StatelessWidget {
  final List<LectureSessionReport> sessions;

  const ReportSessionSection({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Lecture Sessions', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        if (sessions.isEmpty)
          const Text('No lecture sessions found.')
        else
          ...sessions.map((session) => ReportSessionTile(session: session)),
      ],
    );
  }
}
