import 'package:attendance_management_system/features/students/models/student.dart';
import 'package:flutter/material.dart';

class StudentSelectionTile extends StatelessWidget {
  const StudentSelectionTile({
    super.key,
    required this.student,
    required this.selected,
    required this.onChanged,
  });

  final Student student;
  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: selected,
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (value) => onChanged(value ?? false),

      title: Text(
        student.fullName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),

      subtitle: Text(student.admissionNumber),
    );
  }
}
