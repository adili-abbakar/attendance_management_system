import 'package:attendance_management_system/features/levels/models/level.dart';
import 'package:flutter/material.dart';

class DeleteLevelDialog extends StatelessWidget {
  const DeleteLevelDialog({
    super.key,
    required this.level,
    required this.onDelete,
  });

  final Level level;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.delete_outline, size: 48, color: Colors.red),

      title: const Text("Delete Level"),

      content: Text(
        'Are you sure you want to delete "${level.name} "?\n\n'
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
