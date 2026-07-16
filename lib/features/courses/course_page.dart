import 'package:attendance_management_system/core/widgets/app_bar_widget.dart';
import 'package:attendance_management_system/core/widgets/app_drawer.dart';
import 'package:attendance_management_system/core/widgets/empty_state.dart';
import 'package:attendance_management_system/data/models/course.dart';
import 'package:attendance_management_system/data/providers/course_provider.dart';
import 'package:attendance_management_system/features/courses/widgets/course_form_dialog.dart';
import 'package:attendance_management_system/features/courses/widgets/delete_course_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../dashboard/widgets/dashboard_section.dart';
import '../dashboard/widgets/stat_card.dart';
import '../dashboard/widgets/statistics_grid.dart';

import 'widgets/course_card.dart';
import 'widgets/course_grid.dart';
import 'widgets/course_search_bar.dart';

class CoursePage extends StatefulWidget {
  const CoursePage({super.key});

  @override
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseProvider>().loadCourses();
    });
  }

  Future<void> _showCreateCourseDialog() async {
    await showDialog(
      context: context,
      builder: (_) => CourseFormDialog(
        onSave: (code, title, level, semester, session) async {
          return context.read<CourseProvider>().createCourse(
            Course(
              code: code,
              title: title,
              level: level,
              semester: semester,
              academicSession: session,
              isActive: true,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showEditCourseDialog(Course course) async {
    await showDialog(
      context: context,
      builder: (_) => CourseFormDialog(
        initialCode: course.code,
        initialTitle: course.title,
        initialLevel: course.level,
        initialSemester: course.semester,
        initialSession: course.academicSession,

        onSave: (code, title, level, semester, session) async {
          return context.read<CourseProvider>().updateCourse(
            course.copyWith(
              code: code,
              title: title,
              level: level,
              semester: semester,
              academicSession: session,
            ),
          );
        },
      ),
    );
  }

  Future<void> _showDeleteCourseDialog(Course course) async {
    await showDialog(
      context: context,
      builder: (_) => DeleteCourseDialog(
        course: course,
        onDelete: () async {
          final success = await context.read<CourseProvider>().deleteCourse(
            course.id!,
          );

          if (!mounted) return;

          if (!success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to delete course.')),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();
    final courses = provider.courses;

    final semesterOneCount = courses.where((e) => e.semester == 1).length;

    final semesterTwoCount = courses.where((e) => e.semester == 2).length;

    final activeCount = courses.where((e) => e.isActive).length;

    return Scaffold(
      appBar: const AppBarWidget(title: "Courses"),
      endDrawer: const AppDrawer(),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateCourseDialog,
        icon: const Icon(Icons.add),
        label: const Text("Add Course"),
      ),

      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                DashboardSection(
                  title: "Statistics",
                  child: StatisticsGrid(
                    children: [
                      StatCard(
                        title: "Total Courses",
                        value: courses.length.toString(),
                        icon: Icons.menu_book,
                      ),
                      StatCard(
                        title: "Semester 1",
                        value: semesterOneCount.toString(),
                        icon: Icons.looks_one,
                      ),
                      StatCard(
                        title: "Semester 2",
                        value: semesterTwoCount.toString(),
                        icon: Icons.looks_two,
                      ),
                      StatCard(
                        title: "Active",
                        value: activeCount.toString(),
                        icon: Icons.check_circle_outline,
                      ),
                    ],
                  ),
                ),

                DashboardSection(
                  title: "Manage Courses",
                  child: Column(
                    children: [
                      CourseSearchBar(
                        onChanged: (_) {},
                        onAddPressed: _showCreateCourseDialog,
                      ),

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
                                  session: course.academicSession,
                                  onTap: () {},

                                  // We'll implement these next.
                                  onEdit: () => _showEditCourseDialog(course),

                                  onDelete: () =>
                                      _showDeleteCourseDialog(course),
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
