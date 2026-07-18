import 'package:flutter/material.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({
    super.key,
    required this.code,
    required this.title,
    required this.level,
    required this.semester,
    required this.session,
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

  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: colors.primaryContainer,
                    child: Icon(Icons.menu_book_rounded, color: colors.primary),
                  ),

                  const Spacer(),

                  PopupMenuButton(
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        onTap: onEdit,
                        child: const Row(
                          children: [
                            Icon(Icons.edit_outlined),
                            SizedBox(width: 10),
                            Text("Edit"),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        onTap: onDelete,
                        child: const Row(
                          children: [
                            Icon(Icons.delete_outline),
                            SizedBox(width: 10),
                            Text("Delete"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Text(
                code,
                style: text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 6),

              Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),

              const Spacer(),

              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  Chip(
                    avatar: const Icon(Icons.school_outlined, size: 18),
                    label: Text(level),
                  ),
                  Chip(
                    avatar: const Icon(Icons.calendar_today_outlined, size: 18),
                    label: Text("Semester $semester"),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  const Icon(Icons.event_note_outlined, size: 18),

                  const SizedBox(width: 6),

                  Expanded(
                    child: Text(
                      session,
                      style: text.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
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
