import 'package:attendance_management_system/features/courses/tables/course_table.dart';

class LectureSessionTable {
  static const String tableName = 'lecture_sessions';

  static const String id = 'id';
  static const String courseId = 'course_id';
  static const String sessionNumber = 'session_number';
  static const String weekNumber = 'week_number';
  static const String lectureDate = 'lecture_date';
  static const String fromTime = 'from_time';
  static const String toTime = 'to_time';
  static const String durationMinutes = 'duration_minutes';
  static const String status = 'status';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
  static const String startedAt = 'started_at';

  static const String createTable =
      '''
      CREATE TABLE $tableName (
        $id INTEGER PRIMARY KEY AUTOINCREMENT,

        $courseId INTEGER NOT NULL,
        $sessionNumber INTEGER NOT NULL,
        $weekNumber INTEGER NOT NULL,

        $lectureDate TEXT NOT NULL,
        $fromTime TEXT NOT NULL,
        $toTime TEXT NOT NULL,
        $durationMinutes INTEGER NOT NULL,

        $status TEXT NOT NULL DEFAULT 'scheduled',

        $createdAt TEXT NOT NULL,
        $updatedAt TEXT NOT NULL,
        $startedAt TEXT,

        FOREIGN KEY ($courseId)
          REFERENCES ${CourseTable.tableName}(${CourseTable.id})
          ON UPDATE CASCADE
          ON DELETE RESTRICT,

        UNIQUE($courseId, $sessionNumber)
      );
    ''';

  static const String dropTable = 'DROP TABLE IF EXISTS $tableName';
}
