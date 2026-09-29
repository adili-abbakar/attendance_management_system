import 'package:attendance_management_system/features/attendance/attendance/models/attendance_verification.dart';
import 'package:attendance_management_system/features/students/models/student.dart';

enum AttendanceVerificationResultStatus {
  success,
  studentNotFound,
  studentNotEnrolled,
  invalidStudent,
  error,
}

class AttendanceVerificationResult {
  const AttendanceVerificationResult({
    required this.status,
    this.verification,
    this.student,
    this.message,
  });

  final AttendanceVerificationResultStatus status;
  final AttendanceVerification? verification;
  final Student? student;
  final String? message;

  bool get isSuccess => status == AttendanceVerificationResultStatus.success;

  bool get isStudentNotFound =>
      status == AttendanceVerificationResultStatus.studentNotFound;

  bool get isStudentNotEnrolled =>
      status == AttendanceVerificationResultStatus.studentNotEnrolled;

  bool get isInvalidStudent =>
      status == AttendanceVerificationResultStatus.invalidStudent;

  bool get isError => status == AttendanceVerificationResultStatus.error;
}
