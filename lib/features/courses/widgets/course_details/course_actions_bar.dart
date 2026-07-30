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
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.spaceBetween,
          children: [
            FilledButton.icon(
              onPressed: onImportStudents,
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 40),
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              icon: const Icon(
                Icons.upload_file_outlined,
                size: 18,
              ),
              label: const Text("Import Students"),
            ),

            OutlinedButton.icon(
              onPressed: onAddStudent,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 40),
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              icon: const Icon(
                Icons.person_add_alt_1_outlined,
                size: 18,
              ),
              label: const Text("Add Student"),
            ),

            OutlinedButton.icon(
              onPressed: onRefresh,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 40),
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              icon: const Icon(
                Icons.refresh,
                size: 18,
              ),
              label: const Text("Refresh"),
            ),
          ],
        ),
      ),
    );
  }
}