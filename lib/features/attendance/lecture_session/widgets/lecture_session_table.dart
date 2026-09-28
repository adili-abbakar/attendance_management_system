import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:attendance_management_system/core/table/table.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/models/lecture_session.dart';
import 'package:flutter/material.dart';

class LectureSessionTable extends StatelessWidget {
  const LectureSessionTable({
    super.key,
    required this.sessions,
    required this.onTap,
    required this.onUpdate,
    required this.onDetails,
    required this.onAttendance,
    required this.onStart,
    required this.onComplete,
    required this.onDelete,
  });

  final List<LectureSession> sessions;

  final ValueChanged<LectureSession> onTap;
  final ValueChanged<LectureSession> onUpdate;
  final ValueChanged<LectureSession> onDetails;
  final ValueChanged<LectureSession> onAttendance;
  final ValueChanged<LectureSession> onStart;
  final ValueChanged<LectureSession> onComplete;
  final ValueChanged<LectureSession> onDelete;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);
    final colors = Theme.of(context).colorScheme;

    return AppDataTable(
      columns: const [
        AppTableColumn(
          label: '#',
          flex: 1,
          minWidth: 55,
          alignment: Alignment.center,
        ),
        AppTableColumn(label: 'Lecture Session', flex: 3, minWidth: 180),
        AppTableColumn(
          label: 'Week',
          flex: 1,
          minWidth: 70,
          alignment: Alignment.center,
        ),
        AppTableColumn(label: 'Date', flex: 2, minWidth: 110),
        AppTableColumn(label: 'Time', flex: 3, minWidth: 150),
        AppTableColumn(label: 'Duration', flex: 2, minWidth: 100),
        AppTableColumn(
          label: 'Status',
          flex: 2,
          minWidth: 110,
          alignment: Alignment.center,
        ),
        AppTableColumn(
          label: 'Actions',
          flex: 2,
          minWidth: 90,
          alignment: Alignment.center,
        ),
      ],
      rows: List.generate(sessions.length, (index) {
        final session = sessions[index];

        return AppTableRow(
          onTap: () => onTap(session),
          cells: [
            Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: r.bodySmall,
                fontWeight: FontWeight.w600,
                color: colors.onSurfaceVariant,
              ),
            ),

            Text(
              session.lectureSessionName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: r.body,
                fontWeight: FontWeight.w500,
                color: colors.onSurface,
              ),
            ),

            Text(
              session.weekNumber.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: r.body, color: colors.onSurface),
            ),

            Text(
              _formatDate(session.lectureDate),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            Text(
              '${session.fromTime} – ${session.toTime}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            Text(
              _formatDuration(session.durationMinutes),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            _StatusBadge(status: session.status),

            _ActionsButton(
              session: session,
              onUpdate: onUpdate,
              onDetails: onDetails,
              onAttendance: onAttendance,
              onStart: onStart,
              onComplete: onComplete,
              onDelete: onDelete,
            ),
          ],
        );
      }),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final LectureSessionStatus status;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);
    final colors = Theme.of(context).colorScheme;

    final bool isActive = status == LectureSessionStatus.active;
    final bool isCompleted = status == LectureSessionStatus.completed;

    final Color foregroundColor;

    if (isActive) {
      foregroundColor = colors.primary;
    } else if (isCompleted) {
      foregroundColor = colors.onSurfaceVariant;
    } else {
      foregroundColor = colors.secondary;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: r.spacingS,
        vertical: r.spacingXS,
      ),
      decoration: BoxDecoration(
        color: foregroundColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _statusLabel(status),
        style: TextStyle(
          fontSize: r.caption,
          fontWeight: FontWeight.w700,
          color: foregroundColor,
        ),
      ),
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
}

class _ActionsButton extends StatelessWidget {
  const _ActionsButton({
    required this.session,
    required this.onUpdate,
    required this.onDetails,
    required this.onAttendance,
    required this.onStart,
    required this.onComplete,
    required this.onDelete,
  });

  final LectureSession session;

  final ValueChanged<LectureSession> onUpdate;
  final ValueChanged<LectureSession> onDetails;
  final ValueChanged<LectureSession> onAttendance;
  final ValueChanged<LectureSession> onStart;
  final ValueChanged<LectureSession> onComplete;
  final ValueChanged<LectureSession> onDelete;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);

    return PopupMenuButton<String>(
      iconSize: r.iconMedium,
      onSelected: (value) {
        switch (value) {
          case 'update':
            onUpdate(session);
            break;

          case 'details':
            onDetails(session);
            break;

          case 'attendance':
            onAttendance(session);
            break;

          case 'start':
            onStart(session);
            break;

          case 'complete':
            onComplete(session);
            break;

          case 'delete':
            onDelete(session);
            break;
        }
      },
      itemBuilder: (context) {
        final items = <PopupMenuEntry<String>>[
          const PopupMenuItem(value: 'update', child: Text('Update Session')),
          const PopupMenuItem(value: 'details', child: Text('View Details')),
          const PopupMenuItem(
            value: 'attendance',
            child: Text('View Attendance'),
          ),
        ];

        if (session.isScheduled) {
          items.add(
            const PopupMenuItem(value: 'start', child: Text('Start Lecture')),
          );
        }

        if (session.isActive) {
          items.add(
            const PopupMenuItem(
              value: 'complete',
              child: Text('Complete Lecture'),
            ),
          );
        }

        items.add(const PopupMenuItem(value: 'delete', child: Text('Delete')));

        return items;
      },
    );
  }
}
