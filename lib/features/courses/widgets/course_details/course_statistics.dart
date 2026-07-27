import 'package:flutter/material.dart';

class CourseStatistics extends StatelessWidget {
  const CourseStatistics({
    super.key,
    required this.totalStudents,
    this.totalAttendanceSessions = 0,
    this.averageAttendance = 0,
  });

  final int totalStudents;
  final int totalAttendanceSessions;
  final double averageAttendance;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 900 ? 3 : 1;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: columns,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.8,
          children: [
            _StatisticCard(
              icon: Icons.people_outline,
              title: 'Students',
              value: totalStudents.toString(),
            ),

            _StatisticCard(
              icon: Icons.event_available_outlined,
              title: 'Attendance Sessions',
              value: totalAttendanceSessions.toString(),
            ),

            _StatisticCard(
              icon: Icons.analytics_outlined,
              title: 'Average Attendance',
              value: '${averageAttendance.toStringAsFixed(1)}%',
            ),
          ],
        );
      },
    );
  }
}

class _StatisticCard extends StatelessWidget {
  const _StatisticCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: colors.primaryContainer,
              child: Icon(
                icon,
                color: colors.primary,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: text.bodyMedium,
                  ),

                  const SizedBox(height: 6),

                  Text(
                    value,
                    style: text.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}