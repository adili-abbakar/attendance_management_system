import 'package:attendance_management_system/features/students/import/results/student_import_result.dart';
import 'package:attendance_management_system/features/students/import/results/student_import_summary.dart';
import 'package:attendance_management_system/features/students/import/services/student_import_service.dart';
import 'package:attendance_management_system/features/students/models/student.dart';
import 'package:attendance_management_system/features/students/providers/student_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class StudentImportProvider extends ChangeNotifier {
  StudentImportProvider(this._studentProvider);

  final StudentProvider _studentProvider;

  bool _isImporting = false;

  StudentImportResult? _preview;
  StudentImportSummary? _summary;

  List<Student> _studentsToImport = [];

  bool get isImporting => _isImporting;

  StudentImportResult? get preview => _preview;

  StudentImportSummary? get summary => _summary;
  String? get generalError => _summary?.generalError ?? _preview?.error;
  bool get hasPreview => _preview != null;

  void clear() {
    _isImporting = false;
    _preview = null;
    _summary = null;
    _studentsToImport = [];

    notifyListeners();
  }

  Future<StudentImportResult> validateImport(PlatformFile file) async {
    _isImporting = true;
    _preview = null;
    _summary = null;
    _studentsToImport = [];

    notifyListeners();

    try {
      final readResult = await StudentImportService.instance.readStudents(file);

      if (!readResult.success) {
        _preview = StudentImportResult(success: false, error: readResult.error);

        return _preview!;
      }

      final validation = await StudentImportService.instance.validateImport(
        readResult.validStudents,
      );

      _preview = validation;
      _studentsToImport = validation.validStudents;

      return validation;
    } finally {
      _isImporting = false;
      notifyListeners();
    }
  }

  Future<StudentImportSummary> confirmImport() async {
    _isImporting = true;

    notifyListeners();

    try {
      final importedCount = await StudentImportService.instance.importStudents(
        _studentsToImport,
      );

      await _studentProvider.loadStudents();

      _summary = StudentImportSummary(
        importedCount: importedCount,
        skippedCount: _preview?.skippedRows ?? 0,
        warnings: _preview?.warnings ?? [],
        errors: _preview?.errors ?? [],
      );

      return _summary!;
    } catch (_) {
      _summary = const StudentImportSummary(
        importedCount: 0,
        skippedCount: 0,
        generalError: 'An unexpected error occurred while importing students.',
      );

      return _summary!;
    } finally {
      _isImporting = false;
      notifyListeners();
    }
  }
}
