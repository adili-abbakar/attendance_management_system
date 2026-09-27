import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:attendance_management_system/core/table/table.dart';
import 'package:attendance_management_system/features/academic_session/models/academic_session.dart';
import 'package:flutter/material.dart';

class AcademicSessionTable extends StatelessWidget {
  const AcademicSessionTable({
    super.key,
    required this.sessions,
    required this.onEdit,
    required this.onDelete,
  });

  final List<AcademicSession> sessions;
  final ValueChanged<AcademicSession> onEdit;
  final ValueChanged<AcademicSession> onDelete;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);
    final colors = Theme.of(context).colorScheme;

    return AppDataTable(
      columns: const [
        AppTableColumn(
          label: '#',
          flex: 1,
          minWidth: 60,
          alignment: Alignment.center,
        ),
        AppTableColumn(label: 'Academic Session', flex: 4, minWidth: 180),
        AppTableColumn(
          label: 'Actions',
          flex: 2,
          minWidth: 120,
          alignment: Alignment.center,
        ),
      ],
      rows: List.generate(sessions.length, (index) {
        final session = sessions[index];

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
              session.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: r.body,
                fontWeight: FontWeight.w500,
                color: colors.onSurface,
              ),
            ),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TableActionButton(
                  icon: Icons.edit_outlined,
                  tooltip: 'Edit',
                  onPressed: () => onEdit(session),
                ),
                SizedBox(width: r.spacingXS),
                _TableActionButton(
                  icon: Icons.delete_outline_rounded,
                  tooltip: 'Delete',
                  color: colors.error,
                  onPressed: () => onDelete(session),
                ),
              ],
            ),
          ],
        );
      }),
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
