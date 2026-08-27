import 'package:attendance_management_system/features/attendance/attendance/models/attendance_record.dart';
import 'package:attendance_management_system/features/students/models/student.dart';

enum AttendanceResultStatus {
  success,

  studentNotFound,

  studentNotEnrolled,

  alreadyAttended,

  lectureSessionNotActive,

  invalidAdmissionNumber,

  error,
}

class AttendanceResult {
  final AttendanceResultStatus status;

  final AttendanceRecord? record;

  final Student? student;

  final String? message;

  const AttendanceResult({
    required this.status,
    this.record,
    this.student,
    this.message,
  });

  // ------------------------------------------------------------
  // Status getters
  // ------------------------------------------------------------

  bool get isSuccess => status == AttendanceResultStatus.success;

  bool get isStudentNotFound =>
      status == AttendanceResultStatus.studentNotFound;

  bool get isStudentNotEnrolled =>
      status == AttendanceResultStatus.studentNotEnrolled;

  bool get isAlreadyAttended =>
      status == AttendanceResultStatus.alreadyAttended;

  bool get isLectureSessionNotActive =>
      status == AttendanceResultStatus.lectureSessionNotActive;

  bool get isInvalidAdmissionNumber =>
      status == AttendanceResultStatus.invalidAdmissionNumber;

  bool get isError => status == AttendanceResultStatus.error;

  // ------------------------------------------------------------
  // Success result
  // ------------------------------------------------------------

  const AttendanceResult.success({
    required AttendanceRecord record,
    Student? student,
  }) : this(
         status: AttendanceResultStatus.success,
         record: record,
         student: student,
       );

  // ------------------------------------------------------------
  // Failure result
  // ------------------------------------------------------------

  const AttendanceResult.failure({
    required AttendanceResultStatus status,
    String? message,
    Student? student,
  }) : this(status: status, message: message, student: student);
}
