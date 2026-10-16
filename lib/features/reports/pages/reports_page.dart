import 'package:attendance_management_system/core/widgets/app_bar_widget.dart';
import 'package:attendance_management_system/core/widgets/app_drawer.dart';
import 'package:attendance_management_system/features/attendance/attendance/dialogs/select_course_dialog.dart';
import 'package:attendance_management_system/features/courses/models/course.dart';
import 'package:attendance_management_system/features/courses/providers/course_provider.dart';
import 'package:attendance_management_system/features/reports/helpers/report_helper.dart';
import 'package:attendance_management_system/features/reports/models/attendance_report.dart';
import 'package:attendance_management_system/features/reports/providers/report_provider.dart';
import 'package:attendance_management_system/features/reports/services/report_exporter.dart';
import 'package:attendance_management_system/features/reports/widgets/empty_report_view.dart';
import 'package:attendance_management_system/features/reports/widgets/report_course_header.dart';
import 'package:attendance_management_system/features/reports/widgets/report_error_view.dart';
import 'package:attendance_management_system/features/reports/widgets/report_filter_bar.dart';
import 'package:attendance_management_system/features/reports/widgets/report_session_section.dart';
import 'package:attendance_management_system/features/reports/widgets/report_student_section.dart';
import 'package:attendance_management_system/features/reports/widgets/report_summary.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReportsPage extends StatefulWidget {
  final Course? course;

  const ReportsPage({super.key, this.course});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  Course? _selectedCourse;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _selectedCourse = widget.course;

    if (_selectedCourse != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _generateReport();
        }
      });
    }
  }

  Future<void> _selectCourse() async {
    final courses = context.read<CourseProvider>().courses;

    final course = await showDialog<Course?>(
      context: context,
      builder: (_) => SelectCourseDialog(courses: courses),
    );

    if (!mounted || course == null) return;

    setState(() => _selectedCourse = course);
  }

  Future<void> _generateReport() async {
    final courseId = _selectedCourse?.id;

    if (courseId == null || courseId <= 0) return;

    await context.read<ReportProvider>().generateCourseReport(
      courseId: courseId,
    );
  }

  Future<void> _exportExcel(AttendanceReport report) async {
    if (_isExporting || !ReportHelper.hasReport(report)) return;

    setState(() => _isExporting = true);

    try {
      final bytes = await ReportExporter.instance.exportExcel(report);

      if (!mounted) return;

      final fileName = ReportHelper.buildFileName(report);

      final savedFile = await FilePicker.saveFile(
        dialogTitle: 'Save Attendance Report',
        fileName: fileName,
        bytes: bytes,
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (!mounted) return;

      if (savedFile == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Export cancelled.')));
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Excel report saved successfully.')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save Excel report: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
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
                if (!ReportHelper.hasReport(report))
                  const EmptyReportView()
                else ...[
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: _isExporting
                          ? null
                          : () => _exportExcel(report),
                      icon: _isExporting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.table_chart_outlined),
                      label: Text(
                        _isExporting ? 'Exporting...' : 'Export Excel',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
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
}
