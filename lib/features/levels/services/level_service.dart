import 'package:attendance_management_system/data/database/database_service.dart';
import 'package:attendance_management_system/features/levels/tables/level_table.dart';
import 'package:attendance_management_system/features/levels/results/level_result.dart';

import '../models/level.dart';

class LevelService {
  LevelService._();
  static final LevelService instance = LevelService._();

  final DatabaseService _databaseService = DatabaseService.instance;

  Future<List<Level>> getLevels() async {
    final db = await _databaseService.database;

    final result = await db.query(
      LevelTable.tableName,
      orderBy: '${LevelTable.id} DESC',
    );

    return result.map((e) => Level.fromMap(e)).toList();
  }

  Future<Level?> getLevel(int id) async {
    final db = await _databaseService.database;

    final result = await db.query(
      LevelTable.tableName,
      where: "${LevelTable.id} = ?",
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return Level.fromMap(result.first);
  }

  Future<LevelResult> createLevel(Level level) async {
    final db = await DatabaseService.instance.database;

    final existing = await db.query(
      LevelTable.tableName,
      where: '${LevelTable.name} = ?',
      whereArgs: [level.name],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      return const LevelResult(
        success: false,
        levelNameError: 'This level already exists, try using diffrent name.',
      );
    }

    await db.insert(LevelTable.tableName, level.toMap());

    return const LevelResult(success: true);
  }

  Future<LevelResult> updateLevel(Level level) async {
    final db = await DatabaseService.instance.database;

    final existing = await db.query(
      LevelTable.tableName,
      where:
          '${LevelTable.name} = ? AND '
          '${LevelTable.id} != ?',
      whereArgs: [level.name, level.id],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      return const LevelResult(
        success: false,
        levelNameError: 'This level already exists, try using diffrent name.',
      );
    }

    await db.update(
      LevelTable.tableName,
      level.toMap(),
      where: '${LevelTable.id} = ?',
      whereArgs: [level.id],
    );

    return const LevelResult(success: true);
  }

  Future<bool> deleteLevel(int id) async {
    final db = await _databaseService.database;

    final rows = await db.delete(
      LevelTable.tableName,
      where: '${LevelTable.id} = ?',
      whereArgs: [id],
    );

    return rows > 0;
  }
}
