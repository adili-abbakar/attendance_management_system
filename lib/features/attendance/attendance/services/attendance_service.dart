import 'package:attendance_management_system/data/database/database_service.dart';
import 'package:attendance_management_system/features/attendance/attendance/models/attendance_record.dart';
import 'package:attendance_management_system/features/attendance/attendance/results/attendance_result.dart';
import 'package:attendance_management_system/features/attendance/attendance/tables/attendance_record_table.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/services/lecture_session_service.dart';
import 'package:attendance_management_system/features/students/services/student_service.dart';

class AttendanceService {
  AttendanceService._();

  static final AttendanceService instance = AttendanceService._();

  final DatabaseService _databaseService = DatabaseService.instance;

  final StudentService _studentService = StudentService.instance;

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

  Future<AttendanceResult> recordAttendance({
    required int lectureSessionId,
    required int studentId,
  }) async {
    final lectureSession = await _lectureSessionService.getLectureSessionById(
      lectureSessionId,
    );

    if (lectureSession == null) {
      return const AttendanceResult.failure(
        status: AttendanceResultStatus.error,
        message: 'Lecture session not found.',
      );
    }

    if (!lectureSession.isActive) {
      return const AttendanceResult.failure(
        status: AttendanceResultStatus.lectureSessionNotActive,
        message: 'This lecture session is not active.',
      );
    }

    final student = await _studentService.getStudent(studentId);

    if (student == null) {
      return const AttendanceResult.failure(
        status: AttendanceResultStatus.studentNotFound,
        message: 'Student not found.',
      );
    }

    final alreadyAttended = await hasStudentAttended(
      lectureSessionId: lectureSessionId,
      studentId: studentId,
    );

    if (alreadyAttended) {
      return AttendanceResult.failure(
        status: AttendanceResultStatus.alreadyAttended,
        message: 'Attendance has already been recorded for this student.',
        student: student,
      );
    }

    final record = AttendanceRecord(
      lectureSessionId: lectureSessionId,
      studentId: studentId,
      status: AttendanceRecordStatus.present,
      scannedAt: DateTime.now(),
    );

    final db = await _databaseService.database;

    final data = record.toMap()..remove(AttendanceRecordTable.id);

    final id = await db.insert(AttendanceRecordTable.tableName, data);

    return AttendanceResult.success(
      record: record.copyWith(id: id),
      student: student,
    );
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

  Future<int> deleteAttendanceRecord(int recordId) async {
    final db = await _databaseService.database;

    return db.delete(
      AttendanceRecordTable.tableName,
      where: '${AttendanceRecordTable.id} = ?',
      whereArgs: [recordId],
    );
  }
}
