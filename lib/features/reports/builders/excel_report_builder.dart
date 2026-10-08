import 'dart:typed_data';

import 'package:excel_plus/excel_plus.dart';

import '../models/attendance_report.dart';

class ExcelReportBuilder {
  Future<Uint8List> build(AttendanceReport report) async {
    final excel = Excel.createExcel();

    // Use the default sheet.
    //
    // Do NOT create another sheet. Excel.createExcel()
    // already creates Sheet1.
    final sheet = excel['Sheet1'];

    var row = 0;

    row = _reportHeader(sheet, report, row);

    row += 2;

    row = _sessionSummary(sheet, report, row);

    row += 2;

    _studentAttendance(sheet, report, row);

    final bytes = excel.save();

    if (bytes == null) {
      throw Exception('Failed to generate Excel report.');
    }

    return Uint8List.fromList(bytes);
  }

  // ---------------------------------------------------------------------------
  // Report Header
  // ---------------------------------------------------------------------------

  int _reportHeader(Sheet sheet, AttendanceReport report, int row) {
    _text(sheet, row, 0, 'ATTENDANCE REPORT');

    row += 2;

    _text(sheet, row, 0, 'Course Code');
    _text(sheet, row, 1, report.courseCode ?? '');

    row++;

    _text(sheet, row, 0, 'Course Title');
    _text(sheet, row, 1, report.courseTitle ?? '');

    row++;

    _text(sheet, row, 0, 'Level');
    _text(sheet, row, 1, report.levelName ?? '');

    row++;

    _text(sheet, row, 0, 'Semester');
    _text(sheet, row, 1, _formatSemester(report.semester));

    row++;

    _text(sheet, row, 0, 'Academic Session');
    _text(sheet, row, 1, report.academicSessionName ?? '');

    row++;

    _text(sheet, row, 0, 'Report Period');
    _text(sheet, row, 1, _formatReportPeriod(report));

    row++;

    _text(sheet, row, 0, 'Generated');
    _text(sheet, row, 1, _formatDateTime(report.generatedAt));

    row += 2;

    _text(sheet, row, 0, 'SUMMARY');

    row++;

    _text(sheet, row, 0, 'Total Students');
    _number(sheet, row, 1, report.totalStudents);

    row++;

    _text(sheet, row, 0, 'Total Sessions');
    _number(sheet, row, 1, report.totalSessions);

    row++;

    _text(sheet, row, 0, 'Overall Attendance');
    _text(sheet, row, 1, _percentage(report.attendancePercentage));

    return row;
  }

  // ---------------------------------------------------------------------------
  // Session Summary
  // ---------------------------------------------------------------------------

  int _sessionSummary(Sheet sheet, AttendanceReport report, int row) {
    _text(sheet, row, 0, 'LECTURE SESSION SUMMARY');

    row++;

    final headers = [
      'Session',
      'Week',
      'Date',
      'Time',
      'Status',
      'Students',
      'Present',
      'Absent',
      'Attendance',
    ];

    for (var column = 0; column < headers.length; column++) {
      _text(sheet, row, column, headers[column]);
    }

    row++;

    for (final session in report.sessions) {
      final values = [
        'S${session.sessionNumber}',
        session.weekNumber,
        _formatDate(session.lectureDate),
        '${session.fromTime} - ${session.toTime}',
        session.status,
        session.totalStudents,
        session.presentCount,
        session.absentCount,
        _percentage(session.attendancePercentage),
      ];

      for (var column = 0; column < values.length; column++) {
        final value = values[column];

        if (value is int) {
          _number(sheet, row, column, value);
        } else {
          _text(sheet, row, column, value.toString());
        }
      }

      row++;
    }

    return row;
  }

  // ---------------------------------------------------------------------------
  // Student Attendance
  // ---------------------------------------------------------------------------

  void _studentAttendance(Sheet sheet, AttendanceReport report, int row) {
    _text(sheet, row, 0, 'STUDENT ATTENDANCE');

    row++;

    final headers = [
      '#',
      'Admission Number',
      'Student Name',
      ...report.sessions.map(
        (session) =>
            'S${session.sessionNumber}\n'
            '${_formatShortDate(session.lectureDate)}',
      ),
      'Present',
      'Absent',
      'Attendance',
    ];

    for (var column = 0; column < headers.length; column++) {
      _text(sheet, row, column, headers[column]);
    }

    row++;

    for (var index = 0; index < report.students.length; index++) {
      final student = report.students[index];

      final attendanceBySession = {
        for (final attendance in student.sessionAttendance)
          attendance.lectureSessionId: attendance,
      };

      final values = <Object>[
        index + 1,
        student.admissionNumber,
        student.fullName,
        ...report.sessions.map((session) {
          final attendance = attendanceBySession[session.lectureSessionId];

          if (attendance == null) {
            return '-';
          }

          return attendance.present ? 'P' : 'A';
        }),
        student.sessionsAttended,
        student.sessionsMissed,
        _percentage(student.attendancePercentage),
      ];

      for (var column = 0; column < values.length; column++) {
        final value = values[column];

        if (value is int) {
          _number(sheet, row, column, value);
        } else {
          _text(sheet, row, column, value.toString());
        }
      }

      row++;
    }
  }

  // ---------------------------------------------------------------------------
  // Cell Helpers
  // ---------------------------------------------------------------------------

  void _text(Sheet sheet, int row, int column, String value) {
    sheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: column, rowIndex: row),
      TextCellValue(value),
    );
  }

  void _number(Sheet sheet, int row, int column, int value) {
    sheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: column, rowIndex: row),
      IntCellValue(value),
    );
  }

  // ---------------------------------------------------------------------------
  // Formatting
  // ---------------------------------------------------------------------------

  String _percentage(double value) {
    return '${value.toStringAsFixed(1)}%';
  }

  String _formatSemester(int? semester) {
    switch (semester) {
      case 1:
        return 'First Semester';
      case 2:
        return 'Second Semester';
      default:
        return 'N/A';
    }
  }

  String _formatReportPeriod(AttendanceReport report) {
    if (report.startDate == null && report.endDate == null) {
      return 'All Sessions';
    }

    if (report.startDate != null && report.endDate != null) {
      return '${_formatDate(report.startDate!)} - '
          '${_formatDate(report.endDate!)}';
    }

    if (report.startDate != null) {
      return 'From ${_formatDate(report.startDate!)}';
    }

    return 'Until ${_formatDate(report.endDate!)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatShortDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
