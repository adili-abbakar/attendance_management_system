import 'package:attendance_management_system/data/database/database_service.dart';
import 'package:attendance_management_system/features/attendance/attendance/tables/attendance_record_table.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/models/models.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/tables/lecture_session_table.dart';
import 'package:attendance_management_system/features/courses/enrollments/tables/course_student_table.dart';
import 'package:attendance_management_system/features/courses/models/course.dart';
import 'package:attendance_management_system/features/courses/tables/course_table.dart';

class LectureSessionService {
  LectureSessionService._();

  static final LectureSessionService instance = LectureSessionService._();

  final DatabaseService _databaseService = DatabaseService.instance;

  Future<List<LectureSession>> getLectureSessions() async {
    final db = await _databaseService.database;

    final result = await db.query(
      LectureSessionTable.tableName,
      orderBy: '${LectureSessionTable.lectureDate} DESC',
    );

    return result.map(LectureSession.fromMap).toList();
  }

  Future<List<LectureSession>> getLectureSessionsByCourse(int courseId) async {
    final db = await _databaseService.database;

    final maps = await db.query(
      LectureSessionTable.tableName,
      where: '${LectureSessionTable.courseId} = ?',
      whereArgs: [courseId],
      orderBy:
          '${LectureSessionTable.lectureDate} DESC, '
          '${LectureSessionTable.sessionNumber} DESC',
    );

    return maps.map(LectureSession.fromMap).toList();
  }

