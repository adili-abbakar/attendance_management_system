import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/models/lecture_session.dart';
import 'package:flutter/material.dart';

class ActiveAttendanceHeader extends StatelessWidget {
  const ActiveAttendanceHeader({
    super.key,
    required this.lectureSession,
    required this.courseName,
    required this.courseCode,
    required this.attendanceCount,
  });

  final LectureSession lectureSession;
  final String courseName;
  final String courseCode;
  final int attendanceCount;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(r.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$courseName ($courseCode) – '
              '${lectureSession.lectureSessionName}',
              style: TextStyle(
                fontSize: r.titleLarge,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: r.spacingS),
            Text(
              '${lectureSession.fromTime} – ${lectureSession.toTime}',
              style: TextStyle(fontSize: r.body),
            ),
            SizedBox(height: r.spacingXS),
            Text(
              'Week ${lectureSession.weekNumber}',
              style: TextStyle(
                fontSize: r.bodySmall,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: r.spacingM),
            Row(
              children: [
                Icon(Icons.people_outline, size: r.iconSmall),
                SizedBox(width: r.spacingXS),
                Text(
                  '$attendanceCount students present',
                  style: TextStyle(
                    fontSize: r.body,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
