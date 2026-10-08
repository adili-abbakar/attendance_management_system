import 'dart:typed_data';

import 'package:attendance_management_system/core/widgets/app_bar_widget.dart';
import 'package:attendance_management_system/core/widgets/app_drawer.dart';
import 'package:attendance_management_system/features/attendance/attendance/dialogs/select_course_dialog.dart';
import 'package:attendance_management_system/features/courses/models/course.dart';
import 'package:attendance_management_system/features/courses/providers/course_provider.dart';
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
import 'package:file_selector/file_selector.dart';
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
        _generateReport();
      });
    }
  }

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

  Future<void> _showExportOptions(AttendanceReport report) async {
    if (_isExporting || !_hasReport(report)) {
      return;
    }

    final format = await showDialog<ReportExportFormat>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Export Attendance Report'),
          content: const Text('Choose the format you want to save.'),
          actions: [
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pop(ReportExportFormat.pdf);
              },
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: const Text('PDF'),
            ),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pop(ReportExportFormat.excel);
              },
              icon: const Icon(Icons.table_chart_outlined),
              label: const Text('Excel'),
            ),
          ],
        );
      },
    );

    if (!mounted || format == null) {
      return;
    }

    await _saveReport(report: report, format: format);
  }

  Future<void> _saveReport({
    required AttendanceReport report,
    required ReportExportFormat format,
  }) async {
    if (_isExporting) {
      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      final exporter = ReportExporter.instance;

      final Uint8List bytes = await exporter.export(report, format);

      if (!mounted) {
        return;
      }

      final fileName = _buildFileName(report, format);

      final location = await getSaveLocation(
        suggestedName: fileName,
        acceptedTypeGroups: [
          XTypeGroup(
            label: _formatName(format),
            extensions: [_fileExtension(format)],
            mimeTypes: [_mimeType(format)],
          ),
        ],
      );

      if (!mounted || location == null) {
        return;
      }

      final file = XFile.fromData(
        bytes,
        name: fileName,
        mimeType: _mimeType(format),
      );

      await file.saveTo(location.path);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_formatName(format)} report saved successfully.'),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save report: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  String _buildFileName(AttendanceReport report, ReportExportFormat format) {
    final courseCode = _sanitizeFileName(report.courseCode ?? 'COURSE');

    final sessionCount = report.totalSessions;

    return '${courseCode}_${sessionCount}_Sessions_'
        'Attendance_Report.${_fileExtension(format)}';
  }

  String _sanitizeFileName(String value) {
    final sanitized = value
        .trim()
        .replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '_')
        .replaceAll(RegExp(r'\s+'), '_');

    return sanitized.isEmpty ? 'COURSE' : sanitized;
  }

  String _fileExtension(ReportExportFormat format) {
    switch (format) {
      case ReportExportFormat.pdf:
        return 'pdf';

      case ReportExportFormat.excel:
        return 'xlsx';
    }
  }

  String _mimeType(ReportExportFormat format) {
    switch (format) {
      case ReportExportFormat.pdf:
        return 'application/pdf';

      case ReportExportFormat.excel:
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    }
  }

  String _formatName(ReportExportFormat format) {
    switch (format) {
      case ReportExportFormat.pdf:
        return 'PDF';

      case ReportExportFormat.excel:
        return 'Excel';
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
          final hasReport = _hasReport(report);

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

                if (!hasReport)
                  const EmptyReportView()
                else ...[
                  _buildReportActions(report),

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

  Widget _buildReportActions(AttendanceReport report) {
    return Align(
      alignment: Alignment.centerRight,
      child: OutlinedButton.icon(
        onPressed: _isExporting ? null : () => _showExportOptions(report),
        icon: _isExporting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.file_download_outlined),
        label: Text(_isExporting ? 'Preparing...' : 'Export Report'),
      ),
    );
  }

  bool _hasReport(AttendanceReport report) {
    return report.courseId != null ||
        report.totalStudents > 0 ||
        report.totalSessions > 0;
  }
}
