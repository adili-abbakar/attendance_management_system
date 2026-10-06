import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/models/lecture_session.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/models/lecture_session_attendance_stats.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/widgets/widgets.dart';
import 'package:attendance_management_system/features/courses/models/course.dart';
import 'package:attendance_management_system/features/students/models/student.dart';
import 'package:flutter/material.dart';

class LectureSessionDetailsContent extends StatelessWidget {
  const LectureSessionDetailsContent({
    super.key,
    required this.course,
    required this.lectureSession,
    required this.attendanceStats,
    required this.responsive,
    required this.presentStudents,
    required this.absentStudents,
  });

  final Course course;
  final LectureSession lectureSession;
  final LectureSessionAttendanceStats? attendanceStats;
  final AppResponsive responsive;
  final List<Student> presentStudents;
  final List<Student> absentStudents;

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    return SingleChildScrollView(
      padding: EdgeInsets.all(r.pagePadding),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: r.dialogWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LectureSessionHeader(
                lectureSession: lectureSession,
                course: course,
                responsive: r,
              ),
              SizedBox(height: r.spacingL),

              LectureSessionAttendanceSummary(stats: attendanceStats),
              SizedBox(height: r.spacingL),

              LectureSessionInformationCard(lectureSession: lectureSession),
              SizedBox(height: r.spacingL),

              LectureSessionManagementActions(
                lectureSession: lectureSession,
                course: course,
              ),

              SizedBox(height: r.spacingL),

              LectureSessionAttendanceList(
                presentStudents: presentStudents,
                absentStudents: absentStudents,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
