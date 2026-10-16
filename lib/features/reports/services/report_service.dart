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
      columns: [
        CourseTable.id,
        CourseTable.code,
        CourseTable.title,
        CourseTable.levelId,
        CourseTable.academicSessionId,
        CourseTable.semester,
      ],
      where: '${CourseTable.id} = ?',
      whereArgs: [courseId],
      limit: 1,
    );

    if (courseRows.isEmpty) {
      throw Exception('Course not found.');
    }

    final course = courseRows.first;

    final courseDetails = await _getCourseDetails(db, course: course);

    final sessions = await _getCourseSessions(
      db,
      courseId: courseId,
      startDate: startDate,
      endDate: endDate,
    );

    final totalStudents = await _getCourseStudentCount(db, courseId);

    final sessionReports = <LectureSessionReport>[];

    var totalPresent = 0;

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
      levelName: courseDetails.levelName,
      academicSessionName: courseDetails.academicSessionName,
      semester: course[CourseTable.semester] as int,
      startDate: startDate,
      endDate: endDate,
      generatedAt: DateTime.now(),
      totalStudents: totalStudents,
      totalSessions: sessions.length,
      attendancePercentage: overallPercentage,
      sessions: sessionReports,
      students: students,
    );
  }

  Future<_CourseDetails> _getCourseDetails(
    Database db, {
    required Map<String, dynamic> course,
  }) async {
    final levelId = course[CourseTable.levelId] as int;
    final academicSessionId = course[CourseTable.academicSessionId] as int;

    String? levelName;
    String? academicSessionName;

    final levelRows = await db.rawQuery(
      '''
      SELECT name
      FROM levels
      WHERE id = ?
      LIMIT 1
      ''',
      [levelId],
    );

    if (levelRows.isNotEmpty) {
      levelName = levelRows.first['name'] as String?;
    }

    final sessionRows = await db.rawQuery(
      '''
      SELECT name
      FROM academic_sessions
      WHERE id = ?
      LIMIT 1
      ''',
      [academicSessionId],
    );

    if (sessionRows.isNotEmpty) {
      academicSessionName = sessionRows.first['name'] as String?;
    }

    return _CourseDetails(
      levelName: levelName,
      academicSessionName: academicSessionName,
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

        ls.id AS lecture_session_id,
        ls.session_number AS session_number,

        ar.${AttendanceRecordTable.status}
            AS attendance_status,

        ar.${AttendanceRecordTable.scannedAt}
            AS scanned_at

      FROM ${CourseStudentTable.tableName} cs

      INNER JOIN students s
        ON s.id = cs.${CourseStudentTable.studentId}

      CROSS JOIN ${LectureSessionTable.tableName} ls

      LEFT JOIN ${AttendanceRecordTable.tableName} ar
        ON ar.${AttendanceRecordTable.studentId} = s.id
        AND ar.${AttendanceRecordTable.lectureSessionId} = ls.id

      WHERE cs.${CourseStudentTable.courseId} = ?
        AND ls.${LectureSessionTable.courseId} = ?
        AND ls.${LectureSessionTable.id}
            IN ($placeholders)

      ORDER BY
        s.full_name ASC,
        ls.${LectureSessionTable.lectureDate} ASC,
        ls.${LectureSessionTable.sessionNumber} ASC
      ''',
      [courseId, courseId, ...sessionIds],
    );

    final students = <int, _StudentReportBuilder>{};

    for (final row in result) {
      final studentId = row['student_id'] as int;

      final builder = students.putIfAbsent(
        studentId,
        () => _StudentReportBuilder(
          studentId: studentId,
          fullName: row['full_name'] as String? ?? '',
          admissionNumber: row['admission_number'] as String? ?? '',
        ),
      );

      final scannedAt = row['scanned_at'];

      builder.sessionAttendance.add(
        StudentSessionAttendance(
          lectureSessionId: row['lecture_session_id'] as int,
          sessionNumber: row['session_number'] as int,
          present: row['attendance_status'] == 'present',
          scannedAt: scannedAt == null
              ? null
              : DateTime.tryParse(scannedAt as String),
        ),
      );
    }

    final totalSessions = sessionIds.length;

    return students.values.map((builder) {
      final attended = builder.sessionAttendance
          .where((attendance) => attendance.present)
          .length;

      final missed = (totalSessions - attended).clamp(0, totalSessions);

      return StudentAttendanceReport(
        studentId: builder.studentId,
        fullName: builder.fullName,
        admissionNumber: builder.admissionNumber,
        totalSessions: totalSessions,
        sessionsAttended: attended,
        sessionsMissed: missed,
        attendancePercentage: _calculatePercentage(attended, totalSessions),
        sessionAttendance: List.unmodifiable(builder.sessionAttendance),
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

class _CourseDetails {
  final String? levelName;
  final String? academicSessionName;

  const _CourseDetails({
    required this.levelName,
    required this.academicSessionName,
  });
}

class _StudentReportBuilder {
  final int studentId;
  final String fullName;
  final String admissionNumber;

  final List<StudentSessionAttendance> sessionAttendance = [];

  _StudentReportBuilder({
    required this.studentId,
    required this.fullName,
    required this.admissionNumber,
  });
}
