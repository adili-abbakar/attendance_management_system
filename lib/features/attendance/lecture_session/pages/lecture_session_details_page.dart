import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:attendance_management_system/core/widgets/widgets.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/providers/lecture_session_provider.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/widgets/lecture_session_details/widgets.dart';
import 'package:attendance_management_system/features/courses/models/course.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LectureSessionDetailsPage extends StatefulWidget {
  const LectureSessionDetailsPage({
    super.key,
    required this.lectureSessionId,
    required this.course,
  });

  final int lectureSessionId;
  final Course course;

  @override
  State<LectureSessionDetailsPage> createState() =>
      _LectureSessionDetailsPageState();
}

class _LectureSessionDetailsPageState extends State<LectureSessionDetailsPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      context.read<LectureSessionProvider>().loadLectureSession(
        widget.lectureSessionId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);

    return Scaffold(
      appBar: AppBarWidget(title: 'Lecture Session Details'),
      endDrawer: const AppDrawer(),
      body: Consumer<LectureSessionProvider>(
        builder: (context, provider, child) {
          final lectureSession = provider.selectedLectureSession;

          if (provider.isLoading && lectureSession == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (lectureSession == null) {
            return LectureSessionErrorState(message: provider.errorMessage);
          }

          return LectureSessionDetailsContent(
            course: widget.course,
            lectureSession: lectureSession,
            attendanceStats: provider.selectedSessionAttendanceStats,
            presentStudents: provider.presentStudents,
            absentStudents: provider.absentStudents,
            responsive: r,
          );
        },
      ),
    );
  }
}
