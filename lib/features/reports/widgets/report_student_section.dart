import 'package:attendance_management_system/core/table/app_data_table.dart';
import 'package:attendance_management_system/core/table/app_table_row.dart';
import 'package:attendance_management_system/features/reports/models/attendance_report.dart';
import 'package:flutter/material.dart';

class ReportStudentSection extends StatelessWidget {
  final List<StudentAttendanceReport> students;

  const ReportStudentSection({super.key, required this.students});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final rows = students.asMap().entries.map((entry) {
      final index = entry.key;
      final student = entry.value;

      return AppTableRow(
        cells: [
          Text('${index + 1}'),
          Text(student.fullName, maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(
            student.admissionNumber,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text('${student.sessionsAttended}'),
          Text('${student.sessionsMissed}'),
          Text(
            '${student.attendancePercentage.toStringAsFixed(1)}%',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Student Attendance', style: theme.textTheme.titleLarge),

        const SizedBox(height: 12),

        AppDataTable(
          columns: const [
            AppTableColumn(label: '#', flex: 1, minWidth: 60),
            AppTableColumn(label: 'Student', flex: 3, minWidth: 220),
            AppTableColumn(label: 'Admission No.', flex: 2, minWidth: 150),
            AppTableColumn(
              label: 'Attended',
              flex: 1,
              minWidth: 100,
              alignment: Alignment.center,
            ),
            AppTableColumn(
              label: 'Missed',
              flex: 1,
              minWidth: 100,
              alignment: Alignment.center,
            ),
            AppTableColumn(
              label: 'Attendance',
              flex: 1,
              minWidth: 120,
              alignment: Alignment.center,
            ),
          ],
          rows: rows,
          emptyMessage: 'No students found.',
        ),
      ],
    );
  }
}
