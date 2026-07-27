import 'package:attendance_management_system/features/courses/widgets/course_details/empty_students.dart';
import 'package:attendance_management_system/features/courses/widgets/course_details/enrolled_student_row.dart';
import 'package:attendance_management_system/features/students/models/student.dart';
import 'package:flutter/material.dart';

class EnrolledStudentsTable extends StatelessWidget {
  const EnrolledStudentsTable({
    super.key,
    required this.students,
    this.onStudentTap,
    this.onRemoveStudent,
    this.startIndex = 0,
  });

  final List<Student> students;
  final ValueChanged<Student>? onStudentTap;
  final ValueChanged<Student>? onRemoveStudent;

  /// Zero-based index of the first student on the page.
  final int startIndex;

  @override
  Widget build(BuildContext context) {
    if (students.isEmpty) {
      return const EmptyStudents();
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 28,
          columns: const [
            DataColumn(
              label: Text('S/N', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
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
            DataColumn(
              label: Text(
                'Actions',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: List.generate(
            students.length,
            (index) => EnrolledStudentRow(
              serialNumber: startIndex + index + 1,
              student: students[index],
              onTap: onStudentTap,
              onRemove: onRemoveStudent,
            ),
          ),
        ),
      ),
    );
  }
}
