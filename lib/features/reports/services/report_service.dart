import 'package:attendance_management_system/data/database/database_service.dart';
import 'package:attendance_management_system/features/attendance/attendance/tables/attendance_record_table.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/tables/lecture_session_table.dart';
import 'package:attendance_management_system/features/courses/enrollments/tables/course_student_table.dart';
import 'package:attendance_management_system/features/courses/tables/course_table.dart';
import 'package:sqflite/sqflite.dart';

import '../models/attendance_report.dart';

class ReportService {
  ReportService._();

  static final ReportService instance = ReportService._();

  Future<AttendanceReport> generateCourseReport({
    required int courseId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await DatabaseService.instance.database;

    final courseRows = await db.query(
      CourseTable.tableName,
      columns: [CourseTable.id, CourseTable.code, CourseTable.title],
      where: '${CourseTable.id} = ?',
      whereArgs: [courseId],
      limit: 1,
    );

    if (courseRows.isEmpty) {
      throw Exception('Course not found.');
    }

    final course = courseRows.first;

    final sessions = await _getCourseSessions(
      db,
      courseId: courseId,
      startDate: startDate,
      endDate: endDate,
    );

    final totalStudents = await _getCourseStudentCount(db, courseId);

    final sessionReports = <LectureSessionReport>[];

    var totalPresent = 0;
    var totalAbsent = 0;

    for (final session in sessions) {
      final sessionId = session[LectureSessionTable.id] as int;

      final presentCount = await _getSessionPresentCount(
        db,
        lectureSessionId: sessionId,
      );

      final absentCount = _calculateAbsent(totalStudents, presentCount);

      final attendancePercentage = _calculatePercentage(
        presentCount,
        totalStudents,
      );

      totalPresent += presentCount;
      totalAbsent += absentCount;

      sessionReports.add(
        LectureSessionReport(
          lectureSessionId: sessionId,
          sessionNumber: session[LectureSessionTable.sessionNumber] as int,
          weekNumber: session[LectureSessionTable.weekNumber] as int,
          lectureDate: DateTime.parse(
            session[LectureSessionTable.lectureDate] as String,
          ),
          fromTime: session[LectureSessionTable.fromTime] as String,
          toTime: session[LectureSessionTable.toTime] as String,
          durationMinutes: session[LectureSessionTable.durationMinutes] as int,
          status: session[LectureSessionTable.status] as String,
          totalStudents: totalStudents,
          presentCount: presentCount,
          absentCount: absentCount,
          attendancePercentage: attendancePercentage,
        ),
      );
    }

    final totalPossible = totalStudents * sessions.length;

    final overallPercentage = totalPossible == 0
        ? 0.0
        : (totalPresent / totalPossible) * 100;

    final students = await _getStudentAttendanceReports(
      db,
      courseId: courseId,
      sessionIds: sessions
          .map((session) => session[LectureSessionTable.id] as int)
          .toList(),
    );

    return AttendanceReport(
      courseId: courseId,
      courseCode: course[CourseTable.code] as String,
      courseTitle: course[CourseTable.title] as String,
      totalStudents: totalStudents,
      totalSessions: sessions.length,
      totalPresent: totalPresent,
      totalAbsent: totalAbsent,
      attendancePercentage: overallPercentage,
      sessions: sessionReports,
      students: students,
    );
  }

  Future<List<Map<String, dynamic>>> _getCourseSessions(
    Database db, {
    required int courseId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final conditions = <String>['${LectureSessionTable.courseId} = ?'];

    final arguments = <Object?>[courseId];

    if (startDate != null) {
      conditions.add('${LectureSessionTable.lectureDate} >= ?');
      arguments.add(_dateOnly(startDate));
    }

    if (endDate != null) {
      conditions.add('${LectureSessionTable.lectureDate} <= ?');
      arguments.add(_dateOnly(endDate));
    }

    return db.query(
      LectureSessionTable.tableName,
      where: conditions.join(' AND '),
      whereArgs: arguments,
      orderBy:
          '${LectureSessionTable.lectureDate} ASC, '
          '${LectureSessionTable.sessionNumber} ASC',
    );
  }

  Future<int> _getCourseStudentCount(Database db, int courseId) async {
    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) AS total
      FROM ${CourseStudentTable.tableName}
      WHERE ${CourseStudentTable.courseId} = ?
      ''',
      [courseId],
    );

    return _toInt(result.first['total']);
  }

  Future<int> _getSessionPresentCount(
    Database db, {
    required int lectureSessionId,
  }) async {
    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) AS total
      FROM ${AttendanceRecordTable.tableName}
      WHERE ${AttendanceRecordTable.lectureSessionId} = ?
        AND ${AttendanceRecordTable.status} = ?
      ''',
      [lectureSessionId, 'present'],
    );

    return _toInt(result.first['total']);
  }

