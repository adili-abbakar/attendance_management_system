import 'package:attendance_management_system/features/students/models/student.dart';
import 'package:flutter/material.dart';

class AvailableStudentRow extends DataRow {
  AvailableStudentRow({
    required int index,
    required Student student,
    required bool selected,
    required ValueChanged<Student> onChanged,
  }) : super(
         selected: selected,
         onSelectChanged: (_) => onChanged(student),
         cells: [
           DataCell(
             Text(
               index.toString(),
               style: const TextStyle(fontWeight: FontWeight.w600),
             ),
           ),

           DataCell(
             Checkbox(value: selected, onChanged: (_) => onChanged(student)),
           ),

           DataCell(
             Text(
               student.admissionNumber,
               style: const TextStyle(fontWeight: FontWeight.w600),
             ),
           ),

           DataCell(Text(student.fullName)),

           DataCell(
             Row(
               mainAxisSize: MainAxisSize.min,
               children: [
                 Icon(
                   student.isActive ? Icons.check_circle : Icons.cancel,
                   size: 18,
                   color: student.isActive ? Colors.green : Colors.red,
                 ),

                 const SizedBox(width: 6),

                 Text(student.isActive ? 'Active' : 'Inactive'),
               ],
             ),
           ),
         ],
       );
}
