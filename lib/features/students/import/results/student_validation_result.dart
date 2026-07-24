import 'package:attendance_management_system/features/students/models/student.dart';

class StudentValidationResult {
  const StudentValidationResult({
    required this.validStudents,
    this.errors = const [],
    this.warnings = const [],
  });

  final List<Student> validStudents;

  /// Fatal validation problems
  final List<String> errors;

  /// Non-fatal issues (duplicates already in database, etc.)
  final List<String> warnings;

  bool get isValid => validStudents.isNotEmpty;
}
