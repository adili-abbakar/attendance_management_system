import 'package:attendance_management_system/data/models/student.dart';
import 'package:flutter/material.dart';

class StudentTable extends StatelessWidget {
  const StudentTable({
    super.key,
    required this.students,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Student> students;

  final ValueChanged<Student> onEdit;
  final ValueChanged<Student> onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 56,
          dataRowMinHeight: 56,
          dataRowMaxHeight: 60,
          columns: const [
            DataColumn(
              label: Text(
                'Admission No.',
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
          rows: students.map((student) {
            return DataRow(
              cells: [
                DataCell(Text(student.admissionNumber)),

                DataCell(Text(student.fullName)),

                DataCell(
                  Chip(
                    label: Text(student.isActive ? 'Active' : 'Inactive'),
                    backgroundColor: student.isActive
                        ? Colors.green.withValues(alpha: .15)
                        : Colors.red.withValues(alpha: .15),
                    side: BorderSide.none,
                  ),
                ),

                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Edit',
                        icon: Icon(
                          Icons.edit_outlined,
                          color: theme.colorScheme.primary,
                        ),
                        onPressed: () => onEdit(student),
                      ),

                      IconButton(
                        tooltip: 'Delete',
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () => onDelete(student),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
