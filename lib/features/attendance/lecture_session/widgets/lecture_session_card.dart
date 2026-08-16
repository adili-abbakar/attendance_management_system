import 'package:flutter/material.dart';

import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/models/lecture_session.dart';

class LectureSessionCard extends StatelessWidget {
  const LectureSessionCard({
    super.key,
    required this.lectureSession,
    this.onTap,
    this.onStart,
    this.onComplete,
    this.onDelete,
  });

  final LectureSession lectureSession;

  final VoidCallback? onTap;
  final VoidCallback? onStart;
  final VoidCallback? onComplete;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(r.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      lectureSession.lectureSessionName,
                      style: TextStyle(
                        fontSize: r.titleMedium,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _buildStatus(context, r),
                ],
              ),

              SizedBox(height: r.spacingM),

              _buildInfoRow(
                context,
                r,
                Icons.calendar_view_week_outlined,
                'Week ${lectureSession.weekNumber}',
              ),

              SizedBox(height: r.spacingS),

              _buildInfoRow(
                context,
                r,
                Icons.calendar_today_outlined,
                _formatDate(lectureSession.lectureDate),
              ),

              SizedBox(height: r.spacingS),

              _buildInfoRow(
                context,
                r,
                Icons.access_time_outlined,
                '${lectureSession.fromTime} – '
                '${lectureSession.toTime}',
              ),

              SizedBox(height: r.spacingS),

              _buildInfoRow(
                context,
                r,
                Icons.timer_outlined,
                _formatDuration(lectureSession.durationMinutes),
              ),

              if (lectureSession.isScheduled || lectureSession.isActive) ...[
                SizedBox(height: r.spacingM),
                const Divider(),
                SizedBox(height: r.spacingS),
                Row(
                  children: [
                    if (lectureSession.isScheduled && onStart != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onStart,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Start'),
                        ),
                      ),
                    if (lectureSession.isActive && onComplete != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onComplete,
                          icon: const Icon(Icons.check),
                          label: const Text('Complete'),
                        ),
                      ),
                    if (onDelete != null) ...[
                      SizedBox(width: r.spacingS),
                      IconButton(
                        onPressed: onDelete,
                        tooltip: 'Delete',
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    AppResponsive r,
    IconData icon,
    String text,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: r.iconSmall,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        SizedBox(width: r.spacingS),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: r.body,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatus(BuildContext context, AppResponsive r) {
    return Text(
      _statusLabel(lectureSession.status),
      style: TextStyle(fontSize: r.bodySmall, fontWeight: FontWeight.w600),
    );
  }

  String _statusLabel(LectureSessionStatus status) {
    switch (status) {
      case LectureSessionStatus.scheduled:
        return 'Scheduled';
      case LectureSessionStatus.active:
        return 'Active';
      case LectureSessionStatus.completed:
        return 'Completed';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatDuration(int minutes) {
    if (minutes <= 0) {
      return '-';
    }

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (hours == 0) {
      return '$remainingMinutes min';
    }

    if (remainingMinutes == 0) {
      return '$hours hr';
    }

    return '$hours hr $remainingMinutes min';
  }
}
