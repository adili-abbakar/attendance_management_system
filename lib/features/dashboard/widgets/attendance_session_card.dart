import 'package:flutter/material.dart';

class AttendanceSessionCard extends StatelessWidget {
  const AttendanceSessionCard({
    super.key,
    required this.courseCode,
    required this.courseTitle,
    required this.time,
    required this.students,
    required this.onTap,
  });

  final String courseCode;
  final String courseTitle;
  final String time;
  final int students;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: colors.primaryContainer,
                child: Icon(Icons.fact_check_rounded, color: colors.primary),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      courseCode,
                      style: text.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(courseTitle),

                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 20,
                      runSpacing: 8,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.schedule_outlined, size: 18),
                            const SizedBox(width: 4),
                            Text(time),
                          ],
                        ),

                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.people_outline, size: 18),
                            const SizedBox(width: 4),
                            Text("$students Students"),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Icon(Icons.arrow_forward_ios_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
