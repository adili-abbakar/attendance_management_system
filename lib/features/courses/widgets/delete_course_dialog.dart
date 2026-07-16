import 'package:attendance_management_system/data/models/course.dart';
import 'package:flutter/material.dart';

class DeleteCourseDialog extends StatelessWidget {
  const DeleteCourseDialog({
    super.key,
    required this.course,
    required this.onDelete,
  });

  final Course course;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.delete_outline, size: 48, color: Colors.red),

      title: const Text("Delete Course"),

      content: Text(
        'Are you sure you want to delete "${course.code} - ${course.title}"?\n\n'
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
