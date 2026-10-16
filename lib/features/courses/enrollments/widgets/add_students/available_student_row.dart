import 'package:attendance_management_system/features/students/models/student.dart';
import 'package:flutter/material.dart';

class AvailableStudentRow extends DataRow {
  AvailableStudentRow({
    required int index,
    required Student student,
    required super.selected,
    required ValueChanged<Student> onChanged,
  }) : super(
         onSelectChanged: (_) => onChanged(student),
         cells: [
           DataCell(
             Text(
               index.toString(),
               style: const TextStyle(fontWeight: FontWeight.w600),
             ),
             onTap: () => onChanged(student),
           ),

           DataCell(
             Checkbox(value: selected, onChanged: (_) => onChanged(student)),
           ),

           DataCell(
             Text(
               student.admissionNumber,
               style: const TextStyle(fontWeight: FontWeight.w600),
             ),
             onTap: () => onChanged(student),
           ),

           DataCell(Text(student.fullName), onTap: () => onChanged(student)),
         ],
       );
}
