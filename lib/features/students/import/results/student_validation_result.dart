import 'package:attendance_management_system/features/students/models/student.dart';

class StudentValidationResult {
  const StudentValidationResult({
    required this.validStudents,
    this.errors = const [],
    this.warnings = const [],
  });

  final List<Student> validStudents;
  final List<String> errors;
  final List<String> warnings;
  bool get isValid => validStudents.isNotEmpty;
}
