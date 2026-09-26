import 'package:attendance_management_system/core/buttons/app_outlined_button.dart';
import 'package:attendance_management_system/core/buttons/danger_button.dart';
import 'package:flutter/material.dart';

class AcademicSessionCard extends StatelessWidget {
  const AcademicSessionCard({
    super.key,
    required this.name,
    required this.onEdit,
    required this.onDelete, required Null Function() onTap,
  });

  final String name;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      color: colors.surfaceBright,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: colors.primaryContainer,
              child: Icon(
                Icons.school_rounded,
                color: colors.primary,
                size: 20,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 6),

            const Divider(height: 1),

            const SizedBox(height: 6),

            Row(
              children: [
                Expanded(
                  child: AppOutlinedButton(
                    text: 'Edit',
                    icon: Icons.edit_outlined,
                    onPressed: onEdit,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DangerButton(
                    text: 'Delete',
                    icon: Icons.delete_outline,
                    onPressed: onDelete,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
