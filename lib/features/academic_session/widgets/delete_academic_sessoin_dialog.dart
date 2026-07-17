import 'package:attendance_management_system/data/models/academic_session.dart';
import 'package:flutter/material.dart';

class DeleteAcademicSessionDialog extends StatelessWidget {
  const DeleteAcademicSessionDialog({
    super.key,
    required this.academicSession,
    required this.onDelete,
  });

  final AcademicSession academicSession;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.delete_outline, size: 48, color: Colors.red),

      title: const Text("Delete session"),

      content: Text(
        'Are you sure you want to delete "${academicSession.name} "?\n\n'
        'This action cannot be undone.',
      ),

      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),

        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {
            Navigator.pop(context);
            onDelete();
          },
          child: const Text("Delete"),
        ),
      ],
    );
  }
}
