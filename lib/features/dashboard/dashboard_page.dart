import 'package:attendance_management_system/core/widgets/app_bar_widget.dart';
import 'package:attendance_management_system/core/widgets/app_drawer.dart';
import 'package:attendance_management_system/features/attendance/attendance/dialogs/scan_attendance_dialog.dart';
import 'package:attendance_management_system/features/attendance/attendance/dialogs/select_course_dialog.dart';
import 'package:attendance_management_system/features/attendance/attendance/dialogs/select_lecture_session_dialog.dart';
import 'package:attendance_management_system/features/attendance/attendance/pages/active_attendance_page.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/models/lecture_session.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/pages/lecture_session_details_page.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/pages/todays_sessions_page.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/providers/lecture_session_provider.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/widgets/lecture_session_tile.dart';
import 'package:attendance_management_system/features/attendance/verification/helpers/attendance_verification_helper.dart';
import 'package:attendance_management_system/features/auth/models/user.dart';
import 'package:attendance_management_system/features/auth/providers/auth_provider.dart';
import 'package:attendance_management_system/features/courses/models/course.dart';
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
      await Future.wait([
        context.read<StudentProvider>().loadStudents(),
        context.read<CourseProvider>().loadCourses(),
        context.read<CourseProvider>().getCoursesCount(),
        context.read<LectureSessionProvider>().loadTodayLectureSessions(),
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

    if (!mounted || course == null || course.id == null) {
      return;
    }

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

    if (!mounted || session == null || session.id == null) {
      return;
    }

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

    if (!mounted || course == null || course.id == null) {
      return;
    }

    await AttendanceVerificationHelper.verifyStudent(
      context: context,
      course: course,
    );
  }

  Course? _findCourse(CourseProvider courseProvider, int courseId) {
    for (final course in courseProvider.courses) {
      if (course.id == courseId) {
        return course;
      }
    }

    return null;
  }

  void _openTodaysSessions() {
    final lectureSessionProvider = context.read<LectureSessionProvider>();
    final courseProvider = context.read<CourseProvider>();
    final sessions = lectureSessionProvider.todayLectureSessions;

    final sessionData = sessions.map((session) {
      final course = _findCourse(courseProvider, session.courseId);

      return LectureSessionTileData(
        courseCode: course?.code ?? 'Unknown Course',
        courseTitle: course?.title ?? 'Unknown Course',
        sessionName: session.lectureSessionName,
        time: '${session.fromTime} - ${session.toTime}',
        students: course?.studentCount ?? 0,
        status: _sessionStatusLabel(session),
        onTap: course == null
            ? null
            : () => _openLectureSessionDetails(context, session, course),
      );
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TodaysSessionsPage(sessions: sessionData),
      ),
    );
  }

  void _openLectureSessionDetails(
    BuildContext context,
    LectureSession lectureSession,
    Course course,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LectureSessionDetailsPage(
          lectureSessionId: lectureSession.id!,
          courseName: course.title,
          courseCode: course.code,
          startSession: (session) =>
              _startSessionFromDashboard(context, session, course),
          completeSession: (session) =>
              _completeSessionFromDashboard(context, session),
          viewAttendance: (session) =>
              _viewAttendanceFromDashboard(context, session, course),
        ),
      ),
    );
  }

  Future<void> _startSessionFromDashboard(
    BuildContext context,
    LectureSession lectureSession,
    Course course,
  ) async {
    final provider = context.read<LectureSessionProvider>();

    final success = await provider.startLectureSession(lectureSession);

    if (!context.mounted) return;

    if (!success) {
      _showResult(
        context,
        provider.errorMessage ?? 'Failed to start lecture session.',
      );
      return;
    }

    final updatedSession =
        provider.selectedLectureSession ??
        lectureSession.copyWith(status: LectureSessionStatus.active);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ActiveAttendancePage(
          lectureSession: updatedSession,
          courseName: course.title,
          courseCode: course.code,
        ),
      ),
    );
  }

  Future<void> _completeSessionFromDashboard(
    BuildContext context,
    LectureSession lectureSession,
  ) async {
    final provider = context.read<LectureSessionProvider>();

    final success = await provider.completeLectureSession(lectureSession);

    if (!context.mounted) return;

    _showResult(
      context,
      success
          ? 'Lecture session completed.'
          : provider.errorMessage ?? 'Failed to complete lecture session.',
    );
  }

  void _viewAttendanceFromDashboard(
    BuildContext context,
    LectureSession lectureSession,
    Course course,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ActiveAttendancePage(
          lectureSession: lectureSession,
          courseCode: course.code,
          courseName: course.title,
        ),
      ),
    );
  }

  String _sessionStatusLabel(LectureSession session) {
    switch (session.status) {
      case LectureSessionStatus.scheduled:
        return 'Scheduled';

      case LectureSessionStatus.active:
        return 'Active';

      case LectureSessionStatus.completed:
        return 'Completed';
    }
  }

  LectureSessionTileData _buildTodaySessionTileData(
    LectureSession session,
    CourseProvider courseProvider,
  ) {
    final course = _findCourse(courseProvider, session.courseId);

    return LectureSessionTileData(
      courseCode: course?.code ?? 'Unknown Course',
      courseTitle: course?.title ?? 'Unknown Course',
      sessionName: session.lectureSessionName,
      time: '${session.fromTime} - ${session.toTime}',
      students: course?.studentCount ?? 0,
      status: _sessionStatusLabel(session),
      onTap: course == null
          ? null
          : () => _openLectureSessionDetails(context, session, course),
    );
  }

  void _showResult(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = context.watch<StudentProvider>();
    final courseProvider = context.watch<CourseProvider>();
    final lectureSessionProvider = context.watch<LectureSessionProvider>();

    final todaySessions = lectureSessionProvider.todayLectureSessions;

    final visibleTodaySessions = todaySessions
        .take(4)
        .map((session) => _buildTodaySessionTileData(session, courseProvider))
        .toList();

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
            onActionPressed: _openTodaysSessions,
            child: visibleTodaySessions.isEmpty
                ? const _NoTodaySessions()
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: visibleTodaySessions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, index) {
                      final session = visibleTodaySessions[index];

                      return LectureSessionTile(
                        courseCode: session.courseCode,
                        courseTitle: session.courseTitle,
                        sessionName: session.sessionName,
                        time: session.time,
                        students: session.students,
                        status: session.status,
                        onTap: session.onTap,
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

class _NoTodaySessions extends StatelessWidget {
  const _NoTodaySessions();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      color: colors.surfaceBright,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Row(
          children: [
            Icon(
              Icons.event_available_outlined,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No lecture sessions scheduled for today.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
