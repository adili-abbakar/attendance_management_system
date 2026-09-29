import 'package:attendance_management_system/features/attendance/lecture_session/models/lecture_session.dart';

class AttendanceVerificationSession {
  const AttendanceVerificationSession({
    required this.lectureSession,
    required this.isPresent,
    this.scannedAt,
  });

  final LectureSession lectureSession;
  final bool isPresent;
  final DateTime? scannedAt;
}