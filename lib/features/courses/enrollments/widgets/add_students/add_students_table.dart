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

  /// IDs of selected students.
  final Set<int> selectedStudents;

  final ValueChanged<Student> onToggleSelection;

  /// Used for continuous numbering across pages.
  final int startIndex;

  @override
  Widget build(BuildContext context) {
    if (students.isEmpty) {
      return const EmptyAvailableStudents();
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 28,
          headingRowHeight: 56,
          dataRowMinHeight: 52,
          dataRowMaxHeight: 60,
          columns: const [
            DataColumn(
              label: Text('#', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            DataColumn(label: SizedBox.shrink()),
            DataColumn(
              label: Text(
                'Admission Number',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Student Name',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Status',
                style: TextStyle(fontWeight: FontWeight.bold),
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
    );
  }
}
