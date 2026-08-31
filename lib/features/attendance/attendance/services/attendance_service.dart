import 'package:attendance_management_system/data/database/database_service.dart';
import 'package:attendance_management_system/features/attendance/attendance/models/attendance_record.dart';
import 'package:attendance_management_system/features/attendance/attendance/results/attendance_result.dart';
import 'package:attendance_management_system/features/attendance/attendance/tables/attendance_record_table.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/services/lecture_session_service.dart';
import 'package:attendance_management_system/features/students/services/student_service.dart';
import 'package:attendance_management_system/features/courses/enrollments/services/course_enrollment_service.dart';
import 'package:attendance_management_system/features/courses/enrollments/models/course_student.dart';

class AttendanceService {
  AttendanceService._();

  static final AttendanceService instance = AttendanceService._();

  final DatabaseService _databaseService = DatabaseService.instance;

  final StudentService _studentService = StudentService.instance;

  final CourseEnrollmentService _courseEnrollmentService =
      CourseEnrollmentService.instance;

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

  Future<bool> isStudentEnrolledForLectureSession({
    required int lectureSessionId,
    required int studentId,
  }) async {
    final lectureSession = await _lectureSessionService.getLectureSessionById(
      lectureSessionId,
    );

    if (lectureSession == null) {
      return false;
    }

    return _courseEnrollmentService.isStudentEnrolled(
      courseId: lectureSession.courseId,
      studentId: studentId,
    );
  }

  Future<AttendanceResult> recordAttendance({
    required int lectureSessionId,
    required String admissionNumber,
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

    final student = await _studentService.getStudentByAdmissionNumber(
      admissionNumber,
    );

    if (student == null) {
      return const AttendanceResult.failure(
        status: AttendanceResultStatus.studentNotFound,
        message: 'No student was found with this admission number.',
      );
    }

    if (student.id == null) {
      return AttendanceResult.failure(
        status: AttendanceResultStatus.error,
        message: 'The student record is invalid.',
        student: student,
      );
    }

    final studentId = student.id!;

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

    final isEnrolled = await isStudentEnrolledForLectureSession(
      lectureSessionId: lectureSessionId,
      studentId: studentId,
    );

    if (!isEnrolled) {
      return AttendanceResult.failure(
        status: AttendanceResultStatus.studentNotEnrolled,
        message:
            'This student exists in the system, but is not enrolled in this course.',
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

  Future<AttendanceResult> enrollAndRecordAttendance({
    required int lectureSessionId,
    required String admissionNumber,
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

    final student = await _studentService.getStudentByAdmissionNumber(
      admissionNumber,
    );

    if (student == null) {
      return const AttendanceResult.failure(
        status: AttendanceResultStatus.studentNotFound,
        message: 'No student was found with this admission number.',
      );
    }

    if (student.id == null) {
      return AttendanceResult.failure(
        status: AttendanceResultStatus.error,
        message: 'The student record is invalid.',
        student: student,
      );
    }

    final studentId = student.id!;
    final db = await _databaseService.database;

    try {
      late AttendanceRecord savedRecord;

      await db.transaction((txn) async {
        final attendanceMaps = await txn.query(
          AttendanceRecordTable.tableName,
          where:
              '${AttendanceRecordTable.lectureSessionId} = ? AND '
              '${AttendanceRecordTable.studentId} = ?',
          whereArgs: [lectureSessionId, studentId],
          limit: 1,
        );

        if (attendanceMaps.isNotEmpty) {
          throw _AlreadyAttendedException();
        }

        final enrollmentIds = await _courseEnrollmentService
            .alreadyEnrolledStudentIds(lectureSession.courseId, [
              studentId,
            ], executor: txn);

        if (!enrollmentIds.contains(studentId)) {
          final enrollment = CourseStudent(
            courseId: lectureSession.courseId,
            studentId: studentId,
            createdAt: DateTime.now(),
          );

          await _courseEnrollmentService.enrollStudent(
            enrollment,
            executor: txn,
          );
        }

        final record = AttendanceRecord(
          lectureSessionId: lectureSessionId,
          studentId: studentId,
          status: AttendanceRecordStatus.present,
          scannedAt: DateTime.now(),
        );

        final data = record.toMap()..remove(AttendanceRecordTable.id);

        final id = await txn.insert(AttendanceRecordTable.tableName, data);

        savedRecord = record.copyWith(id: id);
      });

      return AttendanceResult.success(record: savedRecord, student: student);
    } on _AlreadyAttendedException {
      return AttendanceResult.failure(
        status: AttendanceResultStatus.alreadyAttended,
        message: 'Attendance has already been recorded for this student.',
        student: student,
      );
    } catch (e) {
      return AttendanceResult.failure(
        status: AttendanceResultStatus.error,
        message: 'Failed to enroll the student and record attendance.',
        student: student,
      );
    }
  }

  Future<AttendanceResult> enrollStudent({
    required int lectureSessionId,
    required String admissionNumber,
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

    final student = await _studentService.getStudentByAdmissionNumber(
      admissionNumber,
    );

    if (student == null) {
      return const AttendanceResult.failure(
        status: AttendanceResultStatus.studentNotFound,
        message: 'No student was found with this admission number.',
      );
    }

    if (student.id == null) {
      return AttendanceResult.failure(
        status: AttendanceResultStatus.error,
        message: 'The student record is invalid.',
        student: student,
      );
    }

    final studentId = student.id!;

    try {
      final isEnrolled = await _courseEnrollmentService.isStudentEnrolled(
        courseId: lectureSession.courseId,
        studentId: studentId,
      );

      if (!isEnrolled) {
        final enrollment = CourseStudent(
          courseId: lectureSession.courseId,
          studentId: studentId,
          createdAt: DateTime.now(),
        );

        await _courseEnrollmentService.enrollStudent(enrollment);
      }

      return AttendanceResult(
        status: AttendanceResultStatus.success,
        student: student,
      );
    } catch (e) {
      return AttendanceResult.failure(
        status: AttendanceResultStatus.error,
        message: 'Failed to add the student to this course.',
        student: student,
      );
    }
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

class _AlreadyAttendedException implements Exception {}
