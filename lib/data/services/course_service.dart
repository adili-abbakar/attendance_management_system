import 'package:attendance_management_system/data/database/database_service.dart';
import 'package:attendance_management_system/data/database/tables/academic_session_table.dart';
import 'package:attendance_management_system/data/database/tables/course_table.dart';
import 'package:attendance_management_system/data/database/tables/level_table.dart';
import 'package:attendance_management_system/data/results/course/course_result.dart';

import '../models/course.dart';

class CourseService {
  CourseService._();

  static final CourseService instance = CourseService._();

  final DatabaseService _databaseService = DatabaseService.instance;

  Future<List<Course>> getCourses() async {
    final db = await _databaseService.database;

    final result = await db.rawQuery('''
      SELECT
        c.*,

        l.id AS level_id,
        l.name AS level_name,

        s.id AS academic_session_id,
        s.name AS academic_session_name

      FROM ${CourseTable.tableName} c

      INNER JOIN ${LevelTable.tableName} l
        ON c.${CourseTable.levelId} = l.${LevelTable.id}

      INNER JOIN ${AcademicSessionTable.tableName} s
        ON c.${CourseTable.academicSessionId} = s.${AcademicSessionTable.id}

      ORDER BY c.${CourseTable.id} DESC
    ''');

    return result.map((e) => Course.fromMap(e)).toList();
  }

  Future<Course?> getCourse(int id) async {
    final db = await _databaseService.database;

    final result = await db.rawQuery(
      '''
      SELECT
        c.*,

        l.id AS level_id,
        l.name AS level_name,

        s.id AS academic_session_id,
        s.name AS academic_session_name

      FROM ${CourseTable.tableName} c

      INNER JOIN ${LevelTable.tableName} l
        ON c.${CourseTable.levelId} = l.${LevelTable.id}

      INNER JOIN ${AcademicSessionTable.tableName} s
        ON c.${CourseTable.academicSessionId} = s.${AcademicSessionTable.id}

      WHERE c.${CourseTable.id} = ?

      LIMIT 1
    ''',
      [id],
    );

    if (result.isEmpty) {
      return null;
    }

    return Course.fromMap(result.first);
  }

  Future<CourseResult> createCourse(Course course) async {
    final db = await _databaseService.database;

    final existing = await db.query(
      CourseTable.tableName,
      where:
          '${CourseTable.code} = ? AND '
          '${CourseTable.semester} = ? AND '
          '${CourseTable.levelId} = ? AND '
          '${CourseTable.academicSessionId} = ?',
      whereArgs: [
        course.code,
        course.semester,
        course.levelId,
        course.academicSessionId,
      ],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      return const CourseResult(
        success: false,
        courseCodeError:
            'This course already exists for the selected level, semester and academic session.',
      );
    }

    await db.insert(CourseTable.tableName, course.toMap());

    return const CourseResult(success: true);
  }

  Future<CourseResult> updateCourse(Course course) async {
    final db = await _databaseService.database;

    final existing = await db.query(
      CourseTable.tableName,
      where:
          '${CourseTable.code} = ? AND '
          '${CourseTable.semester} = ? AND '
          '${CourseTable.levelId} = ? AND '
          '${CourseTable.academicSessionId} = ? AND '
          '${CourseTable.id} != ?',
      whereArgs: [
        course.code,
        course.semester,
        course.levelId,
        course.academicSessionId,
        course.id,
      ],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      return const CourseResult(
        success: false,
        courseCodeError:
            'This course already exists for the selected level, semester and academic session.',
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
