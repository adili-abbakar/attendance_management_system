import 'package:attendance_management_system/features/students/models/student.dart';
import 'package:flutter/material.dart';

class EnrolledStudentRow extends DataRow {
  EnrolledStudentRow({
    required int serialNumber,
    required Student student,
    ValueChanged<Student>? onTap,
    ValueChanged<Student>? onRemove,
  }) : super(
         cells: [
           DataCell(
             Text(
               serialNumber.toString(),
               style: const TextStyle(fontWeight: FontWeight.w600),
             ),
             onTap: onTap == null ? null : () => onTap(student),
           ),

           DataCell(
             Text(
               student.admissionNumber,
               style: const TextStyle(fontWeight: FontWeight.w600),
             ),
             onTap: onTap == null ? null : () => onTap(student),
           ),

           DataCell(
             Text(student.fullName),
             onTap: onTap == null ? null : () => onTap(student),
           ),

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
             onTap: onTap == null ? null : () => onTap(student),
           ),

           DataCell(
             IconButton(
               tooltip: 'Remove from course',
               icon: const Icon(Icons.person_remove_alt_1, color: Colors.red),
               onPressed: onRemove == null ? null : () => onRemove(student),
             ),
           ),
         ],
       );
}
