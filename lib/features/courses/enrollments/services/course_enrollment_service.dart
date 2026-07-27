import 'package:attendance_management_system/data/database/database_service.dart';
import 'package:attendance_management_system/features/courses/enrollments/models/course_student.dart';
import 'package:attendance_management_system/features/courses/enrollments/tables/course_student_table.dart';
import 'package:sqflite/sqflite.dart';
import 'package:attendance_management_system/features/students/models/student.dart';
import 'package:attendance_management_system/features/students/tables/student_table.dart';

class CourseEnrollmentService {
  CourseEnrollmentService._();

  static final instance = CourseEnrollmentService._();

  final DatabaseService _databaseService = DatabaseService.instance;

  Future<Set<int>> alreadyEnrolledStudentIds(
    int courseId,
    List<int> studentIds, {
    DatabaseExecutor? executor,
  }) async {
    if (studentIds.isEmpty) {
      return {};
    }

    final db = executor ?? await _databaseService.database;

    final placeholders = List.filled(studentIds.length, '?').join(',');

    final result = await db.query(
      CourseStudentTable.tableName,
      columns: [CourseStudentTable.studentId],
      where:
          '${CourseStudentTable.courseId} = ? AND '
          '${CourseStudentTable.studentId} IN ($placeholders)',
      whereArgs: [courseId, ...studentIds],
    );

    return result
        .map((row) => row[CourseStudentTable.studentId] as int)
        .toSet();
  }

  Future<void> enrollStudent(
    CourseStudent enrollment, {
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? await _databaseService.database;

    await db.insert(CourseStudentTable.tableName, enrollment.toMap());
  }

  Future<void> enrollStudents(
    List<CourseStudent> enrollments, {
    DatabaseExecutor? executor,
  }) async {
    if (enrollments.isEmpty) return;

    final db = executor ?? await _databaseService.database;

    final batch = db.batch();

    for (final enrollment in enrollments) {
      batch.insert(CourseStudentTable.tableName, enrollment.toMap());
    }

    await batch.commit(noResult: true);
  }

  Future<bool> isStudentEnrolled({
    required int courseId,
    required int studentId,
  }) async {
    final enrolled = await alreadyEnrolledStudentIds(courseId, [studentId]);

    return enrolled.contains(studentId);
  }

  Future<int> getStudentCount(
    int courseId, {
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? await _databaseService.database;

    final result = Sqflite.firstIntValue(
      await db.rawQuery(
        '''
      SELECT COUNT(*)
      FROM ${CourseStudentTable.tableName}
      WHERE ${CourseStudentTable.courseId} = ?
      ''',
        [courseId],
      ),
    );

    return result ?? 0;
  }

  Future<List<Student>> getStudentsForCourse(
    int courseId, {
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? await _databaseService.database;

    final result = await db.rawQuery(
      '''
    SELECT
      s.*
    FROM ${StudentTable.tableName} s

    INNER JOIN ${CourseStudentTable.tableName} cs
      ON s.${StudentTable.id} = cs.${CourseStudentTable.studentId}

    WHERE cs.${CourseStudentTable.courseId} = ?

    ORDER BY s.${StudentTable.fullName} ASC
    ''',
      [courseId],
    );

    return result.map((student) => Student.fromMap(student)).toList();
  }

  Future<bool> removeStudentFromCourse({
    required int courseId,
    required int studentId,
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? await _databaseService.database;

    final rows = await db.delete(
      CourseStudentTable.tableName,
      where:
          '${CourseStudentTable.courseId} = ? AND '
          '${CourseStudentTable.studentId} = ?',
      whereArgs: [courseId, studentId],
    );

    return rows > 0;
  }
}
