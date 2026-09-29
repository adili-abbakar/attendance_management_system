import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/models/lecture_session.dart';
import 'package:flutter/material.dart';

class SelectLectureSessionDialog extends StatelessWidget {
  const SelectLectureSessionDialog({
    super.key,
    required this.sessions,
    this.title = 'Select Lecture Session',
    this.emptyMessage = 'No lecture sessions available.',
  });

  final List<LectureSession> sessions;
  final String title;
  final String emptyMessage;

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
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontSize: r.titleLarge,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SizedBox(
        width: dialogWidth,
        child: sessions.isEmpty
            ? Padding(
                padding: EdgeInsets.symmetric(vertical: r.spacingXL),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.event_note_outlined,
                      size: r.iconLarge,
                      color: colors.onSurfaceVariant,
                    ),
                    SizedBox(height: r.spacingM),
                    Text(
                      emptyMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: r.body,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: sessions.map((session) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: r.spacingS),
                      child: _LectureSessionOption(
                        session: session,
                        onTap: () => Navigator.pop(context, session),
                      ),
                    );
                  }).toList(),
                ),
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

class _LectureSessionOption extends StatelessWidget {
  const _LectureSessionOption({required this.session, required this.onTap});

  final LectureSession session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);
    final colors = Theme.of(context).colorScheme;

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
            children: [
              Container(
                padding: EdgeInsets.all(r.spacingS),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(r.radius),
                ),
                child: Icon(
                  Icons.event_note_outlined,
                  size: r.iconMedium,
                  color: colors.primary,
                ),
              ),
              SizedBox(width: r.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.lectureSessionName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: r.titleMedium,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                    SizedBox(height: r.spacingXS),
                    Text(
                      'Week ${session.weekNumber}',
                      style: TextStyle(
                        fontSize: r.bodySmall,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: r.spacingXS),
                    Text(
                      '${_formatDate(session.lectureDate)} • '
                      '${session.fromTime} – ${session.toTime}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: r.bodySmall,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: r.spacingS),
              _StatusBadge(status: session.status),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final LectureSessionStatus status;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);
    final colors = Theme.of(context).colorScheme;

    final Color backgroundColor;
    final Color foregroundColor;
    final String label;

    switch (status) {
      case LectureSessionStatus.scheduled:
        backgroundColor = colors.surfaceContainerHighest;
        foregroundColor = colors.onSurfaceVariant;
        label = 'Scheduled';
        break;

      case LectureSessionStatus.active:
        backgroundColor = colors.primaryContainer;
        foregroundColor = colors.onPrimaryContainer;
        label = 'Active';
        break;

      case LectureSessionStatus.completed:
        backgroundColor = colors.secondaryContainer;
        foregroundColor = colors.onSecondaryContainer;
        label = 'Completed';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: r.spacingS,
        vertical: r.spacingXS,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: r.caption,
          fontWeight: FontWeight.w600,
          color: foregroundColor,
        ),
      ),
    );
  }
}
