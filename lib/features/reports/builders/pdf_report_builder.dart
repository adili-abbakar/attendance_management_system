import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/attendance_report.dart';

class PdfReportBuilder {
  Future<Uint8List> build(AttendanceReport report) async {
    final document = pw.Document();

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.fromLTRB(28, 28, 28, 28),
        header: (context) => _pageHeader(report, context),
        footer: (context) => _footer(context),
        build: (context) {
          return [
            _reportHeader(report),
            pw.SizedBox(height: 18),

            _summary(report),
            pw.SizedBox(height: 20),

            _sessionSummary(report),
            pw.SizedBox(height: 20),

            _studentAttendance(report),
          ];
        },
      ),
    );

    return document.save();
  }

  // ---------------------------------------------------------------------------
  // Report Header
  // ---------------------------------------------------------------------------

  pw.Widget _reportHeader(AttendanceReport report) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'ATTENDANCE REPORT',
          style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          report.courseCode ?? 'Course',
          style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(
          report.courseTitle ?? '',
          style: const pw.TextStyle(fontSize: 12),
        ),
        pw.SizedBox(height: 12),
        pw.Row(
          children: [
            _metadataItem('Level', report.levelName ?? 'N/A'),
            _metadataItem('Semester', _formatSemester(report.semester)),
            _metadataItem(
              'Academic Session',
              report.academicSessionName ?? 'N/A',
            ),
          ],
        ),
        pw.SizedBox(height: 6),
        pw.Row(
          children: [
            _metadataItem('Report Period', _formatReportPeriod(report)),
            _metadataItem('Generated', _formatDateTime(report.generatedAt)),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Summary
  // ---------------------------------------------------------------------------

  pw.Widget _summary(AttendanceReport report) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('SUMMARY'),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400),
          columnWidths: const {
            0: pw.FlexColumnWidth(1.5),
            1: pw.FlexColumnWidth(1),
            2: pw.FlexColumnWidth(1.5),
            3: pw.FlexColumnWidth(1),
            4: pw.FlexColumnWidth(1.8),
            5: pw.FlexColumnWidth(1),
          },
          children: [
            pw.TableRow(
              children: [
                _cell('Total Students', bold: true),
                _cell('${report.totalStudents}'),
                _cell('Total Sessions', bold: true),
                _cell('${report.totalSessions}'),
                _cell('Overall Attendance', bold: true),
                _cell(_percentage(report.attendancePercentage)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Session Summary
  // ---------------------------------------------------------------------------

  pw.Widget _sessionSummary(AttendanceReport report) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('LECTURE SESSION SUMMARY'),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          headers: const [
            'Session',
            'Week',
            'Date',
            'Time',
            'Status',
            'Students',
            'Present',
            'Absent',
            'Attendance',
          ],
          data: report.sessions.map((session) {
            return [
              'S${session.sessionNumber}',
              '${session.weekNumber}',
              _formatDate(session.lectureDate),
              '${session.fromTime} - ${session.toTime}',
              session.status,
              '${session.totalStudents}',
              '${session.presentCount}',
              '${session.absentCount}',
              _percentage(session.attendancePercentage),
            ];
          }).toList(),
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 9,
          ),
          cellStyle: const pw.TextStyle(fontSize: 8),
          cellPadding: const pw.EdgeInsets.all(5),
          border: pw.TableBorder.all(color: PdfColors.grey400),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Student Attendance
  // ---------------------------------------------------------------------------

  pw.Widget _studentAttendance(AttendanceReport report) {
    final headers = <String>[
      '#',
      'Admission No.',
      ...report.sessions.map(
        (session) =>
            'S${session.sessionNumber}\n'
            '${_formatShortDate(session.lectureDate)}',
      ),
      'Present',
      'Absent',
      '%',
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('STUDENT ATTENDANCE'),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          headers: headers,
          data: _buildStudentRows(report),
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 7,
          ),
          cellStyle: const pw.TextStyle(fontSize: 7),
          cellPadding: const pw.EdgeInsets.all(3),
          border: pw.TableBorder.all(color: PdfColors.grey400),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
        ),
      ],
    );
  }

  List<List<String>> _buildStudentRows(AttendanceReport report) {
    final rows = <List<String>>[];

    for (var index = 0; index < report.students.length; index++) {
      final student = report.students[index];

      final attendanceBySession = {
        for (final attendance in student.sessionAttendance)
          attendance.lectureSessionId: attendance,
      };

      final row = <String>['${index + 1}', student.admissionNumber];

      for (final session in report.sessions) {
        final attendance = attendanceBySession[session.lectureSessionId];

        if (attendance == null) {
          row.add('-');
        } else if (attendance.present) {
          row.add('P');
        } else {
          row.add('A');
        }
      }

      row.add('${student.sessionsAttended}');

      row.add('${student.sessionsMissed}');

      row.add(_percentage(student.attendancePercentage));

      rows.add(row);
    }

    return rows;
  }

  // ---------------------------------------------------------------------------
  // Page Header / Footer
  // ---------------------------------------------------------------------------

  pw.Widget _pageHeader(AttendanceReport report, pw.Context context) {
    if (context.pageNumber == 1) {
      return pw.SizedBox();
    }

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          '${report.courseCode ?? ''} - Attendance Report',
          style: const pw.TextStyle(fontSize: 8),
        ),
        pw.Text(
          'Page ${context.pageNumber}',
          style: const pw.TextStyle(fontSize: 8),
        ),
      ],
    );
  }

  pw.Widget _footer(pw.Context context) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Text(
        'Generated by Attendance Management System',
        style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PDF Helpers
  // ---------------------------------------------------------------------------

  pw.Widget _sectionTitle(String title) {
    return pw.Text(
      title,
      style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
    );
  }

  pw.Widget _metadataItem(String label, String value) {
    return pw.Expanded(
      child: pw.Row(
        children: [
          pw.Text(
            '$label: ',
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          ),
          pw.Expanded(
            child: pw.Text(value, style: const pw.TextStyle(fontSize: 9)),
          ),
        ],
      ),
    );
  }

  pw.Widget _cell(String value, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        value,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: bold ? pw.FontWeight.bold : null,
        ),
      ),
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
