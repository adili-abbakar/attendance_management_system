import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:attendance_management_system/features/attendance/attendance/widgets/attendance_dialog_action.dart';
import 'package:attendance_management_system/features/students/models/student.dart';
import 'package:flutter/material.dart';

class StudentEnrolledDialog extends StatelessWidget {
  const StudentEnrolledDialog({super.key, required this.student});

  final Student student;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);
    final theme = Theme.of(context);

    return AlertDialog(
      icon: Icon(
        Icons.person_add_alt_1,
        size: r.iconLarge,
        color: theme.colorScheme.primary,
      ),
      title: const Text('Student Added', textAlign: TextAlign.center),
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
          SizedBox(height: r.spacingM),
          const Text(
            'The student has been successfully enrolled in this course.',
            textAlign: TextAlign.center,
          ),
          SizedBox(height: r.spacingS),
          Text(
            'Attendance was NOT recorded for this lecture.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: r.bodySmall,
              color: theme.colorScheme.onSurfaceVariant,
            ),
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
