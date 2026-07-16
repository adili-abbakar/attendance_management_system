import 'package:flutter/material.dart';

class LevelCard extends StatelessWidget {
  const LevelCard({
    super.key,
    required this.name,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final String name;

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
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: colors.primaryContainer,

                    child: Icon(Icons.school_rounded, color: colors.primary),
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

              const SizedBox(height: 10),

              Text(
                name,
                style: text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
