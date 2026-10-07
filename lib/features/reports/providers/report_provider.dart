import 'package:flutter/foundation.dart';

import '../models/attendance_report.dart';
import '../models/report_filter.dart';
import '../services/report_service.dart';

class ReportProvider extends ChangeNotifier {
  ReportProvider(instance, {ReportService? reportService})
    : _reportService = reportService ?? ReportService.instance;

  final ReportService _reportService;

  ReportFilter _filter = const ReportFilter();

  AttendanceReport _report = AttendanceReport.empty();

  List<AttendanceStudentRow> _lectureSessionAttendance = [];

  bool _isLoading = false;
  bool _isLoadingSessionAttendance = false;

  String? _errorMessage;

  ReportFilter get filter => _filter;

  AttendanceReport get report => _report;

  List<AttendanceStudentRow> get lectureSessionAttendance =>
      List.unmodifiable(_lectureSessionAttendance);

  bool get isLoading => _isLoading;

  bool get isLoadingSessionAttendance => _isLoadingSessionAttendance;

  String? get errorMessage => _errorMessage;

  bool get hasReport => _report.courseId != null;

  bool get hasLectureSessionAttendance => _lectureSessionAttendance.isNotEmpty;

  Future<void> generateCourseReport({
    required int courseId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _isLoading = true;
    _errorMessage = null;

    _filter = _filter.copyWith(
      reportType: ReportType.course,
      courseId: courseId,
      clearLectureSessionId: true,
      clearStudentId: true,
      dateRange: startDate == null && endDate == null
          ? ReportDateRange.all
          : ReportDateRange.custom,
      startDate: startDate,
      endDate: endDate,
    );

    notifyListeners();

    try {
      _report = await _reportService.generateCourseReport(
        courseId: courseId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (error) {
      _errorMessage = error.toString();
      _report = AttendanceReport.empty();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadLectureSessionAttendance({
    required int lectureSessionId,
  }) async {
    _isLoadingSessionAttendance = true;
    _errorMessage = null;

    _filter = _filter.copyWith(
      reportType: ReportType.lectureSession,
      lectureSessionId: lectureSessionId,
      clearCourseId: true,
      clearStudentId: true,
    );

    notifyListeners();

    try {
      _lectureSessionAttendance = await _reportService
          .getLectureSessionAttendance(lectureSessionId: lectureSessionId);
    } catch (error) {
      _errorMessage = error.toString();
      _lectureSessionAttendance = [];
    } finally {
      _isLoadingSessionAttendance = false;
      notifyListeners();
    }
  }

  void setFilter(ReportFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  void clearReport() {
    _report = AttendanceReport.empty();

    _lectureSessionAttendance = [];

    _errorMessage = null;

    _filter = const ReportFilter();

    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
