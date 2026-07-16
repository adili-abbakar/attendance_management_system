import 'package:flutter/material.dart';

class DeleteCourseDialog extends StatelessWidget {
  const DeleteCourseDialog({
    super.key,
    required this.courseTitle,
    required this.onDelete,
  });

  final String courseTitle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.delete_outline, size: 48, color: Colors.red),

      title: const Text("Delete Course"),

      content: Text(
        'Are you sure you want to delete "$courseTitle"?\n\n'
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
