import 'package:flutter/material.dart';

import 'package:attendance_management_system/features/reports/models/attendance_report.dart';

class ReportSessionTile extends StatelessWidget {
  final LectureSessionReport session;

  const ReportSessionTile({
    super.key,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    final date = session.lectureDate;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text('${session.sessionNumber}'),
        ),
        title: Text(
          'Session ${session.sessionNumber}',
        ),
        subtitle: Text(
          '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year} • '
          '${session.fromTime} - ${session.toTime}',
        ),
        trailing: Text(
          '${session.attendancePercentage.toStringAsFixed(1)}%',
        ),
      ),
    );
  }
}

