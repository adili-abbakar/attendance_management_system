import 'dart:typed_data';

import '../models/attendance_report.dart';
import '../builders/excel_report_builder.dart';
import '../builders/pdf_report_builder.dart';

enum ReportExportFormat { pdf, excel }

class ReportExporter {
  ReportExporter._();

  static final ReportExporter instance = ReportExporter._();

  final PdfReportBuilder _pdfBuilder = PdfReportBuilder();
  final ExcelReportBuilder _excelBuilder = ExcelReportBuilder();

  Future<Uint8List> export(AttendanceReport report, ReportExportFormat format) {
    switch (format) {
      case ReportExportFormat.pdf:
        return _pdfBuilder.build(report);

      case ReportExportFormat.excel:
        return _excelBuilder.build(report);
    }
  }
}
