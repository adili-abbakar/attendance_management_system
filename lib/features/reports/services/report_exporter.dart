import 'dart:typed_data';

import '../builders/excel_report_builder.dart';
import '../models/attendance_report.dart';

class ReportExporter {
  ReportExporter._();

  static final ReportExporter instance = ReportExporter._();

  final ExcelReportBuilder _excelBuilder = ExcelReportBuilder();

  Future<Uint8List> exportExcel(AttendanceReport report) {
    return _excelBuilder.build(report);
  }
}
