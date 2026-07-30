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
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.school_outlined,
              size: 56,
              color: colors.outline,
            ),

            const SizedBox(height: 14),

            Text(
              message,
              textAlign: TextAlign.center,
              style: text.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Import students into this course to start managing attendance.',
              textAlign: TextAlign.center,
              style: text.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),

            if (onImport != null) ...[
              const SizedBox(height: 18),

              FilledButton.icon(
                onPressed: onImport,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 40),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(
                  Icons.upload_file_outlined,
                  size: 18,
                ),
                label: const Text("Import Students"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}