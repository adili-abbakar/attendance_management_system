import 'package:attendance_management_system/features/academic_session/tables/academic_session_table.dart';
import 'package:attendance_management_system/features/courses/enrollments/tables/course_student_table.dart';
import 'package:attendance_management_system/features/courses/tables/course_table.dart';
import 'package:attendance_management_system/features/levels/tables/level_table.dart';
import 'package:attendance_management_system/features/students/tables/student_table.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../features/auth/tables/user_table.dart';

class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initializeDatabase();

    return _database!;
  }

  Future<Database> _initializeDatabase() async {
    final databasePath = await getDatabasesPath();

    final path = join(databasePath, 'attendance_management.db');

    return await openDatabase(
      path,
      version: 1,

      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },

      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(UserTable.createTable);

    await db.execute(LevelTable.createTable);
    await db.execute(AcademicSessionTable.createTable);
    await db.execute(CourseTable.createTable);
    await db.execute(StudentTable.createTable);
    await db.execute(CourseStudentTable.createTable);
  }

  Future<void> closeDatabase() async {
    final db = await database;
    db.close();
  }

  Future<void> deleteDatabaseFile() async {
    final databasePath = await getDatabasesPath();

    final path = join(databasePath, 'attendance_management.db');

    await deleteDatabase(path);

    _database = null;
  }
}
