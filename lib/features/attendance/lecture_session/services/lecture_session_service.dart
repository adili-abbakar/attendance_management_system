import 'package:attendance_management_system/data/database/database_service.dart';
import 'package:attendance_management_system/features/attendance/attendance/tables/attendance_record_table.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/models/lecture_session.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/tables/lecture_session_table.dart';
import 'package:attendance_management_system/features/courses/enrollments/tables/course_student_table.dart';
import 'package:attendance_management_system/features/courses/models/course.dart';
import 'package:attendance_management_system/features/courses/tables/course_table.dart';

class LectureSessionService {
  LectureSessionService._();

  static final LectureSessionService instance = LectureSessionService._();

  final DatabaseService _databaseService = DatabaseService.instance;

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

    final result = await db.rawQuery('''
    SELECT
      COALESCE(SUM(course_stats.attendance_count), 0)
        AS total_attendance,

      COALESCE(SUM(
        course_stats.student_count * course_stats.lecture_session_count
      ), 0) AS total_possible_attendance

    FROM (
      SELECT
        c.id,

        COUNT(DISTINCT cs.student_id) AS student_count,

        COUNT(DISTINCT ls.${LectureSessionTable.id})
          AS lecture_session_count,

        COUNT(ar.${AttendanceRecordTable.id})
          AS attendance_count

      FROM ${CourseTable.tableName} c

      LEFT JOIN ${CourseStudentTable.tableName} cs
        ON cs.course_id = c.id

      LEFT JOIN ${LectureSessionTable.tableName} ls
        ON ls.${LectureSessionTable.courseId} = c.id

      LEFT JOIN ${AttendanceRecordTable.tableName} ar
        ON ar.${AttendanceRecordTable.lectureSessionId} =
           ls.${LectureSessionTable.id}

      GROUP BY c.id
    ) AS course_stats
    ''');

    if (result.isEmpty) {
      return 0.0;
    }

    final row = result.first;

    final totalAttendance = row['total_attendance'] as int? ?? 0;

    final totalPossibleAttendance =
        row['total_possible_attendance'] as int? ?? 0;

    if (totalPossibleAttendance == 0) {
      return 0.0;
    }

    return (totalAttendance / totalPossibleAttendance) * 100;
  }
  
  Future<double> calculateCourseAverageAttendance(Course course) async {
    final db = await _databaseService.database;

    final result = await db.rawQuery(
      '''
    SELECT
      COUNT(ar.${AttendanceRecordTable.id}) AS attendance_record_count,
      COUNT(DISTINCT ls.${LectureSessionTable.id}) AS lecture_session_count
    FROM ${LectureSessionTable.tableName} ls
    LEFT JOIN ${AttendanceRecordTable.tableName} ar
      ON ar.${AttendanceRecordTable.lectureSessionId} =
         ls.${LectureSessionTable.id}
    WHERE ls.${LectureSessionTable.courseId} = ?
    ''',
      [course.id],
    );

    if (result.isNotEmpty) {
      final row = result.first;

      final attendanceRecordCount = row['attendance_record_count'] as int;

      final lectureSessionsCount = row['lecture_session_count'] as int;

      if (course.studentCount == 0 || lectureSessionsCount == 0) {
        return 0.0;
      }

      return (attendanceRecordCount /
              (course.studentCount * lectureSessionsCount)) *
          100;
    }

    return 0.0;
  }

  Future<int> getLectureSessionCount(int courseId) async {
    final db = await _databaseService.database;

    final result = await db.rawQuery(
      '''
  select count(*) as lecture_session_count 
  from ${LectureSessionTable.tableName} where ${LectureSessionTable.courseId} = ?
''',
      [courseId],
    );

    return result.first['lecture_session_count'] as int;
  }
}
