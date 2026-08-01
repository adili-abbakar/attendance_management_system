class QrExportResult {
  const QrExportResult({
    required this.success,
    this.exportedCount = 0,
    this.message,
  });

  final bool success;

  final int exportedCount;

  final String? message;

  bool get failed => !success;

  factory QrExportResult.success({
    required int exportedCount,
    String? message,
  }) {
    return QrExportResult(
      success: true,
      exportedCount: exportedCount,
      message: message,
    );
  }

  factory QrExportResult.failure({String? message}) {
    return QrExportResult(success: false, message: message);
  }
}
