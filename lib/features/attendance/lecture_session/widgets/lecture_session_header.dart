import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/models/lecture_session.dart';
import 'package:attendance_management_system/features/courses/models/course.dart';
import 'package:flutter/material.dart';

class LectureSessionHeader extends StatelessWidget {
  const LectureSessionHeader({
    super.key,
    required this.lectureSession,
    required this.course,
    required this.responsive,
  });

  final LectureSession lectureSession;
  final Course course;
  final AppResponsive responsive;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lectureSession.lectureSessionName,
          style: TextStyle(
            fontSize: responsive.headline,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: responsive.spacingXS),
        Text(
          '${course.title} (${course.code})',
          style: TextStyle(
            fontSize: responsive.body,
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}