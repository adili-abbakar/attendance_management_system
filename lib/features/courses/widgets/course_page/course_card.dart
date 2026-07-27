import 'package:flutter/material.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({
    super.key,
    required this.code,
    required this.title,
    required this.level,
    required this.semester,
    required this.session,
    required this.studentCount,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final String code;
  final String title;

  /// Display name from the joined Level table.
  final String level;

  final int semester;

  /// Display name from the joined Academic Session table.
  final String session;

  final int studentCount;

  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              code,
              style: text.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Text(
              title,
              style: text.bodyLarge,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const Divider(height: 28),

            _InfoRow(icon: Icons.school_outlined, label: 'Level', value: level),

            const SizedBox(height: 10),

            _InfoRow(
              icon: Icons.menu_book_outlined,
              label: 'Semester',
              value: semester == 1 ? 'First Semester' : 'Second Semester',
            ),

            const SizedBox(height: 10),

            _InfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Session',
              value: session,
            ),

            const SizedBox(height: 10),

            _InfoRow(
              icon: Icons.people_outline,
              label: 'Students',
              value: studentCount.toString(),
              valueColor: colors.primary,
            ),

            const Spacer(),

            const Divider(),

            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Details'),
                ),

                const SizedBox(width: 8),

                IconButton(
                  tooltip: 'Edit',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),

                IconButton(
                  tooltip: 'Delete',
                  onPressed: onDelete,
                  color: colors.error,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 18, color: colors.primary),
        const SizedBox(width: 10),

        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),

        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: valueColor != null
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
