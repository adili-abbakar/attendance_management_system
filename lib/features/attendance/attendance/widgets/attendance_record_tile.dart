import 'package:flutter/material.dart';

import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:attendance_management_system/features/attendance/attendance/models/attendance_record.dart';

class AttendanceRecordTile extends StatelessWidget {
  const AttendanceRecordTile({
    super.key,
    required this.record,
    required this.studentName,
    required this.admissionNumber,
  });

  final AttendanceRecord record;
  final String studentName;
  final String admissionNumber;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);

    return Card(
      margin: EdgeInsets.only(bottom: r.spacingS),
      child: Padding(
        padding: EdgeInsets.all(r.cardPadding),
        child: Row(
          children: [
            CircleAvatar(
              radius: r.avatarRadius * 0.65,
              child: Icon(Icons.person, size: r.iconMedium),
            ),
            SizedBox(width: r.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    studentName,
                    style: TextStyle(
                      fontSize: r.titleMedium,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: r.spacingXS),
                  Text(
                    admissionNumber,
                    style: TextStyle(
                      fontSize: r.bodySmall,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: r.spacingM),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  record.status.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: r.bodySmall,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: r.spacingXS),
                Text(
                  _formatTime(record.scannedAt),
                  style: TextStyle(
                    fontSize: r.caption,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }
}
