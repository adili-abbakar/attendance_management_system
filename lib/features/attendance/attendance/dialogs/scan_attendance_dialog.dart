import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:flutter/material.dart';

enum AttendanceScanAction { verify, record }

class ScanAttendanceDialog extends StatelessWidget {
  const ScanAttendanceDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
final screenWidth = MediaQuery.sizeOf(context).width;

    final availableWidth = screenWidth - (r.dialogInset * 2);

    final dialogWidth = availableWidth < r.dialogWidth
        ? availableWidth
        : r.dialogWidth;

    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: r.dialogInset,
        vertical: r.dialogInset,
      ),
      title: Text(
        'Scan QR',
        style: theme.textTheme.titleLarge?.copyWith(
          fontSize: r.titleLarge,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SizedBox(
        width: dialogWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'What would you like to do?',
                style: TextStyle(
                  fontSize: r.body,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
            SizedBox(height: r.spacingM),
            _ActionOption(
              icon: Icons.fact_check_outlined,
              title: 'Verify Attendance',
              description:
                  'Check a student\'s attendance percentage for a course.',
              onTap: () => Navigator.pop(context, AttendanceScanAction.verify),
            ),
            SizedBox(height: r.spacingS),
            _ActionOption(
              icon: Icons.how_to_reg_outlined,
              title: 'Record Attendance',
              description: 'Record attendance for a selected lecture session.',
              onTap: () => Navigator.pop(context, AttendanceScanAction.record),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

class _ActionOption extends StatelessWidget {
  const _ActionOption({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: colors.surfaceBright,
      borderRadius: BorderRadius.circular(r.radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(r.radius),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(r.cardPadding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(r.radius),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(r.spacingS),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(r.radius),
                ),
                child: Icon(icon, size: r.iconMedium, color: colors.primary),
              ),
              SizedBox(width: r.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: r.titleMedium,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                    SizedBox(height: r.spacingXS),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: r.bodySmall,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
