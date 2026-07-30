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
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              onTap: onTap == null ? null : () => onTap(student),
            ),

            DataCell(
              Text(
                student.admissionNumber,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              onTap: onTap == null ? null : () => onTap(student),
            ),

            DataCell(
              Text(
                student.fullName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13),
              ),
              onTap: onTap == null ? null : () => onTap(student),
            ),

            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    student.isActive
                        ? Icons.check_circle
                        : Icons.cancel,
                    size: 16,
                    color: student.isActive
                        ? Colors.green
                        : Colors.red,
                  ),

                  const SizedBox(width: 4),

                  Text(
                    student.isActive ? 'Active' : 'Inactive',
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
              onTap: onTap == null ? null : () => onTap(student),
            ),

            DataCell(
              IconButton(
                tooltip: 'Remove from course',
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(
                  minWidth: 36,
                  minHeight: 36,
                ),
                icon: const Icon(
                  Icons.person_remove_alt_1,
                  color: Colors.red,
                  size: 20,
                ),
                onPressed: onRemove == null
                    ? null
                    : () => onRemove(student),
              ),
            ),
          ],
        );
}