  Future<LectureSession?> getLectureSessionById(int lectureSessionId) async {
    final db = await _databaseService.database;

    final maps = await db.query(
      LectureSessionTable.tableName,
      where: '${LectureSessionTable.id} = ?',
      whereArgs: [lectureSessionId],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return LectureSession.fromMap(maps.first);
  }

  Future<int> getNextLectureSessionNumber(int courseId) async {
    final db = await _databaseService.database;

    final result = await db.rawQuery(
      '''
      SELECT MAX(${LectureSessionTable.sessionNumber}) AS max_number
      FROM ${LectureSessionTable.tableName}
      WHERE ${LectureSessionTable.courseId} = ?
      ''',
      [courseId],
    );

    final maxNumber = result.first['max_number'] as int?;

    return (maxNumber ?? 0) + 1;
  }

  Future<int> createLectureSession(LectureSession lectureSession) async {
    final db = await _databaseService.database;

    final sessionNumber = await getNextLectureSessionNumber(
      lectureSession.courseId,
    );

    final now = DateTime.now();

    final lectureSessionToCreate = lectureSession.copyWith(
      sessionNumber: sessionNumber,
      createdAt: now,
      updatedAt: now,
    );

    final data = lectureSessionToCreate.toMap()..remove(LectureSessionTable.id);

    return db.insert(LectureSessionTable.tableName, data);
  }

  Future<int> updateLectureSession(LectureSession lectureSession) async {
    if (lectureSession.id == null) {
      throw ArgumentError('Cannot update a lecture session without an ID.');
    }

    final db = await _databaseService.database;

    final updatedLectureSession = lectureSession.copyWith(
      updatedAt: DateTime.now(),
    );

    final data = updatedLectureSession.toMap()..remove(LectureSessionTable.id);

    return db.update(
      LectureSessionTable.tableName,
      data,
      where: '${LectureSessionTable.id} = ?',
      whereArgs: [lectureSession.id],
    );
  }

  Future<int> deleteLectureSession(int lectureSessionId) async {
    final db = await _databaseService.database;

    return db.delete(
      LectureSessionTable.tableName,
      where: '${LectureSessionTable.id} = ?',
      whereArgs: [lectureSessionId],
    );
  }

  Future<int> startLectureSession(int lectureSessionId) async {
    final db = await _databaseService.database;

    final lectureSession = await getLectureSessionById(lectureSessionId);

    if (lectureSession == null) {
      throw StateError('Lecture session not found.');
    }

    if (lectureSession.isCompleted) {
      throw StateError('A completed lecture session cannot be started again.');
    }

    if (lectureSession.isActive) {
      return 0;
    }

    final now = DateTime.now();

    return db.update(
      LectureSessionTable.tableName,
      {
        LectureSessionTable.status: LectureSessionStatus.active.name,
        LectureSessionTable.startedAt: now.toIso8601String(),
        LectureSessionTable.updatedAt: now.toIso8601String(),
      },
      where: '${LectureSessionTable.id} = ?',
      whereArgs: [lectureSessionId],
    );
  }

  Future<int> completeLectureSession(int lectureSessionId) async {
    final db = await _databaseService.database;

    final lectureSession = await getLectureSessionById(lectureSessionId);

    if (lectureSession == null) {
      throw StateError('Lecture session not found.');
    }

    if (lectureSession.isCompleted) {
      return 0;
    }

    if (!lectureSession.isActive) {
      throw StateError('Only an active lecture session can be completed.');
    }

    return db.update(
      LectureSessionTable.tableName,
      {
        LectureSessionTable.status: LectureSessionStatus.completed.name,
        LectureSessionTable.updatedAt: DateTime.now().toIso8601String(),
      },
      where: '${LectureSessionTable.id} = ?',
      whereArgs: [lectureSessionId],
    );
  }

  Future<double> calculateAverageAttendance() async {
    final db = await _databaseService.database;

    /*
     * Do not join course students, lecture sessions and attendance
     * records directly.
     *
     * Doing that multiplies rows and causes attendance counts to
     * become artificially large.
     *
     * Instead, calculate each value independently for every course.
     */
    final result = await db.rawQuery('''
      SELECT
        COALESCE(
          SUM(course_stats.attendance_count),
          0
        ) AS total_attendance,

        COALESCE(
          SUM(
            course_stats.student_count *
            course_stats.lecture_session_count
          ),
          0
        ) AS total_possible_attendance

      FROM (
        SELECT
          c.${CourseTable.id} AS course_id,

          (
            SELECT COUNT(*)
            FROM ${CourseStudentTable.tableName} cs
            WHERE cs.${CourseStudentTable.courseId} = c.${CourseTable.id}
          ) AS student_count,

          (
            SELECT COUNT(*)
            FROM ${LectureSessionTable.tableName} ls
            WHERE ls.${LectureSessionTable.courseId} = c.${CourseTable.id}
          ) AS lecture_session_count,

          (
            SELECT COUNT(*)
            FROM ${AttendanceRecordTable.tableName} ar
            INNER JOIN ${LectureSessionTable.tableName} ls2
              ON ar.${AttendanceRecordTable.lectureSessionId} =
                 ls2.${LectureSessionTable.id}
            WHERE ls2.${LectureSessionTable.courseId} =
                  c.${CourseTable.id}
          ) AS attendance_count

        FROM ${CourseTable.tableName} c
      ) AS course_stats
      ''');

    if (result.isEmpty) {
      return 0.0;
    }

    final row = result.first;

    final totalAttendance =
        (row['total_attendance'] as num?)?.toDouble() ?? 0.0;

    final totalPossibleAttendance =
        (row['total_possible_attendance'] as num?)?.toDouble() ?? 0.0;

    if (totalPossibleAttendance <= 0) {
      return 0.0;
    }

    final percentage = (totalAttendance / totalPossibleAttendance) * 100;

    /*
     * Attendance percentage should never exceed 100%.
     *
     * The SQL above already prevents the previous multiplication
     * problem, but this also protects the displayed statistic from
     * bad/duplicate data.
     */
    return percentage.clamp(0.0, 100.0);
  }

  Future<double> calculateCourseAverageAttendance(Course course) async {
    final db = await _databaseService.database;

    final result = await db.rawQuery(
      '''
      SELECT
        COUNT(ar.${AttendanceRecordTable.id})
          AS attendance_record_count,

        COUNT(DISTINCT ls.${LectureSessionTable.id})
          AS lecture_session_count

      FROM ${LectureSessionTable.tableName} ls

      LEFT JOIN ${AttendanceRecordTable.tableName} ar
        ON ar.${AttendanceRecordTable.lectureSessionId} =
           ls.${LectureSessionTable.id}

      WHERE ls.${LectureSessionTable.courseId} = ?
      ''',
      [course.id],
    );

    if (result.isEmpty) {
      return 0.0;
    }

    final row = result.first;

    final attendanceRecordCount =
        (row['attendance_record_count'] as num?)?.toInt() ?? 0;

    final lectureSessionsCount =
        (row['lecture_session_count'] as num?)?.toInt() ?? 0;

    if (course.studentCount == 0 || lectureSessionsCount == 0) {
      return 0.0;
    }

    final percentage =
        (attendanceRecordCount / (course.studentCount * lectureSessionsCount)) *
        100;

    return percentage.clamp(0.0, 100.0);
  }

  Future<int> getLectureSessionCount(int courseId) async {
    final db = await _databaseService.database;

    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) AS lecture_session_count
      FROM ${LectureSessionTable.tableName}
      WHERE ${LectureSessionTable.courseId} = ?
      ''',
      [courseId],
    );

    return (result.first['lecture_session_count'] as num).toInt();
  }

  Future<List<LectureSession>> getTodayLectureSessions() async {
    final now = DateTime.now();

    final startOfDay = DateTime(now.year, now.month, now.day);

    final endOfDay = startOfDay.add(const Duration(days: 1));

    final db = await _databaseService.database;

    final maps = await db.query(
      LectureSessionTable.tableName,
      where:
          '${LectureSessionTable.lectureDate} >= ? '
          'AND ${LectureSessionTable.lectureDate} < ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: '${LectureSessionTable.fromTime} ASC',
    );

    return maps.map(LectureSession.fromMap).toList();
  }

Future<LectureSessionAttendanceStats> getLectureSessionAttendanceStats(
    int lectureSessionId,
  ) async {
    final db = await _databaseService.database;

    final result = await db.rawQuery(
      '''
    SELECT
      (
        SELECT COUNT(*)
        FROM ${AttendanceRecordTable.tableName} ar
        WHERE ar.${AttendanceRecordTable.lectureSessionId} = ?
      ) AS present_count,
      (
        SELECT COUNT(*)
        FROM ${CourseStudentTable.tableName} cs
        INNER JOIN ${LectureSessionTable.tableName} ls
          ON ls.${LectureSessionTable.courseId} = cs.course_id
        WHERE ls.${LectureSessionTable.id} = ?
      ) AS total_students
    ''',
      [lectureSessionId, lectureSessionId],
    );

    if (result.isEmpty) {
      return const LectureSessionAttendanceStats(
        presentCount: 0,
        totalStudents: 0,
      );
    }

    final row = result.first;

    return LectureSessionAttendanceStats(
      presentCount: (row['present_count'] as int?) ?? 0,
      totalStudents: (row['total_students'] as int?) ?? 0,
    );
  }
}
