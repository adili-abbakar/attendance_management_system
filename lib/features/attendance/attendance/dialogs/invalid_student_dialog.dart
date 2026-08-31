import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:attendance_management_system/features/attendance/attendance/widgets/attendance_dialog_action.dart';
import 'package:flutter/material.dart';

class InvalidStudentDialog extends StatelessWidget {
  const InvalidStudentDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);

    return AlertDialog(
      icon: Icon(Icons.person_off_outlined, size: r.iconLarge),
      title: const Text(
        'Invalid Admission Number',
        textAlign: TextAlign.center,
      ),
      content: const Text(
        'No student was found with this admission number.',
        textAlign: TextAlign.center,
      ),
      actions: [
        OutlinedButton(
          onPressed: () {
            Navigator.pop(context, AttendanceDialogAction.done);
          },
          child: const Text('Close'),
        ),
        FilledButton.icon(
          onPressed: () {
            Navigator.pop(context, AttendanceDialogAction.scanNext);
          },
          icon: const Icon(Icons.qr_code_scanner),
          label: const Text('Scan Again'),
        ),
      ],
    );
  }
}
