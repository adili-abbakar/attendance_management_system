class UserTable {
  UserTable._();

  static const String tableName = 'users';

  static const String id = 'id';
  static const String name = 'name';
  static const String email = 'email';
  static const String staffId = 'staff_id';
  static const String password = 'password';

  static const String createTable =
      '''
CREATE TABLE $tableName (
  $id INTEGER PRIMARY KEY AUTOINCREMENT,
  $name TEXT NOT NULL,
  $email TEXT NOT NULL UNIQUE,
  $staffId TEXT NOT NULL UNIQUE,
  $password TEXT NOT NULL
);
''';

  static const String dropTable = 'DROP TABLE IF EXISTS $tableName';
}
