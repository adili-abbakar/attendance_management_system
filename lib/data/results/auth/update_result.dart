class UpdateResult {
  final bool success;
  final String? emailError;
  final String? staffIdError;

  const UpdateResult({
    required this.success,
    this.emailError,
    this.staffIdError,
  });
}
