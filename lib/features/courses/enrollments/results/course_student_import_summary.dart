class CourseStudentImportSummary {
  const CourseStudentImportSummary({
    required this.createdStudents,
    required this.linkedExistingStudents,
    required this.alreadyEnrolled,
    required this.invalidRows,
    this.warnings = const [],
    this.errors = const [],
    this.generalError,
  });

  /// New students created in the Students table.
  final int createdStudents;

  /// Existing students linked to the course.
  final int linkedExistingStudents;

  /// Students already enrolled in this course.
  final int alreadyEnrolled;

  /// Invalid spreadsheet rows.
  final int invalidRows;

  final List<String> warnings;

  final List<String> errors;

  final String? generalError;

  bool get success => generalError == null;

  bool get hasWarnings => warnings.isNotEmpty;

  bool get hasErrors => errors.isNotEmpty;

  /// Total students newly enrolled in this import.
  int get enrolledStudents => createdStudents + linkedExistingStudents;
}
