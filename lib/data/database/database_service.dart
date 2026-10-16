import 'package:attendance_management_system/features/academic_session/tables/academic_session_table.dart';
import 'package:attendance_management_system/features/attendance/attendance/tables/attendance_record_table.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/tables/lecture_session_table.dart';
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
      version: 2,

      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },

      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(UserTable.createTable);
    await db.execute(LevelTable.createTable);
    await db.execute(AcademicSessionTable.createTable);
    await db.execute(CourseTable.createTable);
    await db.execute(StudentTable.createTable);
    await db.execute(CourseStudentTable.createTable);
    await db.execute(LectureSessionTable.createTable);
    await db.execute(AttendanceRecordTable.createTable);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TEMP TABLE _students_before_activity_removal AS
        SELECT id, admission_number, full_name, created_at, updated_at
        FROM students
      ''');
      await db.execute('''
        CREATE TEMP TABLE _course_students_before_activity_removal AS
        SELECT * FROM ${CourseStudentTable.tableName}
      ''');
      await db.execute('''
        CREATE TEMP TABLE _attendance_records_before_activity_removal AS
        SELECT * FROM ${AttendanceRecordTable.tableName}
      ''');

      await db.execute(AttendanceRecordTable.dropTable);
      await db.execute('DROP TABLE ${CourseStudentTable.tableName}');
      await db.execute(StudentTable.dropTable);
      await db.execute(StudentTable.createTable);

      await db.execute('''
        INSERT INTO ${StudentTable.tableName}
          (${StudentTable.id}, ${StudentTable.admissionNumber},
           ${StudentTable.fullName}, ${StudentTable.createdAt},
           ${StudentTable.updatedAt})
        SELECT id, admission_number, full_name, created_at, updated_at
        FROM _students_before_activity_removal
      ''');

      await db.execute(CourseStudentTable.createTable);
      await db.execute('''
        INSERT INTO ${CourseStudentTable.tableName}
        SELECT * FROM _course_students_before_activity_removal
      ''');

      await db.execute(AttendanceRecordTable.createTable);
      await db.execute('''
        INSERT INTO ${AttendanceRecordTable.tableName}
        SELECT * FROM _attendance_records_before_activity_removal
      ''');

      await db.execute(
        'DROP TABLE _attendance_records_before_activity_removal',
      );
      await db.execute('DROP TABLE _course_students_before_activity_removal');
      await db.execute('DROP TABLE _students_before_activity_removal');
    }
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
