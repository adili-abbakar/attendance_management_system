import 'package:attendance_management_system/features/courses/models/course.dart';
import 'package:flutter/material.dart';

class CourseHeader extends StatelessWidget {
  const CourseHeader({super.key, required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor: colors.primaryContainer,
              child: Icon(
                Icons.menu_book_rounded,
                size: 34,
                color: colors.primary,
              ),
            ),

            const SizedBox(width: 20),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.code,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(course.title, style: theme.textTheme.titleMedium),

                  const SizedBox(height: 20),

                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _InfoChip(
                        icon: Icons.school_outlined,
                        label: course.levelName ?? '-',
                      ),
                      _InfoChip(
                        icon: Icons.calendar_today_outlined,
                        label: 'Semester ${course.semester}',
                      ),
                      _InfoChip(
                        icon: Icons.event_note_outlined,
                        label: course.academicSessionName ?? '-',
                      ),
                      _InfoChip(
                        icon: course.isActive
                            ? Icons.check_circle_outline
                            : Icons.cancel_outlined,
                        label: course.isActive ? 'Active' : 'Inactive',
                        color: course.isActive ? Colors.green : Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color ?? colors.primary),

          const SizedBox(width: 8),

          Text(label),
        ],
      ),
    );
  }
}
