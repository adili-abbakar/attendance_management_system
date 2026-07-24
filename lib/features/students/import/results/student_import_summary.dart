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

  /// Non-fatal issues.
  /// Example:
  /// ADM001 already exists.
  final List<String> warnings;

  /// Validation issues.
  /// Example:
  /// Row 10 - Missing name.
  final List<String> errors;

  final String? generalError;

  bool get success => generalError == null;

  bool get hasWarnings => warnings.isNotEmpty;

  bool get hasErrors => errors.isNotEmpty;

  bool get hasSkipped => skippedCount > 0;
}
