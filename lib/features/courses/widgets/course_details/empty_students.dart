import 'package:flutter/material.dart';

class EmptyStudents extends StatelessWidget {
  const EmptyStudents({
    super.key,
    this.message = 'No students found.',
    this.onImport,
  });

  final String message;
  final VoidCallback? onImport;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.school_outlined, size: 72, color: colors.outline),

            const SizedBox(height: 20),

            Text(message, style: text.titleMedium, textAlign: TextAlign.center),

            const SizedBox(height: 8),

            Text(
              'Import students into this course to start managing attendance.',
              style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),

            if (onImport != null) ...[
              const SizedBox(height: 24),

              FilledButton.icon(
                onPressed: onImport,
                icon: const Icon(Icons.upload_file_outlined),
                label: const Text('Import Students'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
