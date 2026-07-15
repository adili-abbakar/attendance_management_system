class RegisterResult {
  final bool success;
  final String? emailError;
  final String? staffIdError;
  final int? userId;

  const RegisterResult({
    required this.success,
    this.emailError,
    this.staffIdError,
    this.userId,
  });
}
