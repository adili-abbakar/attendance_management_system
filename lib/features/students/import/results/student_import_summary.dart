class StudentImportSummary {
  const StudentImportSummary({
    required this.importedCount,
    required this.skippedCount,
    this.warnings = const [],
    this.errors = const [],
    this.generalError,
  });

  final int importedCount;
  final int skippedCount;
  final List<String> warnings;
  final List<String> errors;
  final String? generalError;
  bool get success => generalError == null;
  bool get hasWarnings => warnings.isNotEmpty;
  bool get hasErrors => errors.isNotEmpty;
  bool get hasSkipped => skippedCount > 0;
}
