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

  final bool success;
  final List<Student> validStudents;
  final int totalRows;
  final List<String> errors;
  final List<String> warnings;
  final String? error;

  bool get hasErrors => errors.isNotEmpty;
  bool get hasWarnings => warnings.isNotEmpty;
  int get validRows => validStudents.length;
  int get skippedRows => totalRows - validStudents.length;
}
