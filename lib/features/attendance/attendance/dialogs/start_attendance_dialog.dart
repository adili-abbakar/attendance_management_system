import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/models/lecture_session.dart';
import 'package:flutter/material.dart';

class StartAttendanceDialog extends StatelessWidget {
  const StartAttendanceDialog({super.key, required this.lectureSessions});

  final List<LectureSession> lectureSessions;

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

    final sessions = lectureSessions
        .where((session) => session.isScheduled || session.isActive)
        .toList();

    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: r.dialogInset,
        vertical: r.dialogInset,
      ),
      title: Text(
        'Start Attendance',
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
                      Icons.event_busy_outlined,
                      size: r.iconLarge,
                      color: colors.onSurfaceVariant,
                    ),
                    SizedBox(height: r.spacingM),
                    Text(
                      'No lecture sessions are available for attendance.',
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final isActive = session.isActive;

    final statusColor = isActive ? colors.primary : colors.secondary;

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      session.lectureSessionName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: r.titleMedium,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                  SizedBox(width: r.spacingS),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: r.spacingS,
                      vertical: r.spacingXS,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      isActive ? 'Active' : 'Scheduled',
                      style: TextStyle(
                        fontSize: r.caption,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: r.spacingS),
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
                style: TextStyle(
                  fontSize: r.bodySmall,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
