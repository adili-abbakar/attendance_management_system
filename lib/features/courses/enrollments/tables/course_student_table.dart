class CourseStudentTable {
  CourseStudentTable._();

  static const tableName = 'course_students';
  static const id = 'id';
  static const courseId = 'course_id';
  static const studentId = 'student_id';
  static const createdAt = 'created_at';

  static String get createTable =>
      '''
      CREATE TABLE $tableName (
        $id INTEGER PRIMARY KEY AUTOINCREMENT,
        $courseId INTEGER NOT NULL,
        $studentId INTEGER NOT NULL,
        $createdAt TEXT NOT NULL,

        FOREIGN KEY ($courseId)
          REFERENCES courses(id)
          ON DELETE CASCADE,

        FOREIGN KEY ($studentId)
          REFERENCES students(id)
          ON DELETE CASCADE,

        UNIQUE($courseId, $studentId)
      );
      ''';
}
