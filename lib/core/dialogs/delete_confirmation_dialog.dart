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
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return AlertDialog(
      insetPadding: EdgeInsets.all(r.dialogInset),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(r.radius),
      ),

      contentPadding: EdgeInsets.all(r.dialogPadding),

      icon: Icon(icon, color: colors.error, size: r.iconLarge),

      title: Text(
        title,
        textAlign: TextAlign.center,
        style: text.titleLarge?.copyWith(
          fontSize: r.titleLarge,
          fontWeight: FontWeight.bold,
        ),
      ),

      content: Text.rich(
        TextSpan(
          style: text.bodyMedium?.copyWith(
            fontSize: r.body,
            color: colors.onSurface,
          ),
          children: [
            const TextSpan(text: 'Are you sure you want to delete\n\n'),

            TextSpan(
              text: '"$itemName"',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const TextSpan(text: '?\n\nThis action cannot be undone.'),
          ],
        ),
        textAlign: TextAlign.center,
      ),

      actionsAlignment: MainAxisAlignment.end,

      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(cancelButtonText, style: TextStyle(fontSize: r.body)),
        ),

        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: colors.error,
            foregroundColor: colors.onError,
            minimumSize: Size(0, r.buttonHeight),
            padding: EdgeInsets.symmetric(horizontal: r.spacingL),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(r.radius),
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
            onDelete();
          },
          child: Text(deleteButtonText, style: TextStyle(fontSize: r.body)),
        ),
      ],
    );
  }
}
