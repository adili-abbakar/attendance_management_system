class StudentTable {
  static const String tableName = 'students';

  static const String id = 'id';

  static const String admissionNumber = 'admission_number';
  static const String fullName = 'full_name';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';

  static const String createTable =
      '''
    CREATE TABLE $tableName (
      $id INTEGER PRIMARY KEY AUTOINCREMENT,

      $admissionNumber TEXT NOT NULL,
      $fullName TEXT NOT NULL,

      $createdAt TEXT NOT NULL,
      $updatedAt TEXT NOT NULL,

      UNIQUE($admissionNumber)
    );
  ''';

  static const String dropTable = 'DROP TABLE IF EXISTS $tableName';
}
