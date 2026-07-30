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
        int columns;

        if (constraints.maxWidth >= 900) {
          columns = 3;
        } else if (constraints.maxWidth >= 600) {
          columns = 2;
        } else {
          columns = 1;
        }

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: columns,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 3.2,
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
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: colors.primaryContainer,
              child: Icon(icon, color: colors.primary, size: 20),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodySmall,
                  ),

                  const SizedBox(height: 2),

                  Text(
                    value,
                    style: text.titleLarge?.copyWith(
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
