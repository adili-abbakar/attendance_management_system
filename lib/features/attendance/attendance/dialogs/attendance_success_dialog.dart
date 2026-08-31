import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:attendance_management_system/features/attendance/attendance/widgets/attendance_dialog_action.dart';
import 'package:attendance_management_system/features/students/models/student.dart';
import 'package:flutter/material.dart';

class AttendanceSuccessDialog extends StatelessWidget {
  const AttendanceSuccessDialog({super.key, required this.student});

  final Student student;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);
    final theme = Theme.of(context);

    return AlertDialog(
      icon: Icon(
        Icons.check_circle,
        size: r.iconLarge,
        color: theme.colorScheme.primary,
      ),
      title: const Text('Attendance Recorded', textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            student.fullName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: r.titleLarge,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: r.spacingXS),
          Text(
            student.admissionNumber,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: r.body,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: r.spacingM),
          const Text(
            'Attendance has been successfully recorded.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        OutlinedButton(
          onPressed: () {
            Navigator.pop(context, AttendanceDialogAction.done);
          },
          child: const Text('Done'),
        ),
        FilledButton.icon(
          onPressed: () {
            Navigator.pop(context, AttendanceDialogAction.scanNext);
          },
          icon: const Icon(Icons.qr_code_scanner),
          label: const Text('Scan Next'),
        ),
      ],
    );
  }
}
