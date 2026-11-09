import 'package:attendance_management_system/features/academic_session/pages/academic_session_page.dart';
import 'package:attendance_management_system/features/courses/pages/course_page.dart';
import 'package:attendance_management_system/features/levels/pages/level_page.dart';
import 'package:attendance_management_system/features/reports/pages/reports_page.dart';
import 'package:attendance_management_system/features/students/pages/student_page.dart';
import 'package:attendance_management_system/features/sync/pages/sync_page.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),

              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: colors.primaryContainer,
                    child: Icon(
                      Icons.fact_check_outlined,
                      size: 40,
                      color: colors.primary,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Attendance Management',
                    style: text.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Academic operations',
                    style: text.bodyMedium?.copyWith(color: colors.primary),
                  ),
                ],
              ),
            ),

            const Divider(),

            Expanded(
              child: ListView(
                children: [
                  _DrawerTile(
                    icon: Icons.dashboard_outlined,
                    title: "Dashboard",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                  ),

                  _DrawerTile(
                    icon: Icons.menu_book_outlined,
                    title: "Courses",
                    onTap: () {
                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CoursePage()),
                      );
                    },
                  ),

                  _DrawerTile(
                    icon: Icons.school_outlined,
                    title: "Levels",
                    onTap: () {
                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LevelPage()),
                      );
                    },
                  ),

                  _DrawerTile(
                    icon: Icons.calendar_month_rounded,
                    title: "Academic Sessions",
                    onTap: () {
                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AcademicSessionPage(),
                        ),
                      );
                    },
                  ),

                  _DrawerTile(
                    icon: Icons.people_outline,
                    title: "Students",
                    onTap: () {
                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const StudentPage()),
                      );
                    },
                  ),

                  _DrawerTile(
                    icon: Icons.fact_check_outlined,
                    title: "Attendance",
                    onTap: () {},
                  ),

                  _DrawerTile(
                    icon: Icons.bar_chart_outlined,
                    title: "Reports",
                    onTap: () {
                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ReportsPage()),
                      );
                    },
                  ),

                  const Divider(),

                  _DrawerTile(
                    icon: Icons.sync_outlined,
                    title: "Synchronization",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SyncPage()),
                      );
                    },
                  ),
                  _DrawerTile(
                    icon: Icons.settings_outlined,
                    title: "Settings",
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),

      title: Text(title),

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),

      onTap: onTap,
    );
  }
}
