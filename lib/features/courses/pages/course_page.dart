import 'package:attendance_management_system/core/dialogs/delete_confirmation_dialog.dart';
import 'package:attendance_management_system/core/widgets/app_bar_widget.dart';
import 'package:attendance_management_system/core/widgets/app_drawer.dart';
import 'package:attendance_management_system/core/widgets/empty_state.dart';
import 'package:attendance_management_system/features/academic_session/models/academic_session.dart';

import 'package:attendance_management_system/features/courses/models/course.dart';
import 'package:attendance_management_system/features/courses/pages/course_details_page.dart';
import 'package:attendance_management_system/features/courses/providers/course_details_provider.dart';
import 'package:attendance_management_system/features/levels/models/level.dart';
import 'package:attendance_management_system/features/academic_session/providers/academic_session_provider.dart';
import 'package:attendance_management_system/features/courses/providers/course_provider.dart';
import 'package:attendance_management_system/features/levels/providers/level_provider.dart';
import 'package:attendance_management_system/features/academic_session/dialogs/academic_session_form_dialog.dart';
import 'package:attendance_management_system/features/courses/dialogs/course_form_dialog.dart';
import 'package:attendance_management_system/features/levels/dialogs/level_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../dashboard/widgets/dashboard_section.dart';
import '../widgets/course_page/course_card.dart';
import '../widgets/course_page/course_grid.dart';
import '../widgets/course_page/course_search_bar.dart';

class CoursePage extends StatefulWidget {
  const CoursePage({super.key});

  @override
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseProvider>().loadCourses();
    });
  }

  Future<void> _showCreateCourseDialog() async {
    final levelProvider = context.read<LevelProvider>();
    final academicProvider = context.read<AcademicSessionProvider>();
    final courseProvider = context.read<CourseProvider>();

    await showDialog(
      context: context,
      builder: (_) => CourseFormDialog(
        onAddLevel: () async {
          await showDialog(
            context: context,
            builder: (_) => LevelFormDialog(
              onSave: (name) async {
                return levelProvider.createLevel(
                  Level(
                    name: name,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ),
                );
              },
            ),
          );

          await levelProvider.loadLevels();
        },
        onAddAcademicSession: () async {
          await showDialog(
            context: context,
            builder: (_) => AcademicSessionFormDialog(
              onSave: (name) async {
                return academicProvider.createAcademicSession(
                  AcademicSession(
                    name: name,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ),
                );
              },
            ),
          );

          await academicProvider.loadAcademicSessions();
        },
        onSave:
            (
              String code,
              String title,
              int levelId,
              int semester,
              int academicSessionId,
            ) async {
              return courseProvider.createCourse(
                Course(
                  code: code,
                  title: title,
                  levelId: levelId,
                  academicSessionId: academicSessionId,
                  semester: semester,

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
    final levelProvider = context.read<LevelProvider>();
    final academicProvider = context.read<AcademicSessionProvider>();
    final courseProvider = context.read<CourseProvider>();

    await showDialog(
      context: context,
      builder: (_) => CourseFormDialog(
        initialCode: course.code,
        initialTitle: course.title,
        initialLevelId: course.levelId,
        initialSemester: course.semester,
        initialAcademicSessionId: course.academicSessionId,
        onAddLevel: () async {
          await showDialog(
            context: context,
            builder: (_) => LevelFormDialog(
              onSave: (name) async {
                return levelProvider.createLevel(
                  Level(
                    name: name,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ),
                );
              },
            ),
          );

          await levelProvider.loadLevels();
        },
        onAddAcademicSession: () async {
          await showDialog(
            context: context,
            builder: (_) => AcademicSessionFormDialog(
              onSave: (name) async {
                return academicProvider.createAcademicSession(
                  AcademicSession(
                    name: name,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ),
                );
              },
            ),
          );

          await academicProvider.loadAcademicSessions();
        },

        onSave:
            (
              String code,
              String title,
              int levelId,
              int semester,
              int academicSessionId,
            ) async {
              return courseProvider.updateCourse(
                course.copyWith(
                  code: code,
                  title: title,
                  levelId: levelId,
                  semester: semester,
                  academicSessionId: academicSessionId,
                ),
              );
            },
      ),
    );
  }

  Future<void> _showDeleteCourseDialog(Course course) async {
    final courseProvider = context.read<CourseProvider>();
    final messenger = ScaffoldMessenger.of(context);

    await showDialog(
      context: context,
      builder: (_) => DeleteConfirmationDialog(
        title: 'Delete Course',
        itemName: '${course.code} - ${course.title}',
        onDelete: () async {
          final success = await courseProvider.deleteCourse(course.id!);

          if (!mounted) return;

          if (!success) {
            messenger.showSnackBar(
              const SnackBar(content: Text('Failed to delete course.')),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = context.watch<CourseProvider>();
    final courses = courseProvider.courses;

    return Scaffold(
      appBar: const AppBarWidget(title: 'Courses'),
      endDrawer: const AppDrawer(),

      body: courseProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                DashboardSection(
                  title: 'Manage Courses',
                  child: Column(
                    children: [
                      CourseSearchBar(
                        onChanged: (_) {},
                        controller: _searchController,
                        onAddPressed: _showCreateCourseDialog,
                      ),

                      const SizedBox(height: 12),

                      if (courses.isEmpty)
                        const EmptyState(
                          title: 'No Courses',
                          message: 'Create your first course.',
                          icon: Icons.menu_book_outlined,
                        )
                      else
                        CourseGrid(
                          children: courses
                              .map(
                                (course) => CourseCard(
                                  code: course.code,
                                  title: course.title,
                                  level: course.levelName ?? '-',
                                  semester: course.semester,
                                  session: course.academicSessionName ?? '-',
                                  studentCount: course.studentCount,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ChangeNotifierProvider(
                                          create: (_) =>
                                              CourseDetailsProvider(course)
                                                ..loadStudents(),
                                          child: CourseDetailsPage(
                                            course: course,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
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
                const SizedBox(height: 16),
              ],
            ),
    );
  }
}
