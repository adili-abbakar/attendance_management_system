import 'package:flutter/foundation.dart';

@immutable
class AttendanceReport {
  final int? courseId;
  final String? courseCode;
  final String? courseTitle;

  final int totalStudents;
  final int totalSessions;
  final int totalPresent;
  final int totalAbsent;
  final double attendancePercentage;

  final List<LectureSessionReport> sessions;
  final List<StudentAttendanceReport> students;

  const AttendanceReport({
    this.courseId,
    this.courseCode,
    this.courseTitle,
    required this.totalStudents,
    required this.totalSessions,
    required this.totalPresent,
    required this.totalAbsent,
    required this.attendancePercentage,
    this.sessions = const [],
    this.students = const [],
  });

  factory AttendanceReport.empty() {
    return const AttendanceReport(
      totalStudents: 0,
      totalSessions: 0,
      totalPresent: 0,
      totalAbsent: 0,
      attendancePercentage: 0,
    );
  }

  AttendanceReport copyWith({
    int? courseId,
    String? courseCode,
    String? courseTitle,
    int? totalStudents,
    int? totalSessions,
    int? totalPresent,
    int? totalAbsent,
    double? attendancePercentage,
    List<LectureSessionReport>? sessions,
    List<StudentAttendanceReport>? students,
  }) {
    return AttendanceReport(
      courseId: courseId ?? this.courseId,
      courseCode: courseCode ?? this.courseCode,
      courseTitle: courseTitle ?? this.courseTitle,
      totalStudents: totalStudents ?? this.totalStudents,
      totalSessions: totalSessions ?? this.totalSessions,
      totalPresent: totalPresent ?? this.totalPresent,
      totalAbsent: totalAbsent ?? this.totalAbsent,
      attendancePercentage:
          attendancePercentage ?? this.attendancePercentage,
      sessions: sessions ?? this.sessions,
      students: students ?? this.students,
    );
  }
}

@immutable
class LectureSessionReport {
  final int lectureSessionId;
  final int sessionNumber;
  final int weekNumber;
  final DateTime lectureDate;
  final String fromTime;
  final String toTime;
  final int durationMinutes;
  final String status;
  final int totalStudents;
  final int presentCount;
  final int absentCount;
  final double attendancePercentage;

  const LectureSessionReport({
    required this.lectureSessionId,
    required this.sessionNumber,
    required this.weekNumber,
    required this.lectureDate,
    required this.fromTime,
    required this.toTime,
    required this.durationMinutes,
    required this.status,
    required this.totalStudents,
    required this.presentCount,
    required this.absentCount,
    required this.attendancePercentage,
  });
}

@immutable
class StudentAttendanceReport {
  final int studentId;
  final String fullName;
  final String admissionNumber;
  final int totalSessions;
  final int sessionsAttended;
  final int sessionsMissed;
  final double attendancePercentage;

  const StudentAttendanceReport({
    required this.studentId,
    required this.fullName,
    required this.admissionNumber,
    required this.totalSessions,
    required this.sessionsAttended,
    required this.sessionsMissed,
    required this.attendancePercentage,
  });
}

@immutable
class AttendanceStudentRow {
  final int studentId;
  final String fullName;
  final String admissionNumber;
  final bool present;
  final DateTime? scannedAt;

  const AttendanceStudentRow({
    required this.studentId,
    required this.fullName,
    required this.admissionNumber,
    required this.present,
    this.scannedAt,
  });
}