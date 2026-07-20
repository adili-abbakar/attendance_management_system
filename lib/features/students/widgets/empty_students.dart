import 'package:flutter/material.dart';

class EmptyStudents extends StatelessWidget {
  const EmptyStudents({
    super.key,
    required this.onAddStudent,
  });

  final VoidCallback onAddStudent;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.groups_outlined,
              size: 90,
              color: colors.primary,
            ),

            const SizedBox(height: 24),

            Text(
              'No Students Found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),

            const SizedBox(height: 12),

            Text(
              'Add students manually or import them from an Excel file to begin managing attendance.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 32),

            FilledButton.icon(
              onPressed: onAddStudent,
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Add Student'),
            ),
          ],
        ),
      ),
    );
  }
}