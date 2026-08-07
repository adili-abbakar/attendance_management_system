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

  final int createdStudents;
  final int linkedExistingStudents;
  final int alreadyEnrolled;
  final int invalidRows;
  final List<String> warnings;
  final List<String> errors;
  final String? generalError;

  bool get success => generalError == null;
  bool get hasWarnings => warnings.isNotEmpty;
  bool get hasErrors => errors.isNotEmpty;
  int get enrolledStudents => createdStudents + linkedExistingStudents;
}
