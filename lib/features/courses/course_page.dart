import 'package:attendance_management_system/core/widgets/app_bar_widget.dart';
import 'package:attendance_management_system/core/widgets/app_drawer.dart';
import 'package:flutter/material.dart';

import './widgets/course_card.dart';
import './widgets/course_grid.dart';
import './widgets/course_search_bar.dart';

import '../dashboard/widgets/dashboard_section.dart';
import '../dashboard/widgets/stat_card.dart';
import '../dashboard/widgets/statistics_grid.dart';

import '../../../core/widgets/empty_state.dart';

class CoursePage extends StatelessWidget {
  const CoursePage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with Provider later
    final courses = List.generate(
      8,
      (index) => (
        code: "CSC40${index + 1}",
        title: "Software Engineering ${index + 1}",
        level: "400",
        semester: 2,
        session: "2025/2026",
      ),
    );

    return Scaffold(
      appBar: const AppBarWidget(title: "Courses"),
      endDrawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Course"),
      ),

      body: ListView(
        children: [
          DashboardSection(
            title: "Statistics",

            child: StatisticsGrid(
              children: const [
                StatCard(
                  title: "Total Courses",
                  value: "8",
                  icon: Icons.menu_book,
                ),

                StatCard(
                  title: "Semester 1",
                  value: "4",
                  icon: Icons.looks_one,
                ),

                StatCard(
                  title: "Semester 2",
                  value: "4",
                  icon: Icons.looks_two,
                ),

                StatCard(
                  title: "Active",
                  value: "8",
                  icon: Icons.check_circle_outline,
                ),
              ],
            ),
          ),

          DashboardSection(
            title: "Manage Courses",

            child: Column(
              children: [
                CourseSearchBar(onChanged: (value) {}, onAddPressed: () {}),

                const SizedBox(height: 20),

                if (courses.isEmpty)
                  const EmptyState(
                    title: "No Courses",
                    message: "Create your first course.",
                    icon: Icons.menu_book_outlined,
                  )
                else
                  CourseGrid(
                    children: courses
                        .map(
                          (course) => CourseCard(
                            code: course.code,
                            title: course.title,
                            level: course.level,
                            semester: course.semester,
                            session: course.session,
                            onTap: () {},
                            onEdit: () {},
                            onDelete: () {},
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
