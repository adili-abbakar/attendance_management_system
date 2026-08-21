import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:attendance_management_system/core/responsive/app_responsive.dart';

import 'package:attendance_management_system/features/courses/enrollments/dialogs/add_course_students_dialog.dart';
import 'package:attendance_management_system/features/courses/enrollments/dialogs/import_course_students_dialog.dart';
import 'package:attendance_management_system/features/courses/enrollments/providers/add_course_students_provider.dart';
import 'package:attendance_management_system/features/courses/enrollments/providers/course_student_import_provider.dart';

import 'package:attendance_management_system/features/courses/models/course.dart';
import 'package:attendance_management_system/features/courses/providers/course_details_provider.dart';

import 'package:attendance_management_system/features/courses/widgets/course_details/course_details.dart';

import 'package:attendance_management_system/features/students/models/student.dart';
import 'package:attendance_management_system/features/students/providers/student_provider.dart';
import 'package:attendance_management_system/features/students/services/student_service.dart';

import 'package:attendance_management_system/features/attendance/lecture_session/pages/lecture_sessions_page.dart';

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

  Future<void> _showImportStudentsDialog(Course course) async {
    await showDialog(
      context: context,
      builder: (_) => ChangeNotifierProvider(
        create: (context) =>
            CourseStudentImportProvider(context.read<StudentProvider>()),
        child: ImportCourseStudentsDialog(courseId: course.id!),
      ),
    );

    if (!mounted) return;

    await context.read<CourseDetailsProvider>().loadStudents();
  }

  Future<void> _showAddStudentsDialog() async {
    await showDialog(
      context: context,
      builder: (_) => ChangeNotifierProvider(
        create: (_) => AddCourseStudentsProvider(
          courseId: widget.course.id!,
          studentService: StudentService.instance,
        )..loadStudents(),
        child: AddCourseStudentsDialog(courseId: widget.course.id!),
      ),
    );

    if (!mounted) return;

    await context.read<CourseDetailsProvider>().loadStudents();
  }

  Future<void> _openLectureSessions() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LectureSessionsPage(
          courseId: widget.course.id!,
          courseName: widget.course.title,
          courseCode: widget.course.code,
        ),
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
    final r = AppResponsive.of(context);
    final provider = context.watch<CourseDetailsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Course Details', style: TextStyle(fontSize: r.titleLarge)),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(r.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CourseHeader(course: widget.course),

                SizedBox(height: r.spacingM),

                CourseStatistics(
                  totalStudents: provider.students.length,
                  totalAttendanceSessions: 0,
                  averageAttendance: 0,
                ),

                SizedBox(height: r.spacingM),

                CourseActionsBar(
                  onImportStudents: () =>
                      _showImportStudentsDialog(widget.course),
                  onAddStudent: _showAddStudentsDialog,
                  onLectureSessions: _openLectureSessions,
                  onRefresh: provider.loadStudents,
                ),

                SizedBox(height: r.spacingL),

                StudentSearchBar(
                  controller: _searchController,
                  onChanged: provider.search,
                ),

                SizedBox(height: r.spacingS),

                StudentFilters(
                  showActiveOnly: provider.showActiveOnly,
                  sortAscending: provider.sortAscending,
                  onShowActiveChanged: provider.setShowActiveOnly,
                  onSortChanged: provider.setSortAscending,
                ),

                SizedBox(height: r.spacingM),

                if (provider.isLoading)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(r.spacingL),
                      child: const CircularProgressIndicator(),
                    ),
                  )
                else
                  EnrolledStudentsTable(
                    students: provider.paginatedStudents,
                    onRemoveStudent: _removeStudent,
                    startIndex: (provider.currentPage - 1) * provider.pageSize,
                  ),

                SizedBox(height: r.spacingS),

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
      ),
    );
  }
}
