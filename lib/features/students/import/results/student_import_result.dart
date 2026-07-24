import 'package:attendance_management_system/features/students/models/student.dart';

class StudentImportResult {
  const StudentImportResult({
    required this.success,
    this.validStudents = const [],
    this.totalRows = 0,
    this.errors = const [],
    this.warnings = const [],
    this.error,
  });

  /// Whether reading/validation completed successfully.
  final bool success;

  /// Students that are eligible for import.
  /// (Warnings such as missing names are still included here.)
  final List<Student> validStudents;

  /// Total student rows found in the selected file
  /// (excluding the header row).
  final int totalRows;

  /// Rows that cannot be imported.
  final List<String> errors;

  /// Non-fatal issues.
  /// These rows can either:
  /// - still be imported (e.g. missing student name), or
  /// - be skipped (e.g. admission number already exists).
  final List<String> warnings;

  /// General file-level error.
  /// Example:
  /// - Unable to read file.
  /// - Missing Admission Number column.
  final String? error;

  bool get hasErrors => errors.isNotEmpty;

  bool get hasWarnings => warnings.isNotEmpty;

  int get validRows => validStudents.length;

  int get skippedRows => totalRows - validStudents.length;
}
