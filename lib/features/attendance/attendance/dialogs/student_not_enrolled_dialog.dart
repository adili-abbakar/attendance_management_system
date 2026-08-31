import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:attendance_management_system/features/attendance/attendance/widgets/attendance_dialog_action.dart';
import 'package:attendance_management_system/features/students/models/student.dart';
import 'package:flutter/material.dart';

class StudentNotEnrolledDialog extends StatelessWidget {
  const StudentNotEnrolledDialog({super.key, required this.student});

  final Student student;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);
    final theme = Theme.of(context);

    return AlertDialog(
      icon: Icon(
        Icons.warning_amber_rounded,
        size: r.iconLarge,
        color: theme.colorScheme.error,
      ),
      title: Text(
        'Student Not Enrolled',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.error,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'This student exists in the system, but is NOT enrolled in this course.',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: r.body),
          ),
          SizedBox(height: r.spacingM),
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
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
          SizedBox(height: r.spacingM),
          const Text(
            'Choose what you want to do with this student.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, AttendanceDialogAction.done);
          },
          child: const Text('Ignore'),
        ),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.pop(context, AttendanceDialogAction.scanNext);
          },
          icon: const Icon(Icons.qr_code_scanner),
          label: const Text('Scan Next'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context, AttendanceDialogAction.addToCourse);
          },
          child: const Text('Add to Course'),
        ),
        FilledButton.icon(
          onPressed: () {
            Navigator.pop(context, AttendanceDialogAction.recordAndScanNext);
          },
          icon: const Icon(Icons.check),
          label: const Text('Record & Scan Next'),
        ),
      ],
    );
  }
}
