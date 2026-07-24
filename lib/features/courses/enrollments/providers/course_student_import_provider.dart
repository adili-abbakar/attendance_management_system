import 'package:attendance_management_system/features/courses/enrollments/results/course_student_import_summary.dart';
import 'package:attendance_management_system/features/courses/enrollments/services/course_student_import_service.dart';
import 'package:attendance_management_system/features/students/import/results/student_import_result.dart';
import 'package:attendance_management_system/features/students/models/student.dart';
import 'package:attendance_management_system/features/students/providers/student_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class CourseStudentImportProvider extends ChangeNotifier {
  CourseStudentImportProvider(this._studentProvider);

  final StudentProvider _studentProvider;

  bool _isImporting = false;
  StudentImportResult? _preview;
  CourseStudentImportSummary? _summary;
  List<Student> _studentsToImport = [];
  bool get isImporting => _isImporting;
  StudentImportResult? get preview => _preview;
  CourseStudentImportSummary? get summary => _summary;
  String? get generalError => _summary?.generalError ?? _preview?.error;
  bool get hasPreview => _preview != null;

  void clear() {
    _isImporting = false;
    _preview = null;
    _summary = null;
    _studentsToImport = [];

    notifyListeners();
  }

  Future<StudentImportResult> validateImport(
    PlatformFile file,
    int courseId,
  ) async {
    _isImporting = true;
    _preview = null;
    _summary = null;
    _studentsToImport = [];

    notifyListeners();

    try {
      final readResult = await CourseStudentImportService.instance.readStudents(
        file,
      );

      if (!readResult.success) {
        _preview = StudentImportResult(success: false, error: readResult.error);

        return _preview!;
      }

      final validation = await CourseStudentImportService.instance
          .validateImport(readResult.validStudents, courseId);

      _preview = validation;
      _studentsToImport = validation.validStudents;

      return validation;
    } finally {
      _isImporting = false;
      notifyListeners();
    }
  }

  Future<CourseStudentImportSummary> confirmImport(int courseId) async {
    _isImporting = true;

    notifyListeners();

    try {
      final summary = await CourseStudentImportService.instance.importStudents(
        _studentsToImport,
        courseId,
      );

      await _studentProvider.loadStudents();

      _summary = summary;

      return summary;
    } catch (_) {
      _summary = const CourseStudentImportSummary(
        createdStudents: 0,
        linkedExistingStudents: 0,
        alreadyEnrolled: 0,
        invalidRows: 0,
        generalError: 'An unexpected error occurred while importing students.',
      );

      return _summary!;
    } finally {
      _isImporting = false;
      notifyListeners();
    }
  }
}
