import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/models/lecture_session_attendance_stats.dart';
import 'package:flutter/material.dart';

class LectureSessionAttendanceSummary extends StatelessWidget {
  const LectureSessionAttendanceSummary({super.key, required this.stats});

  final LectureSessionAttendanceStats? stats;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final presentCount = stats?.presentCount ?? 0;
    final totalStudents = stats?.totalStudents ?? 0;
    final percentage = stats?.attendancePercentage ?? 0;

    final progress = totalStudents == 0
        ? 0.0
        : (presentCount / totalStudents).clamp(0.0, 1.0);

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
              child: LinearProgressIndicator(value: progress, minHeight: 7),
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
}
