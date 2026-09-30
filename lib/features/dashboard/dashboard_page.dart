import 'package:attendance_management_system/core/widgets/app_bar_widget.dart';
import 'package:attendance_management_system/core/widgets/app_drawer.dart';
import 'package:attendance_management_system/features/attendance/attendance/dialogs/dialogs.dart';
import 'package:attendance_management_system/features/attendance/attendance/pages/active_attendance_page.dart';
import 'package:attendance_management_system/features/attendance/attendance/providers/attendance_provider.dart';
import 'package:attendance_management_system/features/attendance/attendance/results/attendance_verification_result.dart';
import 'package:attendance_management_system/features/attendance/attendance/widgets/attendance_dialog_action.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/models/lecture_session.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/providers/lecture_session_provider.dart';
import 'package:attendance_management_system/features/auth/models/user.dart';
import 'package:attendance_management_system/features/auth/providers/auth_provider.dart';
import 'package:attendance_management_system/features/courses/models/course.dart';
import 'package:attendance_management_system/features/courses/providers/course_provider.dart';
import 'package:attendance_management_system/features/qr/dialogs/bulk_qr_export_dialog.dart';
import 'package:attendance_management_system/features/scanner/pages/scanner_page.dart';
import 'package:attendance_management_system/features/students/providers/student_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'widgets/widgets.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  User? get user => context.read<AuthProvider>().currentUser;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.wait([
        context.read<StudentProvider>().loadStudents(),
        context.read<CourseProvider>().loadCourses(),
        context.read<CourseProvider>().getCoursesCount(),
      ]);

      if (!mounted) return;

      await context.read<LectureSessionProvider>().getAverageAttendance();
    });
  }

  Future<void> _showBulkExportDialog() async {
    final students = context.read<StudentProvider>().students;

    await showDialog(
      context: context,
      builder: (_) => BulkQrExportDialog(students: students),
    );
  }

  Future<Course?> _showCourseSelectionDialog() async {
    final courses = context.read<CourseProvider>().courses;

    return showDialog<Course?>(
      context: context,
      builder: (_) => SelectCourseDialog(courses: courses),
    );
  }

  Future<LectureSession?> _showLectureSessionSelectionDialog(
    List<LectureSession> sessions,
  ) async {
    return showDialog<LectureSession?>(
      context: context,
      builder: (_) => SelectLectureSessionDialog(sessions: sessions),
    );
  }

  Future<void> _startAttendance() async {
    final course = await _showCourseSelectionDialog();

    if (!mounted || course == null || course.id == null) return;

    final lectureSessionProvider = context.read<LectureSessionProvider>();

    final loaded = await lectureSessionProvider.loadLectureSessionsByCourse(
      course.id!,
    );

    if (!mounted) return;

    if (!loaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            lectureSessionProvider.errorMessage ??
                'Failed to load lecture sessions.',
          ),
        ),
      );
      return;
    }

    final session = await _showLectureSessionSelectionDialog(
      lectureSessionProvider.lectureSessions,
    );

    if (!mounted || session == null || session.id == null) return;

    if (session.isCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A completed lecture session cannot be started.'),
        ),
      );
      return;
    }

    if (session.isScheduled) {
      final success = await lectureSessionProvider.startLectureSession(session);

      if (!mounted) return;

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              lectureSessionProvider.errorMessage ??
                  'Failed to start lecture session.',
            ),
          ),
        );
        return;
      }
    }

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ActiveAttendancePage(
          lectureSession: session,
          courseName: course.title,
          courseCode: course.code,
        ),
      ),
    );
  }

  Future<void> _showScanAttendanceDialog() async {
    final action = await showDialog<AttendanceScanAction>(
      context: context,
      builder: (_) => const ScanAttendanceDialog(),
    );

    if (!mounted || action == null) return;

    switch (action) {
      case AttendanceScanAction.verify:
        await _verifyAttendance();
        break;

      case AttendanceScanAction.record:
        await _startAttendance();
        break;
    }
  }

  Future<void> _verifyAttendance() async {
    final course = await _showCourseSelectionDialog();

    if (!mounted || course == null || course.id == null) return;

    await _scanStudentForVerification(course);
  }

  Future<void> _scanStudentForVerification(Course course) async {
    final admissionNumber = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => ScannerPage()),
    );

    if (!mounted || admissionNumber == null) return;

    final provider = context.read<AttendanceProvider>();

    final result = await provider.verifyStudentAttendance(
      course: course,
      admissionNumber: admissionNumber,
    );

    if (!mounted) return;

    await _handleVerificationResult(course: course, result: result);
  }

  Future<void> _handleVerificationResult({
    required Course course,
    required AttendanceVerificationResult result,
  }) async {
    if (result.isSuccess && result.verification != null) {
      final action = await showDialog<AttendanceVerificationDialogAction>(
        context: context,
        barrierDismissible: false,
        builder: (_) =>
            AttendanceVerificationDialog(verification: result.verification!),
      );

      if (!mounted) return;

      if (action == AttendanceVerificationDialogAction.scanAgain) {
        await _scanStudentForVerification(course);
      }

      return;
    }

    if (result.isStudentNotFound) {
      final action = await showDialog<AttendanceDialogAction>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const InvalidStudentDialog(),
      );

      if (!mounted) return;

      if (action == AttendanceDialogAction.scanNext) {
        await _scanStudentForVerification(course);
      }

      return;
    }

    if (result.isStudentNotEnrolled) {
      final student = result.student;

      if (student == null) {
        await _showVerificationError(
          result.message ?? 'The student is not enrolled in this course.',
        );
        return;
      }

      final action = await showDialog<AttendanceDialogAction>(
        context: context,
        barrierDismissible: false,
        builder: (_) => StudentNotEnrolledDialog(student: student),
      );

      if (!mounted) return;

      if (action == AttendanceDialogAction.scanNext) {
        await _scanStudentForVerification(course);
      }

      return;
    }

    await _showVerificationError(
      result.message ?? 'Failed to verify student attendance.',
    );
  }

  Future<void> _showVerificationError(String message) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AttendanceErrorDialog(message: message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = context.watch<StudentProvider>();
    final courseProvider = context.watch<CourseProvider>();
    final lectureSessionProvider = context.watch<LectureSessionProvider>();

    return Scaffold(
      appBar: AppBarWidget(title: 'Dashboard'),
      endDrawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          DashboardHeader(userName: user?.name ?? 'Guest', role: 'Lecturer'),
          DashboardSection(
            title: 'Statistics',
            child: StatisticsGrid(
              children: [
                StatCard(
                  title: 'Students',
                  value: studentProvider.studentCount?.toString() ?? '-',
                  icon: Icons.people,
                ),
                StatCard(
                  title: 'Courses',
                  value: courseProvider.coursesCount ?? '-',
                  icon: Icons.menu_book,
                ),
                StatCard(
                  title: 'Attendance',
                  value: '${lectureSessionProvider.averageAttendance ?? '-'} %',
                  icon: Icons.fact_check,
                ),
                StatCard(title: 'Reports', value: '12', icon: Icons.bar_chart),
              ],
            ),
          ),
          DashboardSection(
            title: 'Quick Actions',
            child: QuickActionsGrid(
              children: [
                QuickActionCard(
                  title: 'Start Attendance',
                  icon: Icons.play_circle_fill,
                  onTap: _startAttendance,
                ),
                QuickActionCard(
                  title: 'Scan QR',
                  icon: Icons.qr_code_scanner,
                  onTap: _showScanAttendanceDialog,
                ),
                QuickActionCard(
                  title: 'Generate QR',
                  icon: Icons.qr_code,
                  onTap: _showBulkExportDialog,
                ),
                QuickActionCard(
                  title: 'Reports',
                  icon: Icons.analytics_outlined,
                  onTap: () {},
                ),
              ],
            ),
          ),
          DashboardSection(
            title: "Today's Sessions",
            actionText: 'View All',
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, index) {
                return AttendanceSessionCard(
                  courseCode: 'CSC 401',
                  courseTitle: 'Software Engineering',
                  time: '09:00 AM',
                  students: 120,
                  onTap: () {},
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
