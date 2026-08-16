import 'package:attendance_management_system/data/database/database_service.dart';
import 'package:attendance_management_system/features/attendance/attendance/models/attendance_record.dart';
import 'package:attendance_management_system/features/attendance/attendance/tables/attendance_record_table.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/services/lecture_session_service.dart';

class AttendanceService {
  AttendanceService._();

  static final AttendanceService instance = AttendanceService._();

  final DatabaseService _databaseService = DatabaseService.instance;
  final LectureSessionService _lectureSessionService =
      LectureSessionService.instance;

  Future<List<AttendanceRecord>> getRecordsByLectureSession(
    int lectureSessionId,
  ) async {
    final db = await _databaseService.database;

    final maps = await db.query(
      AttendanceRecordTable.tableName,
      where: '${AttendanceRecordTable.lectureSessionId} = ?',
      whereArgs: [lectureSessionId],
      orderBy: '${AttendanceRecordTable.scannedAt} ASC',
    );

    return maps.map(AttendanceRecord.fromMap).toList();
  }

  Future<AttendanceRecord?> getAttendanceRecord({
    required int lectureSessionId,
    required int studentId,
  }) async {
    final db = await _databaseService.database;

    final maps = await db.query(
      AttendanceRecordTable.tableName,
      where:
          '${AttendanceRecordTable.lectureSessionId} = ? AND '
          '${AttendanceRecordTable.studentId} = ?',
      whereArgs: [lectureSessionId, studentId],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return AttendanceRecord.fromMap(maps.first);
  }

  Future<bool> hasStudentAttended({
    required int lectureSessionId,
    required int studentId,
  }) async {
    final record = await getAttendanceRecord(
      lectureSessionId: lectureSessionId,
      studentId: studentId,
    );

    return record != null;
  }

  Future<int> addAttendanceRecord(AttendanceRecord record) async {
    final lectureSession = await _lectureSessionService.getLectureSessionById(
      record.lectureSessionId,
    );

    if (lectureSession == null) {
      throw StateError('Lecture session not found.');
    }

    if (!lectureSession.isActive) {
      throw StateError('Lecture session is not active.');
    }

    final alreadyAttended = await hasStudentAttended(
      lectureSessionId: record.lectureSessionId,
      studentId: record.studentId,
    );

    if (alreadyAttended) {
      throw StateError(
        'Attendance has already been recorded for this student.',
      );
    }

    final db = await _databaseService.database;

    final data = record.toMap()..remove(AttendanceRecordTable.id);

    return db.insert(AttendanceRecordTable.tableName, data);
  }

  Future<int> getAttendanceCount(int lectureSessionId) async {
    final db = await _databaseService.database;

    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) AS count
      FROM ${AttendanceRecordTable.tableName}
      WHERE ${AttendanceRecordTable.lectureSessionId} = ?
      ''',
      [lectureSessionId],
    );

    return (result.first['count'] as int?) ?? 0;
  }
}
