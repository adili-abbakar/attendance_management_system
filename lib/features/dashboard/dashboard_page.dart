import 'package:attendance_management_system/core/widgets/app_bar_widget.dart';
import 'package:attendance_management_system/core/widgets/app_drawer.dart';
import 'package:attendance_management_system/features/attendance/attendance/dialogs/dialogs.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/models/lecture_session.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/providers/lecture_session_provider.dart';
import 'package:attendance_management_system/features/auth/models/user.dart';
import 'package:attendance_management_system/features/auth/providers/auth_provider.dart';
import 'package:attendance_management_system/features/courses/providers/course_provider.dart';
import 'package:attendance_management_system/features/qr/dialogs/bulk_qr_export_dialog.dart';
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
      await context.read<StudentProvider>().loadStudents();

      if (!mounted) return;

      context.read<LectureSessionProvider>().getAverageAttendance();
    });
  }

  Future<void> _showBulkExportDialog() async {
    final students = context.read<StudentProvider>().students;

    await showDialog(
      context: context,
      builder: (_) => BulkQrExportDialog(students: students),
    );
  }

  Future<LectureSession?> _showStartAttendanceDialog() async {
    final provider = context.read<LectureSessionProvider>();

    final loaded = await provider.loadLectureSessions();

    if (!mounted || !loaded) return null;

    return showDialog<LectureSession?>(
      context: context,
      builder: (_) =>
          StartAttendanceDialog(lectureSessions: provider.lectureSessions),
    );
  }

  Future<void> _startAttendance() async {
    final session = await _showStartAttendanceDialog();

    if (!mounted || session == null) return;

    final provider = context.read<LectureSessionProvider>();

    if (session.isScheduled) {
      final success = await provider.startLectureSession(session);

      if (!mounted) return;

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.errorMessage ?? 'Failed to start lecture session.',
            ),
          ),
        );
        return;
      }
    }

    if (!mounted) return;

    // TODO: Navigate to ActiveAttendancePage.
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
    // TODO: Open SelectCourseDialog and navigate to verification.
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
                  value: studentProvider.students.length.toString(),
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
