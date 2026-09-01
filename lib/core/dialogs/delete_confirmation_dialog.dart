import 'package:attendance_management_system/core/buttons/buttons.dart';
import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:flutter/material.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  const DeleteConfirmationDialog({
    super.key,
    required this.title,
    required this.itemName,
    required this.onDelete,
    this.description,
    this.deleteButtonText = 'Delete',
    this.cancelButtonText = 'Cancel',
    this.icon = Icons.warning_amber_rounded,
  });

  final String title;
  final String itemName;
  final String? description;

  final VoidCallback onDelete;

  final String deleteButtonText;
  final String cancelButtonText;

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: r.dialogInset,
        vertical: r.dialogInset,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(r.radius),
      ),
      contentPadding: EdgeInsets.all(r.dialogPadding),

      icon: Icon(icon, color: colors.error, size: r.iconLarge),

      title: Text(
        title,
        textAlign: TextAlign.center,
        style: theme.textTheme.titleLarge?.copyWith(
          fontSize: r.titleLarge,
          fontWeight: FontWeight.bold,
        ),
      ),

      content: SizedBox(
        width: r.isPhone ? null : r.dialogWidth,
        child: Text.rich(
          TextSpan(
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: r.body,
              color: colors.onSurface,
            ),
            children: [
              const TextSpan(text: 'Are you sure you want to delete\n\n'),

              TextSpan(
                text: '"$itemName"',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),

              if (description != null) ...[
                TextSpan(text: '\n\n$description'),
              ] else ...[
                const TextSpan(text: '?\n\nThis action cannot be undone.'),
              ],
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),

      actionsAlignment: MainAxisAlignment.end,

      actions: [
        AppTextButton(
          text: cancelButtonText,
          onPressed: () => Navigator.pop(context),
        ),

        DangerButton(
          width: 120,
          text: deleteButtonText,
          icon: Icons.delete_outline_rounded,
          onPressed: () {
            Navigator.pop(context);
            onDelete();
          },
        ),
      ],
    );
  }
}
