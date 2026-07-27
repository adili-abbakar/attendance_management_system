import 'package:flutter/material.dart';

class CourseActionsBar extends StatelessWidget {
  const CourseActionsBar({
    super.key,
    required this.onImportStudents,
    required this.onAddStudent,
    required this.onRefresh,
  });

  final VoidCallback onImportStudents;
  final VoidCallback onAddStudent;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.spaceBetween,
          children: [
            FilledButton.icon(
              onPressed: onImportStudents,
              icon: const Icon(Icons.upload_file_outlined),
              label: const Text('Import Students'),
            ),

            OutlinedButton.icon(
              onPressed: onAddStudent,
              icon: const Icon(Icons.person_add_alt_1_outlined),
              label: const Text('Add Student'),
            ),

            OutlinedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}
