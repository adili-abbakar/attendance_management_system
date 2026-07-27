import 'package:attendance_management_system/features/courses/enrollments/dialogs/add_course_students_dialog.dart';
import 'package:attendance_management_system/features/courses/enrollments/providers/add_course_students_provider.dart';
import 'package:attendance_management_system/features/courses/models/course.dart';
import 'package:attendance_management_system/features/courses/providers/course_details_provider.dart';
import 'package:attendance_management_system/features/courses/widgets/course_details/course_actions_bar.dart';
import 'package:attendance_management_system/features/courses/widgets/course_details/course_header.dart';
import 'package:attendance_management_system/features/courses/widgets/course_details/course_statistics.dart';
import 'package:attendance_management_system/features/courses/widgets/course_details/enrolled_students_table.dart';
import 'package:attendance_management_system/features/courses/widgets/course_details/student_filters.dart';
import 'package:attendance_management_system/features/courses/widgets/course_details/student_pagination.dart';
import 'package:attendance_management_system/features/courses/widgets/course_details/student_search_bar.dart';
import 'package:attendance_management_system/features/students/models/student.dart';
import 'package:attendance_management_system/features/students/services/student_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendance_management_system/features/courses/enrollments/dialogs/import_course_students_dialog.dart';
import 'package:attendance_management_system/features/courses/enrollments/providers/course_student_import_provider.dart';
import 'package:attendance_management_system/features/students/providers/student_provider.dart';

class CourseDetailsPage extends StatefulWidget {
  const CourseDetailsPage({super.key, required this.course});

  final Course course;

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showImportStudentsDialog(Course course) {
    showDialog(
      context: context,
      builder: (_) => ChangeNotifierProvider(
        create: (context) =>
            CourseStudentImportProvider(context.read<StudentProvider>()),
        child: ImportCourseStudentsDialog(courseId: course.id!),
      ),
    );
    if (!mounted) return;

    context.read<CourseDetailsProvider>().loadStudents();
  }

  void _showAddStudentsDialog() {
    showDialog(
      context: context,
      builder: (_) => ChangeNotifierProvider(
        create: (_) => AddCourseStudentsProvider(
          courseId: widget.course.id!,
          studentService: StudentService.instance,
        )..loadStudents(),
        child: AddCourseStudentsDialog(courseId: widget.course.id!),
      ),
    );
  }

  Future<void> _removeStudent(Student student) async {
    final provider = context.read<CourseDetailsProvider>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove Student'),
        content: Text('Remove ${student.fullName} from this course?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await provider.removeStudent(student);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Student removed from course.'
              : 'Unable to remove student.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseDetailsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Course Details')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1300),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CourseHeader(course: widget.course),

                      const SizedBox(height: 24),

                      CourseStatistics(
                        totalStudents: provider.students.length,
                        totalAttendanceSessions: 0,
                        averageAttendance: 0,
                      ),

                      const SizedBox(height: 24),

                      CourseActionsBar(
                        onImportStudents: () =>
                            _showImportStudentsDialog(widget.course),
                        onAddStudent: _showAddStudentsDialog,
                        onRefresh: provider.loadStudents,
                      ),

                      const SizedBox(height: 32),

                      StudentSearchBar(
                        controller: _searchController,
                        onChanged: provider.search,
                      ),

                      const SizedBox(height: 16),

                      StudentFilters(
                        showActiveOnly: provider.showActiveOnly,
                        sortAscending: provider.sortAscending,
                        onShowActiveChanged: provider.setShowActiveOnly,
                        onSortChanged: provider.setSortAscending,
                      ),
                      const SizedBox(height: 24),

                      if (provider.isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else
                        EnrolledStudentsTable(
                          students: provider.paginatedStudents,
                          onRemoveStudent: _removeStudent,
                          startIndex:
                              (provider.currentPage - 1) * provider.pageSize,
                        ),

                      StudentPagination(
                        currentPage: provider.currentPage,
                        totalPages: provider.totalPages,
                        onPrevious: provider.currentPage > 1
                            ? provider.previousPage
                            : null,
                        onNext: provider.currentPage < provider.totalPages
                            ? provider.nextPage
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
