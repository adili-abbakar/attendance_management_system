import 'package:attendance_management_system/data/database/database_service.dart';
import 'package:attendance_management_system/features/academic_session/tables/academic_session_table.dart';
import 'package:attendance_management_system/features/academic_session/models/academic_session.dart';
import 'package:attendance_management_system/features/academic_session/results/academic_session_result.dart';

class AcademicSessionSerivce {
  AcademicSessionSerivce._();
  static final AcademicSessionSerivce instance = AcademicSessionSerivce._();

  final DatabaseService _databaseService = DatabaseService.instance;

  Future<List<AcademicSession>> getAcademicSessions() async {
    final db = await _databaseService.database;

    final result = await db.query(
      AcademicSessionTable.tableName,
      orderBy: '${AcademicSessionTable.id} DESC',
    );

    return result.map((e) => AcademicSession.fromMap(e)).toList();
  }

  Future<AcademicSession?> getAcademicSession(int id) async {
    final db = await _databaseService.database;

    final result = await db.query(
      AcademicSessionTable.tableName,
      where: "${AcademicSessionTable.id} = ?",
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return AcademicSession.fromMap(result.first);
  }

  Future<AcademicSessionResult> createAcademicSession(AcademicSession academicSession) async {
    final db = await DatabaseService.instance.database;

    final existing = await db.query(
      AcademicSessionTable.tableName,
      where: '${AcademicSessionTable.name} = ?',
      whereArgs: [academicSession.name],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      return const AcademicSessionResult(
        success: false,
        academicSessionNameError: 'This session already exists, try using diffrent name.',
      );
    }

    await db.insert(AcademicSessionTable.tableName, academicSession.toMap());

    return const AcademicSessionResult(success: true);
  }

  Future<AcademicSessionResult> updateAcademicSession(AcademicSession academicSession) async {
    final db = await DatabaseService.instance.database;

    final existing = await db.query(
      AcademicSessionTable.tableName,
      where:
          '${AcademicSessionTable.name} = ? AND '
          '${AcademicSessionTable.id} != ?',
      whereArgs: [academicSession.name, academicSession.id],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      return const AcademicSessionResult(
        success: false,
        academicSessionNameError: 'This session already exists, try using diffrent name.',
      );
    }

    await db.update(
      AcademicSessionTable.tableName,
      academicSession.toMap(),
      where: '${AcademicSessionTable.id} = ?',
      whereArgs: [academicSession.id],
    );

    return const AcademicSessionResult(success: true);
  }

  Future<bool> deleteAcademicSession(int id) async {
    final db = await _databaseService.database;

    final rows = await db.delete(
      AcademicSessionTable.tableName,
      where: '${AcademicSessionTable.id} = ?',
      whereArgs: [id],
    );

    return rows > 0;
  }
}
