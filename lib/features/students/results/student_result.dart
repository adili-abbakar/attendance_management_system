import 'package:attendance_management_system/features/students/models/student.dart';

class StudentResult {
  const StudentResult({
    required this.success,
    this.student,
    this.admissionNumberError,
  });

  final bool success;


  final Student? student;

  final String? admissionNumberError;
}