  Future<List<StudentAttendanceReport>> _getStudentAttendanceReports(
    Database db, {
    required int courseId,
    required List<int> sessionIds,
  }) async {
    if (sessionIds.isEmpty) {
      return [];
    }

    final placeholders = List.filled(sessionIds.length, '?').join(', ');

    final result = await db.rawQuery(
      '''
      SELECT
        s.id AS student_id,
        s.full_name AS full_name,
        s.admission_number AS admission_number,

        COUNT(
          DISTINCT CASE
            WHEN ar.status = 'present'
            THEN ar.lecture_session_id
          END
        ) AS attended

      FROM ${CourseStudentTable.tableName} cs

      INNER JOIN students s
        ON s.id = cs.${CourseStudentTable.studentId}

      LEFT JOIN ${AttendanceRecordTable.tableName} ar
        ON ar.${AttendanceRecordTable.studentId} = s.id
        AND ar.${AttendanceRecordTable.lectureSessionId}
            IN ($placeholders)

      WHERE cs.${CourseStudentTable.courseId} = ?

      GROUP BY
        s.id,
        s.full_name,
        s.admission_number

      ORDER BY s.full_name ASC
      ''',
      [...sessionIds, courseId],
    );

    return result.map((row) {
      final attended = _toInt(row['attended']);
      final totalSessions = sessionIds.length;

      final missed = (totalSessions - attended).clamp(0, totalSessions);

      return StudentAttendanceReport(
        studentId: row['student_id'] as int,
        fullName: row['full_name'] as String? ?? '',
        admissionNumber: row['admission_number'] as String? ?? '',
        totalSessions: totalSessions,
        sessionsAttended: attended,
        sessionsMissed: missed,
        attendancePercentage: _calculatePercentage(attended, totalSessions),
      );
    }).toList();
  }

  Future<List<AttendanceStudentRow>> getLectureSessionAttendance({
    required int lectureSessionId,
  }) async {
    final db = await DatabaseService.instance.database;

    final result = await db.rawQuery(
      '''
      SELECT
        s.id AS student_id,
        s.full_name AS full_name,
        s.admission_number AS admission_number,

        ar.${AttendanceRecordTable.status}
          AS attendance_status,

        ar.${AttendanceRecordTable.scannedAt}
          AS scanned_at

      FROM ${LectureSessionTable.tableName} ls

      INNER JOIN ${CourseStudentTable.tableName} cs
        ON cs.${CourseStudentTable.courseId}
           = ls.${LectureSessionTable.courseId}

      INNER JOIN students s
        ON s.id = cs.${CourseStudentTable.studentId}

      LEFT JOIN ${AttendanceRecordTable.tableName} ar
        ON ar.${AttendanceRecordTable.studentId} = s.id
        AND ar.${AttendanceRecordTable.lectureSessionId} = ls.id

      WHERE ls.${LectureSessionTable.id} = ?

      ORDER BY s.full_name ASC
      ''',
      [lectureSessionId],
    );

    return result.map((row) {
      final scannedAt = row['scanned_at'];

      return AttendanceStudentRow(
        studentId: row['student_id'] as int,
        fullName: row['full_name'] as String? ?? '',
        admissionNumber: row['admission_number'] as String? ?? '',
        present: row['attendance_status'] == 'present',
        scannedAt: scannedAt == null
            ? null
            : DateTime.tryParse(scannedAt as String),
      );
    }).toList();
  }

  int _calculateAbsent(int totalStudents, int present) {
    return (totalStudents - present).clamp(0, totalStudents);
  }

  double _calculatePercentage(int value, int total) {
    if (total <= 0) {
      return 0;
    }

    return (value / total) * 100;
  }

  int _toInt(Object? value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _dateOnly(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');

    final month = date.month.toString().padLeft(2, '0');

    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}
