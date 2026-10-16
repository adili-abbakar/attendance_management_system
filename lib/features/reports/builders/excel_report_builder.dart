import 'dart:typed_data';

import 'package:excel_plus/excel_plus.dart';

import '../models/attendance_report.dart';

class ExcelReportBuilder {
  static const _worksheetName = 'Sheet1';
  static const _overviewSummaryRow = 9;
  static const _sessionDetailsStartRow = 15;
  static const _studentAttendanceStartOffset = 3;
  static const _sessionDataRowOffset = 2;

  static const _serialNumberColumn = 0;
  static const _admissionNumberColumn = 1;
  static const _studentNameColumn = 2;
  static const _sessionColumnsStart = 3;

  static const _markedValue = '✓';
  static const _cancelledValue = '✕';
  static const _unrecordedValue = '-';
  static const _leftAlignment = HorizontalAlign.Left;
  static const _centerAlignment = HorizontalAlign.Center;

  static const _sessionHeaders = <String>[
    'Session',
    'Week',
    'Date',
    'Start Time',
    'End Time',
    'Duration (Minutes)',
    'Status',
    'Total Students',
    'Present',
    'Absent',
    'Attendance (%)',
  ];
  static const _sessionHeaderAlignments = <HorizontalAlign>[
    _centerAlignment,
    _centerAlignment,
    _centerAlignment,
    _centerAlignment,
    _centerAlignment,
    _centerAlignment,
    _leftAlignment,
    _centerAlignment,
    _centerAlignment,
    _centerAlignment,
    _centerAlignment,
  ];

  Future<Uint8List> build(AttendanceReport report) async {
    final excel = Excel.createExcel();
    final sheet = excel[_worksheetName];

    _addOverview(sheet, report);
    _addSessionDetails(sheet, report);
    _addStudentAttendance(sheet, report);

    final bytes = excel.save();

    if (bytes == null || bytes.isEmpty) {
      throw Exception('Failed to generate the Excel attendance report.');
    }

    return Uint8List.fromList(bytes);
  }

  void _addOverview(Sheet sheet, AttendanceReport report) {
    _write(sheet, 0, 0, 'LECTURE ATTENDANCE REPORT');
    _write(sheet, 1, 0, 'Course Code');
    _write(sheet, 1, 1, report.courseCode ?? 'N/A');

    _write(sheet, 2, 0, 'Course Title');
    _write(sheet, 2, 1, report.courseTitle ?? 'N/A');

    _write(sheet, 3, 0, 'Level');
    _write(sheet, 3, 1, report.levelName ?? 'N/A');

    _write(sheet, 4, 0, 'Academic Session');
    _write(sheet, 4, 1, report.academicSessionName ?? 'N/A');

    _write(sheet, 5, 0, 'Semester');
    _write(sheet, 5, 1, report.semester ?? 'N/A', alignment: _centerAlignment);

    _write(sheet, 6, 0, 'Reporting Period');
    _write(sheet, 6, 1, _getReportPeriod(report), alignment: _centerAlignment);

    _write(sheet, 7, 0, 'Generated On');
    _write(
      sheet,
      7,
      1,
      _formatDate(report.generatedAt),
      alignment: _centerAlignment,
    );

    _write(sheet, _overviewSummaryRow, 0, 'ATTENDANCE SUMMARY');
    _write(sheet, _overviewSummaryRow + 1, 0, 'Total Students');
    _write(sheet, _overviewSummaryRow + 1, 1, report.totalStudents);

    _write(sheet, _overviewSummaryRow + 2, 0, 'Total Lecture Sessions');
    _write(sheet, _overviewSummaryRow + 2, 1, report.totalSessions);

    _write(sheet, _overviewSummaryRow + 3, 0, 'Overall Attendance');
    _write(
      sheet,
      _overviewSummaryRow + 3,
      1,
      '${report.attendancePercentage.toStringAsFixed(1)}%',
      alignment: _centerAlignment,
    );
  }

