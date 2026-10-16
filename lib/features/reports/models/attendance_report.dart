import 'package:flutter/foundation.dart';

@immutable
class AttendanceReport {
  final int? courseId;
  final String? courseCode;
  final String? courseTitle;
  final String? levelName;
  final String? academicSessionName;
  final int? semester;

  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime generatedAt;

  final int totalStudents;
  final int totalSessions;
  final double attendancePercentage;

  final List<LectureSessionReport> sessions;
  final List<StudentAttendanceReport> students;

  const AttendanceReport({
    this.courseId,
    this.courseCode,
    this.courseTitle,
    this.levelName,
    this.academicSessionName,
    this.semester,
    this.startDate,
    this.endDate,
    required this.generatedAt,
    required this.totalStudents,
    required this.totalSessions,
    required this.attendancePercentage,
    this.sessions = const [],
    this.students = const [],
  });

  factory AttendanceReport.empty() {
    return AttendanceReport(
      generatedAt: DateTime.now(),
      totalStudents: 0,
      totalSessions: 0,
      attendancePercentage: 0,
    );
  }

  AttendanceReport copyWith({
    int? courseId,
    String? courseCode,
    String? courseTitle,
    String? levelName,
    String? academicSessionName,
    int? semester,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? generatedAt,
    int? totalStudents,
    int? totalSessions,
    double? attendancePercentage,
    List<LectureSessionReport>? sessions,
    List<StudentAttendanceReport>? students,
  }) {
    return AttendanceReport(
      courseId: courseId ?? this.courseId,
      courseCode: courseCode ?? this.courseCode,
      courseTitle: courseTitle ?? this.courseTitle,
      levelName: levelName ?? this.levelName,
      academicSessionName: academicSessionName ?? this.academicSessionName,
      semester: semester ?? this.semester,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      generatedAt: generatedAt ?? this.generatedAt,
      totalStudents: totalStudents ?? this.totalStudents,
      totalSessions: totalSessions ?? this.totalSessions,
      attendancePercentage: attendancePercentage ?? this.attendancePercentage,
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

  final List<StudentSessionAttendance> sessionAttendance;

  const StudentAttendanceReport({
    required this.studentId,
    required this.fullName,
    required this.admissionNumber,
    required this.totalSessions,
    required this.sessionsAttended,
    required this.sessionsMissed,
    required this.attendancePercentage,
    this.sessionAttendance = const [],
  });
}

@immutable
class StudentSessionAttendance {
  final int lectureSessionId;
  final int sessionNumber;
  final bool present;
  final DateTime? scannedAt;

  const StudentSessionAttendance({
    required this.lectureSessionId,
    required this.sessionNumber,
    required this.present,
    this.scannedAt,
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
