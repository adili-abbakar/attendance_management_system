import 'package:attendance_management_system/core/widgets/app_bar_widget.dart';
import 'package:attendance_management_system/core/widgets/app_drawer.dart';
import 'package:attendance_management_system/features/auth/models/user.dart';
import 'package:attendance_management_system/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/dashboard_section.dart';
import 'widgets/stat_card.dart';
import 'widgets/statistics_grid.dart';
import 'widgets/quick_action_card.dart';
import 'widgets/quick_actions_grid.dart';
import 'widgets/attendance_session_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  User? get user => context.read<AuthProvider>().currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: 'Dashboard'),
      endDrawer: const AppDrawer(),
      body: ListView(
        children: [
          DashboardHeader(userName: user?.name ?? 'Guest', role: "Lecturer"),

          DashboardSection(
            title: "Statistics",

            child: StatisticsGrid(
              children: [
                StatCard(title: "Students", value: "520", icon: Icons.people),

                StatCard(title: "Courses", value: "8", icon: Icons.menu_book),

                StatCard(
                  title: "Attendance",
                  value: "94%",
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

              separatorBuilder: (_, __) => const SizedBox(height: 12),

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

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
