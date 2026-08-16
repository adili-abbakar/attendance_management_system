import 'package:flutter/material.dart';

import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:attendance_management_system/features/attendance/attendance/results/attendance_result.dart';

class AttendanceScanResultDialog extends StatelessWidget {
  const AttendanceScanResultDialog({
    super.key,
    required this.result,
    this.studentName,
  });

  final AttendanceResult result;
  final String? studentName;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);
    final theme = Theme.of(context);

    final isSuccess = result.isSuccess;
    final isDuplicate = result.isAlreadyAttended;

    final title = isSuccess
        ? 'Attendance Recorded'
        : isDuplicate
        ? 'Already Recorded'
        : 'Attendance Not Recorded';

    final icon = isSuccess
        ? Icons.check_circle_outline
        : isDuplicate
        ? Icons.info_outline
        : Icons.error_outline;

    return AlertDialog(
      insetPadding: EdgeInsets.all(r.dialogInset),
      title: Row(
        children: [
          Icon(icon, size: r.iconMedium),
          SizedBox(width: r.spacingS),
          Expanded(
            child: Text(title, style: TextStyle(fontSize: r.titleLarge)),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: r.dialogWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (result.student != null) ...[
              if (studentName != null && studentName!.isNotEmpty) ...[
                Text(
                  studentName!,
                  style: TextStyle(
                    fontSize: r.titleMedium,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: r.spacingXS),
              ],
              Text(
                result.student!.admissionNumber,
                style: TextStyle(
                  fontSize: r.body,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: r.spacingM),
            ],
            Text(result.message ?? '', style: TextStyle(fontSize: r.body)),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
