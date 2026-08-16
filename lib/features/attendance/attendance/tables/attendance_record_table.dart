import 'package:attendance_management_system/features/attendance/lecture_session/tables/lecture_session_table.dart';
import 'package:attendance_management_system/features/students/tables/student_table.dart';

class AttendanceRecordTable {
  static const String tableName = 'attendance_records';

  static const String id = 'id';
  static const String lectureSessionId = 'lecture_session_id';
  static const String studentId = 'student_id';
  static const String status = 'status';
  static const String scannedAt = 'scanned_at';

  static const String createTable =
      '''
      CREATE TABLE $tableName (
        $id INTEGER PRIMARY KEY AUTOINCREMENT,

        $lectureSessionId INTEGER NOT NULL,
        $studentId INTEGER NOT NULL,

        $status TEXT NOT NULL DEFAULT 'present',
        $scannedAt TEXT NOT NULL,

        FOREIGN KEY ($lectureSessionId)
          REFERENCES ${LectureSessionTable.tableName}(${LectureSessionTable.id})
          ON UPDATE CASCADE
          ON DELETE CASCADE,

        FOREIGN KEY ($studentId)
          REFERENCES ${StudentTable.tableName}(${StudentTable.id})
          ON UPDATE CASCADE
          ON DELETE RESTRICT,

        UNIQUE($lectureSessionId, $studentId)
      );
    ''';

  static const String dropTable = 'DROP TABLE IF EXISTS $tableName';
}
