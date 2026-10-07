import 'package:attendance_management_system/features/courses/models/course.dart';
import 'package:flutter/material.dart';

class ReportFilterBar extends StatelessWidget {
  final Course? selectedCourse;
  final VoidCallback onSelectCourse;
  final VoidCallback onGenerate;

  const ReportFilterBar({
    super.key,
    required this.selectedCourse,
    required this.onSelectCourse,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      color: colors.surfaceBright,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Report Filters', style: theme.textTheme.titleMedium),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: onSelectCourse,
              icon: const Icon(Icons.menu_book_outlined),
              label: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  selectedCourse == null
                      ? 'Select Course'
                      : '${selectedCourse!.code} — ${selectedCourse!.title}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            const SizedBox(height: 12),

            FilledButton.icon(
              onPressed: selectedCourse == null ? null : onGenerate,
              icon: const Icon(Icons.assessment_outlined),
              label: const Text('Generate Report'),
            ),
          ],
        ),
      ),
    );
  }
}
