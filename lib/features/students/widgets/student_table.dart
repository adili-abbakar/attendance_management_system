import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:attendance_management_system/core/table/table.dart';
import 'package:attendance_management_system/features/students/models/student.dart';
import 'package:flutter/material.dart';

class StudentTable extends StatelessWidget {
  const StudentTable({
    super.key,
    required this.students,
    required this.onEdit,
    required this.onDelete,
    required this.onViewQr,
  });

  final List<Student> students;
  final ValueChanged<Student> onEdit;
  final ValueChanged<Student> onDelete;
  final ValueChanged<Student> onViewQr;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);
    final colors = Theme.of(context).colorScheme;

    return AppDataTable(
      columns: const [
        AppTableColumn(
          label: '#',
          flex: 1,
          minWidth: 55,
          alignment: Alignment.center,
        ),
        AppTableColumn(label: 'Admission No.', flex: 2, minWidth: 150),
        AppTableColumn(label: 'Student Name', flex: 3, minWidth: 180),
        AppTableColumn(
          label: 'Status',
          flex: 2,
          minWidth: 110,
          alignment: Alignment.center,
        ),
        AppTableColumn(
          label: 'Actions',
          flex: 2,
          minWidth: 150,
          alignment: Alignment.center,
        ),
      ],
      rows: List.generate(students.length, (index) {
        final student = students[index];

        return AppTableRow(
          cells: [
            Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: r.bodySmall,
                fontWeight: FontWeight.w600,
                color: colors.onSurfaceVariant,
              ),
            ),

            Text(
              student.admissionNumber,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            Text(
              student.fullName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: r.body, fontWeight: FontWeight.w500),
            ),

            _StatusBadge(
              label: student.isActive ? 'Active' : 'Inactive',
              active: student.isActive,
            ),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TableActionButton(
                  icon: Icons.edit_outlined,
                  tooltip: 'Edit',
                  onPressed: () => onEdit(student),
                ),

                SizedBox(width: r.spacingXS),

                _TableActionButton(
                  icon: Icons.delete_outline_rounded,
                  tooltip: 'Delete',
                  color: colors.error,
                  onPressed: () => onDelete(student),
                ),

                SizedBox(width: r.spacingXS),

                _TableActionButton(
                  icon: Icons.qr_code_rounded,
                  tooltip: 'QR Code',
                  onPressed: () => onViewQr(student),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);
    final colors = Theme.of(context).colorScheme;

    final backgroundColor = active
        ? colors.primary.withValues(alpha: 0.10)
        : colors.error.withValues(alpha: 0.10);

    final foregroundColor = active ? colors.primary : colors.error;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: r.spacingS,
        vertical: r.spacingXS,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: r.caption,
          fontWeight: FontWeight.w700,
          color: foregroundColor,
        ),
      ),
    );
  }
}

class _TableActionButton extends StatelessWidget {
  const _TableActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);
    final colors = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(r.radius),
        child: Padding(
          padding: EdgeInsets.all(r.spacingXS),
          child: Icon(icon, size: r.iconSmall, color: color ?? colors.primary),
        ),
      ),
    );
  }
}
