import 'package:attendance_management_system/core/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/models/lecture_session.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/models/lecture_session_attendance_stats.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/providers/lecture_session_provider.dart';

class LectureSessionDetailsPage extends StatefulWidget {
  const LectureSessionDetailsPage({
    super.key,
    required this.lectureSessionId,
    required this.courseName,
    required this.courseCode,
    required this.startSession,
    required this.completeSession,
    required this.viewAttendance,
    this.updateSession,
    this.deleteSession,
  });

  final int lectureSessionId;
  final String courseName;
  final String courseCode;

  final Future<void> Function(LectureSession lectureSession) startSession;

  final Future<void> Function(LectureSession lectureSession) completeSession;

  final void Function(LectureSession lectureSession) viewAttendance;

  final Future<void> Function(LectureSession lectureSession)? updateSession;

  final Future<void> Function(LectureSession lectureSession)? deleteSession;

  @override
  State<LectureSessionDetailsPage> createState() =>
      _LectureSessionDetailsPageState();
}

class _LectureSessionDetailsPageState extends State<LectureSessionDetailsPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LectureSessionProvider>().loadLectureSession(
        widget.lectureSessionId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);

    return Scaffold(
      appBar: AppBarWidget(title: 'Lecture Session Details'),
      endDrawer: const AppDrawer(),
      body: Consumer<LectureSessionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.selectedLectureSession == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final lectureSession = provider.selectedLectureSession;

          if (lectureSession == null) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(r.pagePadding),
                child: Text(
                  provider.errorMessage ?? 'Lecture session not found.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: r.body),
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(r.pagePadding),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: r.dialogWidth),
                child: _buildDetails(
                  context,
                  r,
                  lectureSession,
                  provider.selectedSessionAttendanceStats,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetails(
    BuildContext context,
    AppResponsive r,
    LectureSession lectureSession,
    LectureSessionAttendanceStats? attendanceStats,
  ) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lectureSession.lectureSessionName,
          style: TextStyle(fontSize: r.headline, fontWeight: FontWeight.w600),
        ),

        SizedBox(height: r.spacingXS),

        Text(
          '${widget.courseName} (${widget.courseCode})',
          style: TextStyle(fontSize: r.body, color: colors.onSurfaceVariant),
        ),

        SizedBox(height: r.spacingL),

        _buildAttendanceSummary(context, r, attendanceStats),

        SizedBox(height: r.spacingL),

        _buildInformationCard(context, r, lectureSession),

        SizedBox(height: r.spacingL),

        _buildManagementActions(context, r, lectureSession),
      ],
    );
  }

  Widget _buildAttendanceSummary(
    BuildContext context,
    AppResponsive r,
    LectureSessionAttendanceStats? stats,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final presentCount = stats?.presentCount ?? 0;
    final totalStudents = stats?.totalStudents ?? 0;
    final percentage = stats?.attendancePercentage ?? 0;

    return Card(
      color: colors.surfaceBright,
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.all(r.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendance',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            SizedBox(height: r.spacingM),

            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$presentCount',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    ' / $totalStudents present',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),

                const Spacer(),

                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.primary,
                  ),
                ),
              ],
            ),

            SizedBox(height: r.spacingS),

            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: totalStudents == 0
                    ? 0
                    : (presentCount / totalStudents).clamp(0.0, 1.0),
                minHeight: 7,
              ),
            ),

            SizedBox(height: r.spacingXS),

            Text(
              '$presentCount of $totalStudents students present',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInformationCard(
    BuildContext context,
    AppResponsive r,
    LectureSession lectureSession,
  ) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      color: colors.surfaceBright,
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.all(r.cardPadding),
        child: Column(
          children: [
            _buildDetailRow(
              context,
              r,
              icon: Icons.numbers,
              label: 'Lecture Session',
              value: lectureSession.lectureSessionName,
            ),

            _buildDivider(r),

            _buildDetailRow(
              context,
              r,
              icon: Icons.calendar_view_week_outlined,
              label: 'Week',
              value: lectureSession.weekNumber.toString(),
            ),

            _buildDivider(r),

            _buildDetailRow(
              context,
              r,
              icon: Icons.calendar_today_outlined,
              label: 'Lecture Date',
              value: _formatDate(lectureSession.lectureDate),
            ),

            _buildDivider(r),

            _buildDetailRow(
              context,
              r,
              icon: Icons.access_time_outlined,
              label: 'Time',
              value:
                  '${lectureSession.fromTime} – '
                  '${lectureSession.toTime}',
            ),

            _buildDivider(r),

            _buildDetailRow(
              context,
              r,
              icon: Icons.timer_outlined,
              label: 'Duration',
              value: _formatDuration(lectureSession.durationMinutes),
            ),

            _buildDivider(r),

            _buildDetailRow(
              context,
              r,
              icon: Icons.info_outline,
              label: 'Status',
              value: _statusLabel(lectureSession.status),
            ),

            if (lectureSession.startedAt != null) ...[
              _buildDivider(r),

              _buildDetailRow(
                context,
                r,
                icon: Icons.play_circle_outline,
                label: 'Started At',
                value: _formatDateTime(lectureSession.startedAt!),
              ),
            ],

            _buildDivider(r),

            _buildDetailRow(
              context,
              r,
              icon: Icons.update,
              label: 'Last Updated',
              value: _formatDateTime(lectureSession.updatedAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementActions(
    BuildContext context,
    AppResponsive r,
    LectureSession lectureSession,
  ) {
    final isPhone = r.isPhone;

    final viewAttendanceButton = OutlinedButton.icon(
      onPressed: () => widget.viewAttendance(lectureSession),
      icon: Icon(Icons.fact_check_outlined, size: r.buttonIcon),
      label: const Text('View Attendance'),
    );

    final startButton = FilledButton.icon(
      onPressed: () => widget.startSession(lectureSession),
      icon: Icon(Icons.play_arrow, size: r.buttonIcon),
      label: const Text('Start Lecture'),
    );

    final completeButton = FilledButton.icon(
      onPressed: () => widget.completeSession(lectureSession),
      icon: Icon(Icons.check_circle_outline, size: r.buttonIcon),
      label: const Text('Complete Lecture'),
    );

    final updateButton = OutlinedButton.icon(
      onPressed: widget.updateSession == null
          ? null
          : () => widget.updateSession!(lectureSession),
      icon: Icon(Icons.edit_outlined, size: r.buttonIcon),
      label: const Text('Update'),
    );

    final deleteButton = OutlinedButton.icon(
      onPressed: widget.deleteSession == null
          ? null
          : () => widget.deleteSession!(lectureSession),
      icon: Icon(Icons.delete_outline, size: r.buttonIcon),
      label: const Text('Delete'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.error,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Management',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),

        SizedBox(height: r.spacingM),

        if (lectureSession.isScheduled) ...[
          SizedBox(
            width: double.infinity,
            height: r.buttonHeight,
            child: startButton,
          ),

          SizedBox(height: r.spacingS),
        ],

        if (lectureSession.isActive) ...[
          SizedBox(
            width: double.infinity,
            height: r.buttonHeight,
            child: completeButton,
          ),

          SizedBox(height: r.spacingS),
        ],

        SizedBox(
          width: double.infinity,
          height: r.buttonHeight,
          child: viewAttendanceButton,
        ),

        SizedBox(height: r.spacingM),

        if (isPhone)
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: r.buttonHeight,
                child: updateButton,
              ),
              SizedBox(height: r.spacingS),
              SizedBox(
                width: double.infinity,
                height: r.buttonHeight,
                child: deleteButton,
              ),
            ],
          )
        else
          Row(
            children: [
              Expanded(
                child: SizedBox(height: r.buttonHeight, child: updateButton),
              ),
              SizedBox(width: r.spacingS),
              Expanded(
                child: SizedBox(height: r.buttonHeight, child: deleteButton),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    AppResponsive r, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: r.iconMedium),
        SizedBox(width: r.spacingM),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: r.body,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
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

  Widget _buildDivider(AppResponsive r) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: r.spacingM),
      child: const Divider(height: 1),
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

  String _formatDateTime(DateTime date) {
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
