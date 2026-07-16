import 'package:attendance_management_system/core/widgets/auth_tile.dart';
import 'package:attendance_management_system/features/courses/course_page.dart';
import 'package:attendance_management_system/features/dashboard/dashboard_page.dart';
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
                    child: Icon(Icons.person, size: 40, color: colors.primary),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    "Dr. John Doe",
                    style: text.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    "Lecturer",
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

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DashboardPage(),
                        ),
                      );
                    },
                  ),

                  _DrawerTile(
                    icon: Icons.menu_book_outlined,
                    title: "Courses",
                    onTap: () {
                      Navigator.pop(context);

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const CoursePage()),
                      );
                    },
                  ),

                  _DrawerTile(
                    icon: Icons.people_outline,
                    title: "Students",
                    onTap: () {},
                  ),

                  _DrawerTile(
                    icon: Icons.fact_check_outlined,
                    title: "Attendance",
                    onTap: () {},
                  ),

                  _DrawerTile(
                    icon: Icons.bar_chart_outlined,
                    title: "Reports",
                    onTap: () {},
                  ),

                  const Divider(),

                  _DrawerTile(
                    icon: Icons.person_outline,
                    title: "Profile",
                    onTap: () {},
                  ),

                  _DrawerTile(
                    icon: Icons.settings_outlined,
                    title: "Settings",
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const Divider(),

            Padding(
              padding: const EdgeInsets.all(12),

              child: AuthTile(),
              //  ListTile(
              //   shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(12),
              //   ),

              //   leading: const Icon(Icons.logout_rounded, color: Colors.red),

              //   title: const Text("Logout"),

              //   onTap: () {},
              // ),
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
