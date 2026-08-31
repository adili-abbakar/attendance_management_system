import 'package:flutter/material.dart';

class AttendanceErrorDialog extends StatelessWidget {
  const AttendanceErrorDialog({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.error_outline),
      title: const Text('Operation Failed', textAlign: TextAlign.center),
      content: Text(message, textAlign: TextAlign.center),
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
