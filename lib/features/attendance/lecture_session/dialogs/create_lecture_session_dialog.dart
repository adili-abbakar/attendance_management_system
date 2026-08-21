import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/providers/lecture_session_provider.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/widgets/lecture_session_form.dart';

class CreateLectureSessionDialog extends StatelessWidget {
  const CreateLectureSessionDialog({
    super.key,
    required this.courseId,
    required this.courseName,
  });

  final int courseId;
  final String courseName;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);

    return AlertDialog(
      insetPadding: EdgeInsets.all(r.dialogInset),
      title: Text(
        'Create Lecture Session',
        style: TextStyle(fontSize: r.titleLarge),
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: r.dialogWidth),
        child: SingleChildScrollView(
          child: Consumer<LectureSessionProvider>(
            builder: (context, provider, child) {
              return LectureSessionForm(
                courseId: courseId,
                isLoading: provider.isLoading,
                onSubmit: (lectureSession) async {
                  final success = await provider.createLectureSession(
                    lectureSession,
                  );

                  if (!context.mounted) return;

                  if (success) {
                    Navigator.pop(context, true);
                  }
                },
              );
            },
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: providerIsLoading(context)
              ? null
              : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  bool providerIsLoading(BuildContext context) {
    return context.read<LectureSessionProvider>().isLoading;
  }
}
