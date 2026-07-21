import 'package:attendance_management_system/features/students/models/student.dart';
import 'package:flutter/material.dart';

class DeleteStudentDialog extends StatelessWidget {
  const DeleteStudentDialog({
    super.key,
    required this.student,
    required this.onDelete,
  });

  final Student student;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    bool isDeleting = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          icon: const Icon(
            Icons.warning_amber_rounded,
            color: Colors.red,
            size: 40,
          ),
          title: const Text('Delete Student'),
          content: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium,
              children: [
                const TextSpan(
                  text: 'Are you sure you want to permanently delete\n\n',
                ),
                TextSpan(
                  text: student.fullName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: '\n'),
                TextSpan(
                  text: student.admissionNumber,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: '\n\nThis action cannot be undone.'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isDeleting ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: isDeleting
                  ? null
                  : () async {
                      setState(() {
                        isDeleting = true;
                      });

                      await onDelete();

                      if (!context.mounted) return;

                      Navigator.pop(context);
                    },
              icon: isDeleting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.delete),
              label: Text(isDeleting ? 'Deleting...' : 'Delete'),
            ),
          ],
        );
      },
    );
  }
}
