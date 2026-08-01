import 'dart:io';

import 'package:attendance_management_system/features/qr/enums/qr_export_option.dart';
import 'package:attendance_management_system/features/qr/pdf/services/qr_pdf_service.dart';
import 'package:attendance_management_system/features/qr/results/qr_export_result.dart';
import 'package:attendance_management_system/features/students/models/student.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

class QrExportProvider extends ChangeNotifier {
  QrExportProvider({required this.pdfService});

  final QrPdfService pdfService;

  bool _isLoading = false;
  String? _errorMessage;

  /// Stores only student IDs.
  final Set<int> _selectedStudentIds = {};

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get hasSelection => _selectedStudentIds.isNotEmpty;

  int get selectedCount => _selectedStudentIds.length;

  Set<int> get selectedStudentIds => Set.unmodifiable(_selectedStudentIds);

  bool isSelected(Student student) {
    return student.id != null && _selectedStudentIds.contains(student.id);
  }

  void toggleStudent(Student student) {
    if (student.id == null) return;

    if (_selectedStudentIds.contains(student.id)) {
      _selectedStudentIds.remove(student.id);
    } else {
      _selectedStudentIds.add(student.id!);
    }

    notifyListeners();
  }

  void selectStudent(Student student) {
    if (student.id == null) return;

    if (_selectedStudentIds.add(student.id!)) {
      notifyListeners();
    }
  }

  void unselectStudent(Student student) {
    if (student.id == null) return;

    if (_selectedStudentIds.remove(student.id)) {
      notifyListeners();
    }
  }

  void selectAll(List<Student> students) {
    _selectedStudentIds
      ..clear()
      ..addAll(
        students
            .where((student) => student.id != null)
            .map((student) => student.id!),
      );

    notifyListeners();
  }

  void clearSelection() {
    _selectedStudentIds.clear();
    notifyListeners();
  }

  void toggleAll(List<Student> students) {
    final ids = students
        .where((student) => student.id != null)
        .map((student) => student.id!)
        .toSet();

    if (_selectedStudentIds.length == ids.length &&
        _selectedStudentIds.containsAll(ids)) {
      _selectedStudentIds.clear();
    } else {
      _selectedStudentIds
        ..clear()
        ..addAll(ids);
    }

    notifyListeners();
  }

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
