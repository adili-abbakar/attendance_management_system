import 'package:attendance_management_system/features/academic_session/tables/academic_session_table.dart';
import 'package:attendance_management_system/features/attendance/attendance/tables/attendance_record_table.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/tables/lecture_session_table.dart';
import 'package:attendance_management_system/features/courses/enrollments/tables/course_student_table.dart';
import 'package:attendance_management_system/features/courses/tables/course_table.dart';
import 'package:attendance_management_system/features/levels/tables/level_table.dart';
import 'package:attendance_management_system/features/students/tables/student_table.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();

  static Database? _database;

  static const int _databaseVersion = 5;

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
      version: _databaseVersion,

      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },

      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(LevelTable.createTable);
    await db.execute(AcademicSessionTable.createTable);
    await db.execute(CourseTable.createTable);
    await db.execute(StudentTable.createTable);
    await db.execute(CourseStudentTable.createTable);
    await db.execute(LectureSessionTable.createTable);
    await db.execute(AttendanceRecordTable.createTable);
    await db.execute('''
      CREATE TABLE sync_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute('DROP TABLE IF EXISTS users');
    }

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

    if (oldVersion < 4) {
      await _migrateSyncMetadata(db);
    }

    if (oldVersion < 5) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS sync_settings (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL
        )
      ''');
    }
  }

  Future<void> _migrateSyncMetadata(Database db) async {
    final timestamp = DateTime.now().toUtc().toIso8601String();
    final tables = {
      LevelTable.tableName: [LevelTable.recordUuid],
      AcademicSessionTable.tableName: [AcademicSessionTable.recordUuid],
      CourseTable.tableName: [CourseTable.recordUuid],
      StudentTable.tableName: [StudentTable.recordUuid],
      CourseStudentTable.tableName: [CourseStudentTable.recordUuid, CourseStudentTable.updatedAt],
      LectureSessionTable.tableName: [LectureSessionTable.recordUuid],
      AttendanceRecordTable.tableName: [
        AttendanceRecordTable.recordUuid,
        AttendanceRecordTable.createdAt,
        AttendanceRecordTable.updatedAt,
      ],
    };

    final uuid = const Uuid();

    for (final entry in tables.entries) {
      final tableName = entry.key;
      final columnNames = entry.value;
      final schema = await db.rawQuery('PRAGMA table_info($tableName)');
      final existingColumns = schema
          .map((column) => column['name'] as String)
          .toSet();

      for (final columnName in columnNames) {
        if (!existingColumns.contains(columnName)) {
          await db.execute(
            'ALTER TABLE $tableName ADD COLUMN $columnName TEXT',
          );
        }
      }

      final rows = await db.query(tableName);
      for (final row in rows) {
        final rowId = row['id'];
        final rowMap = <String, Object?>{};

        if (!existingColumns.contains(LevelTable.recordUuid) && tableName == LevelTable.tableName) {
          rowMap[LevelTable.recordUuid] = uuid.v4();
        }
        if (!existingColumns.contains(AcademicSessionTable.recordUuid) && tableName == AcademicSessionTable.tableName) {
          rowMap[AcademicSessionTable.recordUuid] = uuid.v4();
        }
        if (!existingColumns.contains(CourseTable.recordUuid) && tableName == CourseTable.tableName) {
          rowMap[CourseTable.recordUuid] = uuid.v4();
        }
        if (!existingColumns.contains(StudentTable.recordUuid) && tableName == StudentTable.tableName) {
          rowMap[StudentTable.recordUuid] = uuid.v4();
        }
        if (!existingColumns.contains(CourseStudentTable.recordUuid) && tableName == CourseStudentTable.tableName) {
          rowMap[CourseStudentTable.recordUuid] = uuid.v4();
        }
        if (!existingColumns.contains(LectureSessionTable.recordUuid) && tableName == LectureSessionTable.tableName) {
          rowMap[LectureSessionTable.recordUuid] = uuid.v4();
        }
        if (!existingColumns.contains(AttendanceRecordTable.recordUuid) && tableName == AttendanceRecordTable.tableName) {
          rowMap[AttendanceRecordTable.recordUuid] = uuid.v4();
        }

        if (tableName == CourseStudentTable.tableName) {
          rowMap[CourseStudentTable.updatedAt] =
              (row[CourseStudentTable.createdAt] ?? timestamp).toString();
        }

        if (tableName == AttendanceRecordTable.tableName) {
          rowMap[AttendanceRecordTable.createdAt] =
              (row[AttendanceRecordTable.scannedAt] ?? timestamp).toString();
          rowMap[AttendanceRecordTable.updatedAt] =
              (row[AttendanceRecordTable.scannedAt] ?? timestamp).toString();
        }

        if (rowMap.isEmpty) {
          continue;
        }

        await db.update(
          tableName,
          rowMap,
          where: 'id = ?',
          whereArgs: [rowId],
        );
      }

      if (tableName == CourseStudentTable.tableName) {
        await db.execute(
          'CREATE UNIQUE INDEX IF NOT EXISTS idx_${CourseStudentTable.tableName}_record_uuid ON ${CourseStudentTable.tableName}(${CourseStudentTable.recordUuid})',
        );
      }
      if (tableName == AttendanceRecordTable.tableName) {
        await db.execute(
          'CREATE UNIQUE INDEX IF NOT EXISTS idx_${AttendanceRecordTable.tableName}_record_uuid ON ${AttendanceRecordTable.tableName}(${AttendanceRecordTable.recordUuid})',
        );
      }
      if (tableName == LevelTable.tableName) {
        await db.execute(
          'CREATE UNIQUE INDEX IF NOT EXISTS idx_${LevelTable.tableName}_record_uuid ON ${LevelTable.tableName}(${LevelTable.recordUuid})',
        );
      }
      if (tableName == AcademicSessionTable.tableName) {
        await db.execute(
          'CREATE UNIQUE INDEX IF NOT EXISTS idx_${AcademicSessionTable.tableName}_record_uuid ON ${AcademicSessionTable.tableName}(${AcademicSessionTable.recordUuid})',
        );
      }
      if (tableName == CourseTable.tableName) {
        await db.execute(
          'CREATE UNIQUE INDEX IF NOT EXISTS idx_${CourseTable.tableName}_record_uuid ON ${CourseTable.tableName}(${CourseTable.recordUuid})',
        );
      }
      if (tableName == StudentTable.tableName) {
        await db.execute(
          'CREATE UNIQUE INDEX IF NOT EXISTS idx_${StudentTable.tableName}_record_uuid ON ${StudentTable.tableName}(${StudentTable.recordUuid})',
        );
      }
      if (tableName == LectureSessionTable.tableName) {
        await db.execute(
          'CREATE UNIQUE INDEX IF NOT EXISTS idx_${LectureSessionTable.tableName}_record_uuid ON ${LectureSessionTable.tableName}(${LectureSessionTable.recordUuid})',
        );
      }
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
