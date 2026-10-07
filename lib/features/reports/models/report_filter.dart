import 'package:flutter/foundation.dart';

enum ReportType { course, lectureSession, student }

enum ReportDateRange { all, today, thisWeek, thisMonth, custom }

@immutable
class ReportFilter {
  final ReportType reportType;
  final int? courseId;
  final int? lectureSessionId;
  final int? studentId;

  final ReportDateRange dateRange;
  final DateTime? startDate;
  final DateTime? endDate;

  const ReportFilter({
    this.reportType = ReportType.course,
    this.courseId,
    this.lectureSessionId,
    this.studentId,
    this.dateRange = ReportDateRange.all,
    this.startDate,
    this.endDate,
  });

  ReportFilter copyWith({
    ReportType? reportType,
    int? courseId,
    bool clearCourseId = false,
    int? lectureSessionId,
    bool clearLectureSessionId = false,
    int? studentId,
    bool clearStudentId = false,
    ReportDateRange? dateRange,
    DateTime? startDate,
    bool clearStartDate = false,
    DateTime? endDate,
    bool clearEndDate = false,
  }) {
    return ReportFilter(
      reportType: reportType ?? this.reportType,
      courseId: clearCourseId ? null : (courseId ?? this.courseId),
      lectureSessionId: clearLectureSessionId
          ? null
          : (lectureSessionId ?? this.lectureSessionId),
      studentId: clearStudentId ? null : (studentId ?? this.studentId),
      dateRange: dateRange ?? this.dateRange,
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
    );
  }

  bool get hasDateFilter => dateRange != ReportDateRange.all;

  bool get hasCustomDateRange =>
      dateRange == ReportDateRange.custom &&
      startDate != null &&
      endDate != null;

  @override
  bool operator ==(Object other) {
    return other is ReportFilter &&
        other.reportType == reportType &&
        other.courseId == courseId &&
        other.lectureSessionId == lectureSessionId &&
        other.studentId == studentId &&
        other.dateRange == dateRange &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode => Object.hash(
    reportType,
    courseId,
    lectureSessionId,
    studentId,
    dateRange,
    startDate,
    endDate,
  );
}
