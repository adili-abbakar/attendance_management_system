import 'package:attendance_management_system/features/attendance/attendance/models/models.dart';
import 'package:attendance_management_system/features/courses/models/course.dart';
import 'package:attendance_management_system/features/students/models/student.dart';

class AttendanceVerification {
  const AttendanceVerification({
    required this.student,
    required this.course,
    required this.sessions,
  });

  final Student student;
  final Course course;
  final List<AttendanceVerificationSession> sessions;

  int get totalSessions => sessions.length;

  int get attendedSessions =>
      sessions.where((session) => session.isPresent).length;

  double get attendancePercentage {
    if (totalSessions == 0) {
      return 0;
    }

    return (attendedSessions / totalSessions) * 100;
  }
}