  void _addSessionDetails(Sheet sheet, AttendanceReport report) {
    final startRow = _sessionDetailsStartRow;

    _write(sheet, startRow, 0, 'LECTURE SESSION DETAILS');

    for (var column = 0; column < _sessionHeaders.length; column++) {
      _write(
        sheet,
        startRow + 1,
        column,
        _sessionHeaders[column],
        alignment: _sessionHeaderAlignments[column],
      );
    }

    if (report.sessions.isEmpty) {
      _write(sheet, startRow + 2, 0, 'No lecture sessions found.');
      return;
    }

    for (var index = 0; index < report.sessions.length; index++) {
      final session = report.sessions[index];
      final row = startRow + _sessionDataRowOffset + index;

      _write(
        sheet,
        row,
        0,
        'Lecture Session ${session.sessionNumber}',
        alignment: _centerAlignment,
      );
      _write(sheet, row, 1, session.weekNumber);
      _write(
        sheet,
        row,
        2,
        _formatDate(session.lectureDate),
        alignment: _centerAlignment,
      );
      _write(sheet, row, 3, session.fromTime, alignment: _centerAlignment);
      _write(sheet, row, 4, session.toTime, alignment: _centerAlignment);
      _write(sheet, row, 5, session.durationMinutes);
      _write(sheet, row, 6, session.status);
      _write(sheet, row, 7, session.totalStudents);
      _write(sheet, row, 8, session.presentCount);
      _write(sheet, row, 9, session.absentCount);
      _write(
        sheet,
        row,
        10,
        '${session.attendancePercentage.toStringAsFixed(1)}%',
        alignment: _centerAlignment,
      );
    }
  }

  void _addStudentAttendance(Sheet sheet, AttendanceReport report) {
    final startRow =
        _sessionDetailsStartRow +
        _studentAttendanceStartOffset +
        report.sessions.length;

    _write(sheet, startRow, 0, 'STUDENT ATTENDANCE DETAILS');

    final headers = <String>[
      'S/N',
      'Admission Number',
      'Student Name',
      ...report.sessions.map(
        (session) =>
            'Session ${session.sessionNumber} '
            '(${_formatShortDate(session.lectureDate)})',
      ),
      'Attended',
      'Missed',
      'Attendance (%)',
    ];

    for (var column = 0; column < headers.length; column++) {
      final isTextColumn =
          column == _admissionNumberColumn || column == _studentNameColumn;
      _write(
        sheet,
        startRow + 1,
        column,
        headers[column],
        alignment: isTextColumn ? _leftAlignment : _centerAlignment,
      );
    }

    if (report.students.isEmpty) {
      _write(sheet, startRow + 2, 0, 'No students found.');
      return;
    }

    for (var index = 0; index < report.students.length; index++) {
      final student = report.students[index];
      final row = startRow + _sessionDataRowOffset + index;

      _write(sheet, row, _serialNumberColumn, index + 1);
      _write(sheet, row, _admissionNumberColumn, student.admissionNumber);
      _write(sheet, row, _studentNameColumn, student.fullName);

      final attendanceBySession = {
        for (final attendance in student.sessionAttendance)
          attendance.lectureSessionId: attendance,
      };

      for (
        var sessionIndex = 0;
        sessionIndex < report.sessions.length;
        sessionIndex++
      ) {
        final session = report.sessions[sessionIndex];
        final attendance = attendanceBySession[session.lectureSessionId];
        final mark = attendance == null
            ? _unrecordedValue
            : attendance.present
            ? _markedValue
            : _cancelledValue;

        _write(
          sheet,
          row,
          _sessionColumnsStart + sessionIndex,
          mark,
          alignment: _centerAlignment,
        );
      }

      final summaryColumn = _sessionColumnsStart + report.sessions.length;

      _write(sheet, row, summaryColumn, student.sessionsAttended);
      _write(sheet, row, summaryColumn + 1, student.sessionsMissed);
      _write(
        sheet,
        row,
        summaryColumn + 2,
        '${student.attendancePercentage.toStringAsFixed(1)}%',
        alignment: _centerAlignment,
      );
    }
  }

  void _write(
    Sheet sheet,
    int row,
    int column,
    Object value, {
    HorizontalAlign? alignment,
  }) {
    final cell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: column, rowIndex: row),
    );

    if (value is int) {
      cell.value = IntCellValue(value);
    } else if (value is num) {
      cell.value = DoubleCellValue(value.toDouble());
    } else {
      cell.value = TextCellValue(_sanitizeXmlText(value.toString()));
    }

    cell.cellStyle = CellStyle(
      horizontalAlign:
          alignment ?? (value is num ? _centerAlignment : _leftAlignment),
    );
  }

  String _sanitizeXmlText(String value) {
    return value.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]'), '');
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  String _formatShortDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month';
  }

  String _getReportPeriod(AttendanceReport report) {
    final start = report.startDate;
    final end = report.endDate;

    if (start != null && end != null) {
      return '${_formatDate(start)} - ${_formatDate(end)}';
    }

    if (start != null) {
      return 'From ${_formatDate(start)}';
    }

    if (end != null) {
      return 'Until ${_formatDate(end)}';
    }

    if (report.sessions.isEmpty) {
      return 'No lecture sessions';
    }

    final dates = report.sessions.map((session) => session.lectureDate).toList()
      ..sort();

    return '${_formatDate(dates.first)} - ${_formatDate(dates.last)}';
  }
}
