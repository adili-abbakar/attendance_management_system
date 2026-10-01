import 'package:attendance_management_system/core/widgets/app_bar_widget.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/widgets/lecture_session_tile.dart';
import 'package:flutter/material.dart';

class TodaysSessionsPage extends StatelessWidget {
  const TodaysSessionsPage({super.key, required this.sessions});

  final List<LectureSessionTileData> sessions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: "Today's Sessions"),
      body: sessions.isEmpty
          ? const _EmptySessionsView()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
              itemCount: sessions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final session = sessions[index];

                return LectureSessionTile(
                  courseCode: session.courseCode,
                  courseTitle: session.courseTitle,
                  sessionName: session.sessionName,
                  time: session.time,
                  students: session.students,
                  status: session.status,
                  onTap: session.onTap,
                );
              },
            ),
    );
  }
}

class LectureSessionTileData {
  const LectureSessionTileData({
    required this.courseCode,
    required this.courseTitle,
    required this.sessionName,
    required this.time,
    required this.students,
    required this.status,
    this.onTap,
  });

  final String courseCode;
  final String courseTitle;
  final String sessionName;
  final String time;
  final int students;
  final String status;
  final VoidCallback? onTap;
}

class _EmptySessionsView extends StatelessWidget {
  const _EmptySessionsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_available_outlined,
              size: 48,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'No sessions today',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'There are no lecture sessions scheduled for today.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
