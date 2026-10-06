import 'package:attendance_management_system/core/buttons/buttons.dart';
import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/helpers/lecture_session_helper.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/models/lecture_session.dart';
import 'package:attendance_management_system/features/courses/models/course.dart';
import 'package:flutter/material.dart';

class LectureSessionManagementActions extends StatelessWidget {
  const LectureSessionManagementActions({
    super.key,
    required this.lectureSession,
    required this.course,
  });

  final LectureSession lectureSession;
  final Course course;

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
            if (!lectureSession.isActive && !lectureSession.isCompleted)
              AppOutlinedButton(
                text: 'Start Session',
                icon: Icons.play_arrow_outlined,
                onPressed: () {
                  LectureSessionHelper.startSession(
                    context,
                    lectureSession,
                    course: course,
                  );
                },
                fullWidth: false,
              ),

            if (lectureSession.isActive)
              PrimaryButton(
                text: 'Complete Session',
                icon: Icons.check_circle_outline,
                onPressed: () {
                  LectureSessionHelper.completeSession(context, lectureSession);
                },
              ),

            AppOutlinedButton(
              text: 'View Attendance',
              icon: Icons.fact_check_outlined,
              onPressed: () {
                LectureSessionHelper.viewAttendance(
                  context,
                  lectureSession,
                  course: course,
                );
              },
              fullWidth: false,
            ),

            AppOutlinedButton(
              text: 'Edit',
              icon: Icons.edit_outlined,
              onPressed: () {
                LectureSessionHelper.updateSession(
                  context,
                  lectureSession,
                  course.id!,
                );
              },
              fullWidth: false,
            ),

            AppOutlinedButton(
              text: 'Delete',
              icon: Icons.delete_outline,
              onPressed: () {
                LectureSessionHelper.showDeleteSessionDialog(
                  context,
                  lectureSession,
                  course.code,
                );
              },
              fullWidth: false,
            ),
          ],
        ),
      ),
    );
  }
}
