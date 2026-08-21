import 'package:flutter/material.dart';

import 'package:attendance_management_system/core/responsive/app_responsive.dart';

class CourseActionsBar extends StatelessWidget {
  const CourseActionsBar({
    super.key,
    required this.onImportStudents,
    required this.onAddStudent,
    required this.onLectureSessions,
    required this.onRefresh,
  });

  final VoidCallback onImportStudents;
  final VoidCallback onAddStudent;
  final VoidCallback onLectureSessions;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: r.cardPadding,
          vertical: r.spacingS,
        ),
        child: Wrap(
          spacing: r.spacingS,
          runSpacing: r.spacingS,
          alignment: WrapAlignment.start,
          children: [
            FilledButton.icon(
              onPressed: onImportStudents,
              style: FilledButton.styleFrom(
                minimumSize: Size(0, r.buttonHeight),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.symmetric(
                  horizontal: r.spacingM,
                  vertical: r.spacingS,
                ),
              ),
              icon: Icon(Icons.upload_file_outlined, size: r.buttonIcon),
              label: Text(
                'Import Students',
                style: TextStyle(fontSize: r.body),
              ),
            ),

            OutlinedButton.icon(
              onPressed: onAddStudent,
              style: OutlinedButton.styleFrom(
                minimumSize: Size(0, r.buttonHeight),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.symmetric(
                  horizontal: r.spacingM,
                  vertical: r.spacingS,
                ),
              ),
              icon: Icon(Icons.person_add_alt_1_outlined, size: r.buttonIcon),
              label: Text('Add Student', style: TextStyle(fontSize: r.body)),
            ),

            OutlinedButton.icon(
              onPressed: onLectureSessions,
              style: OutlinedButton.styleFrom(
                minimumSize: Size(0, r.buttonHeight),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.symmetric(
                  horizontal: r.spacingM,
                  vertical: r.spacingS,
                ),
              ),
              icon: Icon(Icons.event_note_outlined, size: r.buttonIcon),
              label: Text(
                'Lecture Sessions',
                style: TextStyle(fontSize: r.body),
              ),
            ),

            OutlinedButton.icon(
              onPressed: onRefresh,
              style: OutlinedButton.styleFrom(
                minimumSize: Size(0, r.buttonHeight),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.symmetric(
                  horizontal: r.spacingM,
                  vertical: r.spacingS,
                ),
              ),
              icon: Icon(Icons.refresh, size: r.buttonIcon),
              label: Text('Refresh', style: TextStyle(fontSize: r.body)),
            ),
          ],
        ),
      ),
    );
  }
}
