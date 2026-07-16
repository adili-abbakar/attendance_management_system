import 'package:attendance_management_system/data/database/tables/course_table.dart';
import 'package:attendance_management_system/data/database/tables/level_table.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'tables/user_table.dart';

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
    // print('Database Path: $path');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // print('Creating Database....');
    await db.execute(UserTable.createTable);
    await db.execute(CourseTable.createTable);
    await db.execute(LevelTable.createTable);
    // print('tables created successfully.');
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
