import 'package:attendance_management_system/core/widgets/app_bar_widget.dart';
import 'package:attendance_management_system/core/widgets/app_drawer.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/models/lecture_session.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/pages/lecture_sessions_page.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/providers/lecture_session_provider.dart';
import 'package:attendance_management_system/features/auth/models/user.dart';
import 'package:attendance_management_system/features/auth/providers/auth_provider.dart';
import 'package:attendance_management_system/features/courses/providers/course_provider.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProvider>().getStudentsCount();
      context.read<CourseProvider>().getCoursesCount();
      context.read<LectureSessionProvider>().getAverageAttendance();
    });
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
          DashboardHeader(userName: user?.name ?? 'Guest', role: "Lecturer"),

          DashboardSection(
            title: "Statistics",
            child: StatisticsGrid(
              children: [
                StatCard(
                  title: "Students",
                  value: studentProvider.studentCount ?? '-',
                  icon: Icons.people,
                ),
                StatCard(
                  title: "Courses",
                  value: courseProvider.coursesCount ?? '-',
                  icon: Icons.menu_book,
                ),
                StatCard(
                  title: "Attendance",
                  value: "${lectureSessionProvider.averageAttendance ?? '-'} %",
                  icon: Icons.fact_check,
                ),
                StatCard(title: "Reports", value: "12", icon: Icons.bar_chart),
              ],
            ),
          ),

          DashboardSection(
            title: "Quick Actions",
            child: QuickActionsGrid(
              children: [
                QuickActionCard(
                  title: "Start Attendance",
                  icon: Icons.play_circle_fill,
                  onTap: () {},
                ),
                QuickActionCard(
                  title: "Scan QR",
                  icon: Icons.qr_code_scanner,
                  onTap: () {},
                ),
                QuickActionCard(
                  title: "Generate QR",
                  icon: Icons.qr_code,
                  onTap: () {},
                ),
                QuickActionCard(
                  title: "Reports",
                  icon: Icons.analytics_outlined,
                  onTap: () {},
                ),
              ],
            ),
          ),

          DashboardSection(
            title: "Today's Sessions",
            actionText: "View All",
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, index) {
                return AttendanceSessionCard(
                  courseCode: "CSC 401",
                  courseTitle: "Software Engineering",
                  time: "09:00 AM",
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
