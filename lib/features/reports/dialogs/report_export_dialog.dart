import 'package:flutter/material.dart';

import '../models/attendance_report.dart';
import '../services/report_exporter.dart';

class ReportExportDialog extends StatelessWidget {
  final AttendanceReport report;

  const ReportExportDialog({super.key, required this.report});

  static Future<ReportExportFormat?> show(
    BuildContext context, {
    required AttendanceReport report,
  }) {
    return showDialog<ReportExportFormat>(
      context: context,
      builder: (_) => ReportExportDialog(report: report),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Export Report'),
      content: const Text('Choose the format for your attendance report.'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, ReportExportFormat.pdf);
          },
          child: const Text('PDF'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context, ReportExportFormat.excel);
          },
          child: const Text('Excel'),
        ),
      ],
    );
  }
}
