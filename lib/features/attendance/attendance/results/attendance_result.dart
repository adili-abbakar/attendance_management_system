import 'package:attendance_management_system/features/attendance/attendance/models/attendance_record.dart';
import 'package:attendance_management_system/features/students/models/student.dart';

enum AttendanceResultStatus {
  success,
  studentNotFound,
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

  bool get isSuccess => status == AttendanceResultStatus.success;

  bool get isAlreadyAttended =>
      status == AttendanceResultStatus.alreadyAttended;

  bool get isStudentNotFound =>
      status == AttendanceResultStatus.studentNotFound;

  bool get isLectureSessionNotActive =>
      status == AttendanceResultStatus.lectureSessionNotActive;

  bool get isError => status == AttendanceResultStatus.error;

  const AttendanceResult.success({
    required AttendanceRecord record,
    Student? student,
  }) : this(
         status: AttendanceResultStatus.success,
         record: record,
         student: student,
       );

  const AttendanceResult.failure({
    required AttendanceResultStatus status,
    String? message,
    Student? student,
  }) : this(status: status, message: message, student: student);
}
