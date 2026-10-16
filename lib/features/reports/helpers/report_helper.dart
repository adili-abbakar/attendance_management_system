import '../models/attendance_report.dart';

class ReportHelper {
  const ReportHelper._();

  static bool hasReport(AttendanceReport report) {
    return report.courseId != null ||
        report.totalStudents > 0 ||
        report.totalSessions > 0;
  }

  static String buildFileName(AttendanceReport report) {
    final courseCode = _sanitizeFileName(
      report.courseCode ?? 'COURSE',
      fallback: 'COURSE',
    );

    final academicSession = _sanitizeFileName(
      report.academicSessionName ?? '',
      fallback: 'Academic_Session',
    );

    return '${courseCode}_${academicSession}_Attendance_Report.xlsx';
  }

  static String _sanitizeFileName(String value, {required String fallback}) {
    final sanitized = value
        .trim()
        .replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'_+'), '_');

    return sanitized.isEmpty ? fallback : sanitized;
  }
}
