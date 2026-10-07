import 'dart:convert';
import 'dart:typed_data';

import 'package:excel_plus/excel_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/attendance_report.dart';

enum ReportExportFormat { pdf, excel, csv }

class ReportExporter {
  ReportExporter._();

  static final ReportExporter instance = ReportExporter._();

  Future<Uint8List> exportPdf(AttendanceReport report) async {
    final document = pw.Document();

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            _pdfHeader(report),

            pw.SizedBox(height: 20),

            _pdfSummary(report),

            pw.SizedBox(height: 24),

            _pdfSessions(report),

            pw.SizedBox(height: 24),

            _pdfStudents(report),
          ];
        },
      ),
    );

    return document.save();
  }

  Future<Uint8List> exportExcel(AttendanceReport report) async {
    final excel = Excel.createExcel();

    final sheet = excel['Attendance Report'];

    var row = 0;

    _excelText(sheet, row, 0, 'Attendance Report');

    row += 2;

    _excelText(sheet, row, 0, 'Course Code');

    _excelText(sheet, row, 1, report.courseCode ?? '');

    row++;

    _excelText(sheet, row, 0, 'Course Title');

    _excelText(sheet, row, 1, report.courseTitle ?? '');

    row += 2;

    _excelText(sheet, row, 0, 'Students');

    _excelNumber(sheet, row, 1, report.totalStudents);

    row++;

    _excelText(sheet, row, 0, 'Lecture Sessions');

    _excelNumber(sheet, row, 1, report.totalSessions);

    row++;

    _excelText(sheet, row, 0, 'Present');

    _excelNumber(sheet, row, 1, report.totalPresent);

    row++;

    _excelText(sheet, row, 0, 'Absent');

    _excelNumber(sheet, row, 1, report.totalAbsent);

    row++;

    _excelText(sheet, row, 0, 'Attendance');

    _excelText(
      sheet,
      row,
      1,
      '${report.attendancePercentage.toStringAsFixed(1)}%',
    );

    row += 2;

    _excelText(sheet, row, 0, 'Lecture Sessions');

    row++;

    final sessionHeaders = [
      'Session',
      'Week',
      'Date',
      'From',
      'To',
      'Status',
      'Students',
      'Present',
      'Absent',
      'Attendance',
    ];

    for (var column = 0; column < sessionHeaders.length; column++) {
      _excelText(sheet, row, column, sessionHeaders[column]);
    }

    row++;

    for (final session in report.sessions) {
      final values = [
        session.sessionNumber,
        session.weekNumber,
        _formatDate(session.lectureDate),
        session.fromTime,
        session.toTime,
        session.status,
        session.totalStudents,
        session.presentCount,
        session.absentCount,
        '${session.attendancePercentage.toStringAsFixed(1)}%',
      ];

      for (var column = 0; column < values.length; column++) {
        final value = values[column];

        if (value is int) {
          _excelNumber(sheet, row, column, value);
        } else {
          _excelText(sheet, row, column, value.toString());
        }
      }

      row++;
    }

    row += 2;

    _excelText(sheet, row, 0, 'Student Attendance');

    row++;

    final studentHeaders = [
      'Student',
      'Admission Number',
      'Total Sessions',
      'Attended',
      'Missed',
      'Attendance',
    ];

    for (var column = 0; column < studentHeaders.length; column++) {
      _excelText(sheet, row, column, studentHeaders[column]);
    }

    row++;

    for (final student in report.students) {
      final values = [
        student.fullName,
        student.admissionNumber,
        student.totalSessions,
        student.sessionsAttended,
        student.sessionsMissed,
        '${student.attendancePercentage.toStringAsFixed(1)}%',
      ];

      for (var column = 0; column < values.length; column++) {
        final value = values[column];

        if (value is int) {
          _excelNumber(sheet, row, column, value);
        } else {
          _excelText(sheet, row, column, value.toString());
        }
      }

      row++;
    }

    final bytes = excel.save();

    if (bytes == null) {
      throw Exception('Failed to generate Excel report.');
    }

    return Uint8List.fromList(bytes);
  }

  Future<String> exportCsv(AttendanceReport report) async {
    final rows = <List<String>>[];

    rows.add(['Attendance Report']);

    rows.add(['Course Code', report.courseCode ?? '']);

    rows.add(['Course Title', report.courseTitle ?? '']);

    rows.add([]);

    rows.add(['Students', '${report.totalStudents}']);

    rows.add(['Lecture Sessions', '${report.totalSessions}']);

    rows.add(['Present', '${report.totalPresent}']);

    rows.add(['Absent', '${report.totalAbsent}']);

    rows.add([
      'Attendance',
      '${report.attendancePercentage.toStringAsFixed(1)}%',
    ]);

    rows.add([]);

    rows.add(['LECTURE SESSIONS']);

    rows.add([
      'Session',
      'Week',
      'Date',
      'From',
      'To',
      'Status',
      'Students',
      'Present',
      'Absent',
      'Attendance',
    ]);

    for (final session in report.sessions) {
      rows.add([
        '${session.sessionNumber}',
        '${session.weekNumber}',
        _formatDate(session.lectureDate),
        session.fromTime,
        session.toTime,
        session.status,
        '${session.totalStudents}',
        '${session.presentCount}',
        '${session.absentCount}',
        '${session.attendancePercentage.toStringAsFixed(1)}%',
      ]);
    }

    rows.add([]);

    rows.add(['STUDENT ATTENDANCE']);

    rows.add([
      'Student',
      'Admission Number',
      'Total Sessions',
      'Attended',
      'Missed',
      'Attendance',
    ]);

    for (final student in report.students) {
      rows.add([
        student.fullName,
        student.admissionNumber,
        '${student.totalSessions}',
        '${student.sessionsAttended}',
        '${student.sessionsMissed}',
        '${student.attendancePercentage.toStringAsFixed(1)}%',
      ]);
    }

    return rows.map((row) => row.map(_escapeCsv).join(',')).join('\r\n');
  }

  Future<Uint8List> export(
    AttendanceReport report,
    ReportExportFormat format,
  ) async {
    switch (format) {
      case ReportExportFormat.pdf:
        return exportPdf(report);

      case ReportExportFormat.excel:
        return exportExcel(report);

      case ReportExportFormat.csv:
        final csv = await exportCsv(report);

        return Uint8List.fromList(utf8.encode(csv));
    }
  }

  pw.Widget _pdfHeader(AttendanceReport report) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Attendance Report',
          style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          report.courseCode ?? 'Course',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(
          report.courseTitle ?? '',
          style: const pw.TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  pw.Widget _pdfSummary(AttendanceReport report) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        pw.TableRow(
          children: [
            _pdfCell('Students', bold: true),
            _pdfCell('${report.totalStudents}'),
            _pdfCell('Sessions', bold: true),
            _pdfCell('${report.totalSessions}'),
          ],
        ),
        pw.TableRow(
          children: [
            _pdfCell('Present', bold: true),
            _pdfCell('${report.totalPresent}'),
            _pdfCell('Absent', bold: true),
            _pdfCell('${report.totalAbsent}'),
          ],
        ),
        pw.TableRow(
          children: [
            _pdfCell('Attendance', bold: true),
            _pdfCell('${report.attendancePercentage.toStringAsFixed(1)}%'),
            _pdfCell(''),
            _pdfCell(''),
          ],
        ),
      ],
    );
  }

  pw.Widget _pdfSessions(AttendanceReport report) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Lecture Sessions',
          style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          headers: const [
            'Session',
            'Week',
            'Date',
            'Time',
            'Present',
            'Absent',
            'Attendance',
          ],
          data: report.sessions.map((session) {
            return [
              '${session.sessionNumber}',
              '${session.weekNumber}',
              _formatDate(session.lectureDate),
              '${session.fromTime} - ${session.toTime}',
              '${session.presentCount}',
              '${session.absentCount}',
              '${session.attendancePercentage.toStringAsFixed(1)}%',
            ];
          }).toList(),
        ),
      ],
    );
  }

  pw.Widget _pdfStudents(AttendanceReport report) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Student Attendance',
          style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          headers: const [
            'Student',
            'Admission No.',
            'Sessions',
            'Attended',
            'Missed',
            'Attendance',
          ],
          data: report.students.map((student) {
            return [
              student.fullName,
              student.admissionNumber,
              '${student.totalSessions}',
              '${student.sessionsAttended}',
              '${student.sessionsMissed}',
              '${student.attendancePercentage.toStringAsFixed(1)}%',
            ];
          }).toList(),
        ),
      ],
    );
  }

  pw.Widget _pdfCell(String value, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        value,
        style: pw.TextStyle(fontWeight: bold ? pw.FontWeight.bold : null),
      ),
    );
  }

  void _excelText(Sheet sheet, int row, int column, String value) {
    sheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: column, rowIndex: row),
      TextCellValue(value),
    );
  }

  void _excelNumber(Sheet sheet, int row, int column, int value) {
    sheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: column, rowIndex: row),
      IntCellValue(value),
    );
  }

  String _escapeCsv(String value) {
    final escaped = value.replaceAll('"', '""');

    if (escaped.contains(',') ||
        escaped.contains('"') ||
        escaped.contains('\n') ||
        escaped.contains('\r')) {
      return '"$escaped"';
    }

    return escaped;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
