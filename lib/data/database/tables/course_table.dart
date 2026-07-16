class CourseTable {
  static const String tableName = 'courses';

  static const String id = 'id';
  static const String code = 'code';
  static const String title = 'title';
  static const String level = 'level';
  static const String semester = 'semester';
  static const String academicSession = 'academic_session';
  static const String isActive = 'is_active';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';

  static const String createTable =
      '''
    CREATE TABLE $tableName (
      $id INTEGER PRIMARY KEY AUTOINCREMENT,
      $code TEXT NOT NULL UNIQUE,
      $title TEXT NOT NULL,
      $level TEXT NOT NULL,
      $semester INTEGER NOT NULL,
      $academicSession TEXT NOT NULL,
      $isActive INTEGER NOT NULL DEFAULT 1,
      $createdAt TEXT NOT NULL,
      $updatedAt TEXT NOT NULL
    );
  ''';

  static const String dropTable = 'DROP TABLE IF EXISTS $tableName';
}
