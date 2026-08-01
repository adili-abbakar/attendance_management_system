import 'dart:io';

import 'package:attendance_management_system/features/qr/enums/qr_export_option.dart';
import 'package:attendance_management_system/features/qr/pdf/services/qr_pdf_service.dart';
import 'package:attendance_management_system/features/qr/results/qr_export_result.dart';
import 'package:attendance_management_system/features/students/models/student.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

class QrExportProvider extends ChangeNotifier {
  QrExportProvider({required this.pdfService});

  final QrPdfService pdfService;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  Future<QrExportResult> export({
    required List<Student> students,
    required QrExportOption option,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      switch (option) {
        case QrExportOption.pdf:
          final bytes = await pdfService.generate(students: students);
          final fileName = students.length == 1
              ? '${students.first.admissionNumber}.pdf'
              : 'attendance_qr_cards.pdf';

          final location = await getSaveLocation(suggestedName: fileName);

          if (location == null) {
            return QrExportResult.failure(message: 'Export cancelled.');
          }

          final file = File(location.path);

          await file.writeAsBytes(bytes);
          return QrExportResult.success(exportedCount: students.length);

        case QrExportOption.png:
        case QrExportOption.zipPng:
        case QrExportOption.zipPdf:
          return QrExportResult.failure(
            message: 'This export option has not been implemented yet.',
          );
      }
    } catch (e) {
      _errorMessage = e.toString();

      return QrExportResult.failure(message: _errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
