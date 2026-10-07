import 'package:attendance_management_system/core/widgets/app_bar_widget.dart';
import 'package:attendance_management_system/core/widgets/app_drawer.dart';
import 'package:attendance_management_system/features/attendance/attendance/dialogs/select_course_dialog.dart';
import 'package:attendance_management_system/features/courses/models/course.dart';
import 'package:attendance_management_system/features/courses/providers/course_provider.dart';
import 'package:attendance_management_system/features/reports/models/attendance_report.dart';
import 'package:attendance_management_system/features/reports/providers/report_provider.dart';
import 'package:attendance_management_system/features/reports/widgets/empty_report_view.dart';
import 'package:attendance_management_system/features/reports/widgets/report_course_header.dart';
import 'package:attendance_management_system/features/reports/widgets/report_error_view.dart';
import 'package:attendance_management_system/features/reports/widgets/report_filter_bar.dart';
import 'package:attendance_management_system/features/reports/widgets/report_session_section.dart';
import 'package:attendance_management_system/features/reports/widgets/report_student_section.dart';
import 'package:attendance_management_system/features/reports/widgets/report_summary.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  Course? _selectedCourse;

  Future<void> _selectCourse() async {
    final courses = context.read<CourseProvider>().courses;

    final course = await showDialog<Course?>(
      context: context,
      builder: (_) => SelectCourseDialog(courses: courses),
    );

    if (!mounted || course == null) {
      return;
    }

    setState(() {
      _selectedCourse = course;
    });
  }

  Future<void> _generateReport() async {
    final course = _selectedCourse;

    if (course == null || course.id == null || course.id! <= 0) {
      return;
    }

    await context.read<ReportProvider>().generateCourseReport(
      courseId: course.id!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: 'Reports'),
      endDrawer: const AppDrawer(),
      body: Consumer<ReportProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return ReportErrorView(
              message: provider.errorMessage!,
              onRetry: _generateReport,
            );
          }

          final report = provider.report;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ReportFilterBar(
                  selectedCourse: _selectedCourse,
                  onSelectCourse: _selectCourse,
                  onGenerate: _generateReport,
                ),

                const SizedBox(height: 24),

                if (!_hasReport(report))
                  const EmptyReportView()
                else ...[
                  ReportCourseHeader(report: report),

                  const SizedBox(height: 24),

                  ReportSummary(report: report),

                  const SizedBox(height: 24),

                  ReportSessionSection(sessions: report.sessions),

                  const SizedBox(height: 24),

                  ReportStudentSection(students: report.students),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  bool _hasReport(AttendanceReport report) {
    return report.courseId != null ||
        report.totalStudents > 0 ||
        report.totalSessions > 0;
  }
}
