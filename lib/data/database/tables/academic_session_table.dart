class AcademicSessionTable {
  static const String tableName = 'academic_sessions';

  static const String id = 'id';
  static const String name = 'name';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';

  static const String createTable =
      '''
    CREATE TABLE $tableName (
      $id INTEGER PRIMARY KEY AUTOINCREMENT,
      $name TEXT NOT NULL UNIQUE,
      $createdAt TEXT NOT NULL,
      $updatedAt TEXT NOT NULL
    );
  ''';

  static const String dropTable = 'DROP TABLE IF EXISTS $tableName';
}
