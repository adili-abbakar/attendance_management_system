import 'package:attendance_management_system/features/courses/enrollments/widgets/add_students/available_student_row.dart';
import 'package:attendance_management_system/features/courses/enrollments/widgets/add_students/empty_available_students.dart';
import 'package:attendance_management_system/features/students/models/student.dart';
import 'package:flutter/material.dart';

class AddStudentsTable extends StatelessWidget {
  const AddStudentsTable({
    super.key,
    required this.students,
    required this.selectedStudents,
    required this.onToggleSelection,
    this.startIndex = 1,
  });

  final List<Student> students;
  final Set<int> selectedStudents;
  final ValueChanged<Student> onToggleSelection;
  final int startIndex;

  @override
  Widget build(BuildContext context) {
    if (students.isEmpty) {
      return const EmptyAvailableStudents();
    }

    final phone = MediaQuery.sizeOf(context).width < 600;

    final textTheme = Theme.of(context).textTheme;

    final headingStyle = phone
        ? textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)
        : textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Scrollbar(
            thumbVisibility: phone,
            interactive: true,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: phone ? 760 : constraints.maxWidth,
                ),
                child: DataTable(
                  columnSpacing: phone ? 14 : 28,
                  horizontalMargin: phone ? 10 : 20,
                  headingRowHeight: phone ? 46 : 56,
                  dataRowMinHeight: phone ? 44 : 52,
                  dataRowMaxHeight: phone ? 52 : 60,

                  columns: [
                    DataColumn(
                      label: Text('#', style: headingStyle),
                    ),
                    const DataColumn(
                      label: SizedBox(width: 24),
                    ),
                    DataColumn(
                      label: Text(
                        'Admission Number',
                        style: headingStyle,
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Student Name',
                        style: headingStyle,
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Status',
                        style: headingStyle,
                      ),
                    ),
                  ],

                  rows: List.generate(students.length, (index) {
                    final student = students[index];

                    return AvailableStudentRow(
                      index: startIndex + index,
                      student: student,
                      selected: selectedStudents.contains(student.id),
                      onChanged: onToggleSelection,
                    );
                  }),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}