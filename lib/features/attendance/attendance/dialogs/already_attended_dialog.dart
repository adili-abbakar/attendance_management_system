import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:attendance_management_system/features/attendance/attendance/widgets/attendance_dialog_action.dart';
import 'package:attendance_management_system/features/students/models/student.dart';
import 'package:flutter/material.dart';

class AlreadyAttendedDialog extends StatelessWidget {
  const AlreadyAttendedDialog({
    super.key,
    required this.student,
    required this.message,
  });

  final Student? student;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);

    return AlertDialog(
      icon: Icon(Icons.info_outline, size: r.iconLarge),
      title: const Text('Already Recorded', textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (student != null) ...[
            Text(
              student!.fullName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: r.titleLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: r.spacingXS),
            Text(student!.admissionNumber, textAlign: TextAlign.center),
            SizedBox(height: r.spacingM),
          ],
          Text(
            message ?? 'Attendance has already been recorded for this student.',
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
