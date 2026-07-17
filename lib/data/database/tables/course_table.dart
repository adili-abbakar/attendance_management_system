import 'package:attendance_management_system/data/database/tables/academic_session_table.dart';
import 'package:attendance_management_system/data/database/tables/level_table.dart';

class CourseTable {
  static const String tableName = 'courses';

  static const String id = 'id';
  static const String code = 'code';
  static const String title = 'title';
  static const String levelId = 'level_id';
  static const String semester = 'semester';
  static const String academicSessionId = 'academic_session_id';
  static const String isActive = 'is_active';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';

  static const String createTable =
      '''
      CREATE TABLE $tableName (
        $id INTEGER PRIMARY KEY AUTOINCREMENT,
        $code TEXT NOT NULL,
        $title TEXT NOT NULL,

        $levelId INTEGER NOT NULL,
        $semester INTEGER NOT NULL,
        $academicSessionId INTEGER NOT NULL,

        $isActive INTEGER NOT NULL DEFAULT 1,
        $createdAt TEXT NOT NULL,
        $updatedAt TEXT NOT NULL,

        FOREIGN KEY ($levelId)
          REFERENCES ${LevelTable.tableName}(${LevelTable.id})
          ON UPDATE CASCADE
          ON DELETE RESTRICT,

        FOREIGN KEY ($academicSessionId)
          REFERENCES ${AcademicSessionTable.tableName}(${AcademicSessionTable.id})
          ON UPDATE CASCADE
          ON DELETE RESTRICT,

        UNIQUE($code, $levelId, $semester, $academicSessionId)
      );
    ''';

  static const String dropTable = 'DROP TABLE IF EXISTS $tableName';
}
