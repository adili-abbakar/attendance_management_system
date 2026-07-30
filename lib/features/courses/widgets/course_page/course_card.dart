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
  final String level;
  final int semester;
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
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                code,
                style: text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 4),

              Text(
                title,
                style: text.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const Divider(height: 20),

              _InfoRow(
                icon: Icons.school_outlined,
                label: 'Level',
                value: level,
              ),

              const SizedBox(height: 6),

              _InfoRow(
                icon: Icons.menu_book_outlined,
                label: 'Semester',
                value: semester == 1 ? 'First Semester' : 'Second Semester',
              ),

              const SizedBox(height: 6),

              _InfoRow(
                icon: Icons.calendar_today_outlined,
                label: 'Session',
                value: session,
              ),

              const SizedBox(height: 6),

              _InfoRow(
                icon: Icons.people_outline,
                label: 'Students',
                value: studentCount.toString(),
                valueColor: colors.primary,
              ),

              const Spacer(),

              const Divider(height: 18),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onTap,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 40),
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                      ),
                      icon: const Icon(Icons.visibility_outlined, size: 18),
                      label: const Text("Details"),
                    ),
                  ),

                  const SizedBox(width: 6),

                  IconButton(
                    tooltip: 'Edit',
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 20),
                  ),

                  IconButton(
                    tooltip: 'Delete',
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    onPressed: onDelete,
                    color: colors.error,
                    icon: const Icon(Icons.delete_outline, size: 20),
                  ),
                ],
              ),
            ],
          ),
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
    final text = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icon, size: 16, color: colors.primary),

        const SizedBox(width: 8),

        SizedBox(
          width: 72,
          child: Text(
            '$label:',
            style: text.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),

        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: text.bodySmall?.copyWith(
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
