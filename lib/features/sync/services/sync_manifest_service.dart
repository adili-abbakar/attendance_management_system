import 'package:attendance_management_system/data/database/database_service.dart';
import 'package:attendance_management_system/features/academic_session/tables/academic_session_table.dart';
import 'package:attendance_management_system/features/attendance/attendance/tables/attendance_record_table.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/tables/lecture_session_table.dart';
import 'package:attendance_management_system/features/courses/enrollments/tables/course_student_table.dart';
import 'package:attendance_management_system/features/courses/tables/course_table.dart';
import 'package:attendance_management_system/features/levels/tables/level_table.dart';
import 'package:attendance_management_system/features/students/tables/student_table.dart';
import 'package:attendance_management_system/features/sync/models/sync_models.dart';

class SyncManifestService {
  SyncManifestService._();

  static final SyncManifestService instance = SyncManifestService._();

  final List<String> _syncTables = const [
    LevelTable.tableName,
    AcademicSessionTable.tableName,
    CourseTable.tableName,
    StudentTable.tableName,
    CourseStudentTable.tableName,
    LectureSessionTable.tableName,
    AttendanceRecordTable.tableName,
  ];

  Future<List<SyncManifestEntry>> buildManifest() async {
    final db = await DatabaseService.instance.database;
    final manifests = <SyncManifestEntry>[];

    for (final tableName in _syncTables) {
      final rows = await db.query(tableName);
      for (final row in rows) {
        final recordUuid = (row['record_uuid'] ?? row['id'])?.toString();
        final updatedAtValue = row['updated_at'] ?? row['created_at'] ?? DateTime.now().toUtc().toIso8601String();
        final updatedAt = DateTime.tryParse(updatedAtValue.toString())?.toUtc() ?? DateTime.now().toUtc();
        final record = Map<String, dynamic>.from(row);
        final contentHash = SyncManifestEntry.hashRecord(record);

        manifests.add(
          SyncManifestEntry(
            tableName: tableName,
            recordUuid: recordUuid ?? 'missing-$tableName-${row['id']}',
            updatedAt: updatedAt,
            contentHash: contentHash,
            record: record,
          ),
        );
      }
    }

    return manifests;
  }

  Future<List<Map<String, dynamic>>> loadTableRows(String tableName) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(tableName);
    return rows.map((row) => Map<String, dynamic>.from(row)).toList();
  }
}
