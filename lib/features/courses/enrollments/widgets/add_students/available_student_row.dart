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

           DataCell(
             Builder(
               builder: (context) {
                 final colors = Theme.of(context).colorScheme;
                 final statusColor = student.isActive
                     ? Colors.green
                     : colors.error;

                 return Tooltip(
                   message: student.isActive
                       ? 'Active student'
                       : 'Inactive student',
                   child: Row(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       Icon(
                         student.isActive ? Icons.check_circle : Icons.cancel,
                         size: 18,
                         color: statusColor,
                       ),

                       const SizedBox(width: 6),

                       Text(student.isActive ? 'Active' : 'Inactive'),
                     ],
                   ),
                 );
               },
             ),
             onTap: () => onChanged(student),
           ),
         ],
       );
}
