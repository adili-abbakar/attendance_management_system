import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/models/lecture_session.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/providers/lecture_session_provider.dart';

class LectureSessionDetailsPage extends StatefulWidget {
  const LectureSessionDetailsPage({
    super.key,
    required this.lectureSessionId,
    required this.courseName,
  });

  final int lectureSessionId;
  final String courseName;

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
      appBar: AppBar(
        title: Text(
          'Lecture Session Details',
          style: TextStyle(fontSize: r.titleLarge),
        ),
      ),
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
                child: _buildDetails(context, r, lectureSession),
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
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lectureSession.lectureSessionName,
          style: TextStyle(fontSize: r.headline, fontWeight: FontWeight.w600),
        ),

        SizedBox(height: r.spacingXS),

        Text(
          widget.courseName,
          style: TextStyle(
            fontSize: r.body,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),

        SizedBox(height: r.spacingL),

        Card(
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
        ),

        SizedBox(height: r.spacingL),

        _buildStatusAction(context, r, lectureSession),
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

  Widget _buildStatusAction(
    BuildContext context,
    AppResponsive r,
    LectureSession lectureSession,
  ) {
    if (lectureSession.isScheduled) {
      return SizedBox(
        width: double.infinity,
        height: r.buttonHeight,
        child: FilledButton.icon(
          onPressed: () async {
            final provider = context.read<LectureSessionProvider>();

            final success = await provider.startLectureSession(lectureSession);

            if (!context.mounted) return;

            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Lecture session started.')),
              );
            }
          },
          icon: Icon(Icons.play_arrow, size: r.buttonIcon),
          label: const Text('Start Lecture'),
        ),
      );
    }

    if (lectureSession.isActive) {
      return SizedBox(
        width: double.infinity,
        height: r.buttonHeight,
        child: FilledButton.icon(
          onPressed: () async {
            final provider = context.read<LectureSessionProvider>();

            final success = await provider.completeLectureSession(
              lectureSession,
            );

            if (!context.mounted) return;

            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Lecture session completed.')),
              );
            }
          },
          icon: Icon(Icons.check_circle_outline, size: r.buttonIcon),
          label: const Text('Complete Lecture'),
        ),
      );
    }

    return const SizedBox.shrink();
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
