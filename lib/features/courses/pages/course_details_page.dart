import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:attendance_management_system/core/widgets/widgets.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/pages/lecture_sessions_page.dart';
import 'package:attendance_management_system/features/courses/enrollments/dialogs/add_course_students_dialog.dart';
import 'package:attendance_management_system/features/courses/enrollments/dialogs/import_course_students_dialog.dart';
import 'package:attendance_management_system/features/courses/enrollments/providers/add_course_students_provider.dart';
import 'package:attendance_management_system/features/courses/enrollments/providers/course_student_import_provider.dart';
import 'package:attendance_management_system/features/courses/models/course.dart';
import 'package:attendance_management_system/features/courses/providers/course_details_provider.dart';
import 'package:attendance_management_system/features/courses/widgets/course_details/course_details.dart';
import 'package:attendance_management_system/features/qr/dialogs/student_qr_dialog.dart';
import 'package:attendance_management_system/features/qr/dialogs/bulk_qr_export_dialog.dart';
import 'package:attendance_management_system/features/students/models/student.dart';
import 'package:attendance_management_system/features/students/providers/student_provider.dart';
import 'package:attendance_management_system/features/students/services/student_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CourseDetailsPage extends StatefulWidget {
  const CourseDetailsPage({
    super.key,
    required this.course,
  });

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

  void _showStudentQr(Student student) {
    showDialog(
      context: context,
      builder: (_) => StudentQrDialog(
        student: student,
      ),
    );
  }

  Future<void> _showBulkExportDialog() async {
    final provider = context.read<CourseDetailsProvider>();

    final students = provider.filteredStudents;

    if (students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No students available to export.'),
        ),
      );

      return;
    }

    await showDialog(
      context: context,
      builder: (_) => BulkQrExportDialog(
        students: students,
      ),
    );
  }

  Future<void> _showImportStudentsDialog(Course course) async {
    await showDialog(
      context: context,
      builder: (_) => ChangeNotifierProvider(
        create: (context) => CourseStudentImportProvider(
          context.read<StudentProvider>(),
        ),
        child: ImportCourseStudentsDialog(
          courseId: course.id!,
        ),
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
        child: AddCourseStudentsDialog(
          courseId: widget.course.id!,
        ),
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
        content: Text(
          'Remove ${student.fullName} from this course?',
        ),
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

  Future<void> _refresh() async {
    await context.read<CourseDetailsProvider>().loadStudents();
  }

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);
    final provider = context.watch<CourseDetailsProvider>();

    return Scaffold(
      appBar: AppBarWidget(
        title: 'Course Details',
      ),
      endDrawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(r.pagePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CourseHeader(
                    course: widget.course,
                  ),

                  SizedBox(height: r.spacingM),

                  CourseStatistics(
                    totalStudents: provider.students.length,
                    totalLectureSessions:
                        provider.lectureSessionsCount ?? 0,
                    averageAttendance:
                        provider.averageCourseAttendance ?? 0,
                  ),

                  SizedBox(height: r.spacingM),

                  CourseActionsBar(
                    onImportStudents: () =>
                        _showImportStudentsDialog(widget.course),
                    onAddStudent: _showAddStudentsDialog,
                    onLectureSessions: _openLectureSessions,
                    onRefresh: provider.loadStudents,
                    onExportBulkQr: _showBulkExportDialog,
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
                    onShowActiveChanged:
                        provider.setShowActiveOnly,
                    onSortChanged:
                        provider.setSortAscending,
                  ),

                  SizedBox(height: r.spacingM),

                  if (provider.isLoading)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(r.spacingL),
                        child: const CircularProgressIndicator(),
                      ),
                    )
                  else if (provider.filteredStudents.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 40,
                      ),
                      child: Center(
                        child: Text(
                          'No students found.',
                        ),
                      ),
                    )
                  else ...[
                    StudentPagination(
                      currentPage: provider.currentPage,
                      totalPages: provider.totalPages,
                      onPrevious: provider.currentPage > 1
                          ? provider.previousPage
                          : null,
                      onNext:
                          provider.currentPage < provider.totalPages
                              ? provider.nextPage
                              : null,
                    ),

                    SizedBox(height: r.spacingS),

                    EnrolledStudentsTable(
                      students: provider.paginatedStudents,
                      onRemove: _removeStudent,
                      onViewQr: _showStudentQr,
                      startingIndex:
                          (provider.currentPage - 1) *
                              provider.pageSize,
                    ),

                    SizedBox(height: r.spacingS),

                    StudentPagination(
                      currentPage: provider.currentPage,
                      totalPages: provider.totalPages,
                      onPrevious: provider.currentPage > 1
                          ? provider.previousPage
                          : null,
                      onNext:
                          provider.currentPage < provider.totalPages
                              ? provider.nextPage
                              : null,
                    ),
                  ],

                  if (provider.error != null) ...[
                    SizedBox(height: r.spacingM),

                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(r.spacingM),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Theme.of(context)
                                  .colorScheme
                                  .error,
                            ),
                            SizedBox(width: r.spacingS),
                            Expanded(
                              child: Text(
                                provider.error!,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

