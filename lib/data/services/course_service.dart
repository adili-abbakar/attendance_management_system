import 'package:attendance_management_system/data/database/database_service.dart';
import 'package:attendance_management_system/data/database/tables/course_table.dart';
import 'package:attendance_management_system/data/results/course/course_result.dart';

import '../models/course.dart';

class CourseService {
  CourseService._();
  static final CourseService instance = CourseService._();

  final DatabaseService _databaseService = DatabaseService.instance;

  Future<List<Course>> getCourses() async {
    final db = await _databaseService.database;

    final result = await db.query(
      CourseTable.tableName,
      orderBy: '${CourseTable.id} DESC',
    );

    return result.map((e) => Course.fromMap(e)).toList();
  }

  Future<Course?> getCourse(int id) async {
    final db = await _databaseService.database;

    final result = await db.query(
      CourseTable.tableName,
      where: "${CourseTable.id} = ?",
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return Course.fromMap(result.first);
  }

  Future<CourseResult> createCourse(Course course) async {
    final db = await DatabaseService.instance.database;

    final existing = await db.query(
      CourseTable.tableName,
      where:
          '${CourseTable.code} = ? AND '
          '${CourseTable.semester} = ? AND '
          '${CourseTable.academicSession} = ?',
      whereArgs: [course.code, course.semester, course.academicSession],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      return const CourseResult(
        success: false,
        courseCodeError:
            'This course already exists for the selected semester and academic session.',
      );
    }

    await db.insert(CourseTable.tableName, course.toMap());

    return const CourseResult(success: true);
  }

  Future<CourseResult> updateCourse(Course course) async {
    final db = await DatabaseService.instance.database;

    final existing = await db.query(
      CourseTable.tableName,
      where:
          '${CourseTable.code} = ? AND '
          '${CourseTable.semester} = ? AND '
          '${CourseTable.academicSession} = ? AND '
          '${CourseTable.id} != ?',
      whereArgs: [
        course.code,
        course.semester,
        course.academicSession,
        course.id,
      ],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      return const CourseResult(
        success: false,
        courseCodeError:
            'This course already exists for the selected semester and academic session.',
      );
    }

    await db.update(
      CourseTable.tableName,
      course.toMap(),
      where: '${CourseTable.id} = ?',
      whereArgs: [course.id],
    );

    return const CourseResult(success: true);
  }
  
  Future<bool> deleteCourse(int id) async {
    final db = await _databaseService.database;

    final rows = await db.delete(
      CourseTable.tableName,
      where: '${CourseTable.id} = ?',
      whereArgs: [id],
    );

    return rows > 0;
  }
}
