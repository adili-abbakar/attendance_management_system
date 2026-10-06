import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/models/lecture_session.dart';
import 'package:flutter/material.dart';

class LectureSessionInformationCard extends StatelessWidget {
  const LectureSessionInformationCard({
    super.key,
    required this.lectureSession,
  });

  final LectureSession lectureSession;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);
    final colors = Theme.of(context).colorScheme;

    return Card(
      color: colors.surfaceBright,
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.all(r.cardPadding),
        child: Column(
          children: [
            _DetailRow(
              icon: Icons.numbers,
              label: 'Lecture Session',
              value: lectureSession.lectureSessionName,
            ),
            _Divider(r),
            _DetailRow(
              icon: Icons.calendar_view_week_outlined,
              label: 'Week',
              value: lectureSession.weekNumber.toString(),
            ),
            _Divider(r),
            _DetailRow(
              icon: Icons.calendar_today_outlined,
              label: 'Lecture Date',
              value: _formatDate(lectureSession.lectureDate),
            ),
            _Divider(r),
            _DetailRow(
              icon: Icons.access_time_outlined,
              label: 'Time',
              value: '${lectureSession.fromTime} – ${lectureSession.toTime}',
            ),
            _Divider(r),
            _DetailRow(
              icon: Icons.timer_outlined,
              label: 'Duration',
              value: _formatDuration(lectureSession.durationMinutes),
            ),
            _Divider(r),
            _DetailRow(
              icon: Icons.info_outline,
              label: 'Status',
              value: _statusLabel(lectureSession.status),
            ),
            if (lectureSession.startedAt != null) ...[
              _Divider(r),
              _DetailRow(
                icon: Icons.play_circle_outline,
                label: 'Started At',
                value: _formatDateTime(lectureSession.startedAt!),
              ),
            ],
            _Divider(r),
            _DetailRow(
              icon: Icons.update,
              label: 'Last Updated',
              value: _formatDateTime(lectureSession.updatedAt),
            ),
          ],
        ),
      ),
    );
  }

  static String _statusLabel(LectureSessionStatus status) {
    switch (status) {
      case LectureSessionStatus.scheduled:
        return 'Scheduled';

      case LectureSessionStatus.active:
        return 'Active';

      case LectureSessionStatus.completed:
        return 'Completed';
    }
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  static String _formatDateTime(DateTime date) {
    final datePart = _formatDate(date);

    final hour = date.hour == 0
        ? 12
        : date.hour > 12
        ? date.hour - 12
        : date.hour;

    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '$datePart $hour:$minute $period';
  }

  static String _formatDuration(int minutes) {
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);
    final colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: r.iconMedium),
        SizedBox(width: r.spacingM),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: r.body, color: colors.onSurfaceVariant),
          ),
        ),
        SizedBox(width: r.spacingM),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(fontSize: r.body, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider(this.r);

  final AppResponsive r;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: r.spacingM),
      child: const Divider(height: 1),
    );
  }
}
