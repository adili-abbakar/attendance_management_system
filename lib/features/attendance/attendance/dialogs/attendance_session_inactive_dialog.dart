import 'package:flutter/material.dart';

class AttendanceSessionInactiveDialog extends StatelessWidget {
  const AttendanceSessionInactiveDialog({super.key, required this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.lock_outline),
      title: const Text('Attendance Session Inactive'),
      content: Text(
        message ?? 'This lecture session is not active.',
        textAlign: TextAlign.center,
      ),
      actions: [
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
