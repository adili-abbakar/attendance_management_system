import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:attendance_management_system/features/students/models/student.dart';
import 'package:flutter/material.dart';

class LectureSessionAttendanceList extends StatelessWidget {
  const LectureSessionAttendanceList({
    super.key,
    required this.presentStudents,
    required this.absentStudents,
  });

  final List<Student> presentStudents;
  final List<Student> absentStudents;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Students',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: r.spacingM),

        _StudentStatusSection(
          title: 'Present',
          students: presentStudents,
          icon: Icons.check_circle_outline,
        ),

        SizedBox(height: r.spacingM),

        _StudentStatusSection(
          title: 'Absent',
          students: absentStudents,
          icon: Icons.cancel_outlined,
        ),
      ],
    );
  }
}

class _StudentStatusSection extends StatelessWidget {
  const _StudentStatusSection({
    required this.title,
    required this.students,
    required this.icon,
  });

  final String title;
  final List<Student> students;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      color: colors.surfaceBright,
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.all(r.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: r.iconMedium),
                SizedBox(width: r.spacingS),
                Expanded(
                  child: Text(
                    '$title (${students.length})',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: r.spacingM),

            if (students.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: r.spacingM),
                child: Center(
                  child: Text(
                    'No students',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: students.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  return _StudentTile(student: students[index]);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _StudentTile extends StatelessWidget {
  const _StudentTile({required this.student});

  final Student student;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: r.spacingS),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            child: Text(
              _initials(student),
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: r.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _studentName(student),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: r.spacingXS),
                Text(
                  student.admissionNumber,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _studentName(Student student) {
    return student.fullName;
  }

  String _initials(Student student) {
    final name = student.fullName.trim();

    if (name.isEmpty) {
      return '?';
    }

    final parts = name.split(RegExp(r'\s+'));

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}'
            '${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}
