import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:attendance_management_system/features/attendance/models/lecture_session.dart';
import 'package:attendance_management_system/features/attendance/providers/attendance_provider.dart';
import 'package:attendance_management_system/features/attendance/widgets/attendance_session_form.dart';

class CreateAttendanceSessionPage extends StatelessWidget {
  const CreateAttendanceSessionPage({
    super.key,
    required this.courseId,
    required this.courseName,
  });

  final int courseId;
  final String courseName;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Attendance Session')),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(r.pagePadding),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: r.dialogWidth),
            child: Consumer<AttendanceProvider>(
              builder: (context, provider, child) {
                return AttendanceSessionForm(
                  isLoading: provider.isLoading,
                  onSubmit: (session) async {
                    final success = await provider.createSession(session);

                    if (!context.mounted) {
                      return;
                    }

                    if (success) {
                      Navigator.pop(context);
                    }
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
