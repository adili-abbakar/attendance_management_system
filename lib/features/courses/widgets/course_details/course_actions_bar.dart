import 'package:attendance_management_system/core/buttons/buttons.dart';
import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:flutter/material.dart';

class CourseActionsBar extends StatelessWidget {
  const CourseActionsBar({
    super.key,
    required this.onImportStudents,
    required this.onAddStudent,
    required this.onLectureSessions,
    required this.onVerifyAttendance,
    required this.onRefresh,
    required this.onExportBulkQr,
  });

  final VoidCallback onImportStudents;
  final VoidCallback onAddStudent;
  final VoidCallback onLectureSessions;
  final VoidCallback onVerifyAttendance;
  final VoidCallback onRefresh;
  final VoidCallback onExportBulkQr;

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
            PrimaryButton(
              text: 'Import Students',
              icon: Icons.upload_file_outlined,
              onPressed: onImportStudents,
            ),

            AppOutlinedButton(
              text: 'Add Student',
              icon: Icons.person_add_alt_1_outlined,
              onPressed: onAddStudent,
              fullWidth: false,
            ),

            AppOutlinedButton(
              text: 'Lecture Sessions',
              icon: Icons.event_note_outlined,
              onPressed: onLectureSessions,
              fullWidth: false,
            ),

            AppOutlinedButton(
              text: 'Verify Attendance',
              icon: Icons.fact_check_outlined,
              onPressed: onVerifyAttendance,
              fullWidth: false,
            ),

            AppOutlinedButton(
              text: 'Export QR',
              icon: Icons.qr_code_2_outlined,
              onPressed: onExportBulkQr,
              fullWidth: false,
            ),

            AppOutlinedButton(
              text: 'Refresh',
              icon: Icons.refresh_rounded,
              onPressed: onRefresh,
              fullWidth: false,
            ),
          ],
        ),
      ),
    );
  }
}