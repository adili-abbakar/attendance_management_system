import 'dart:io';
import 'dart:typed_data';

import 'package:attendance_management_system/features/qr/enums/qr_export_option.dart';
import 'package:attendance_management_system/features/qr/pdf/pdf.dart';
import 'package:attendance_management_system/features/qr/zip/zip.dart';
import 'package:attendance_management_system/features/qr/results/qr_export_result.dart';
import 'package:attendance_management_system/features/students/models/student.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:attendance_management_system/features/qr/png/png.dart';

class QrExportProvider extends ChangeNotifier {
  QrExportProvider({
    required this.pdfService,
    required this.pngService,
    required this.zipService,
  });

  final QrPdfService pdfService;
  final QrPngService pngService;
  final QrZipService zipService;
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
    GlobalKey? repaintKey,
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

          await File(location.path).writeAsBytes(bytes);

          return QrExportResult.success(exportedCount: students.length);

        case QrExportOption.png:
          if (students.length != 1) {
            return QrExportResult.failure(
              message: 'PNG export currently supports one student only.',
            );
          }

          if (repaintKey == null) {
            return QrExportResult.failure(
              message: 'Unable to capture QR card.',
            );
          }

          final bytes = await pngService.generate(repaintKey: repaintKey);

          final location = await getSaveLocation(
            suggestedName: '${students.first.admissionNumber}.png',
          );

          if (location == null) {
            return QrExportResult.failure(message: 'Export cancelled.');
          }

          await File(location.path).writeAsBytes(bytes);

          return QrExportResult.success(exportedCount: 1);

        case QrExportOption.zipPng:
          return QrExportResult.failure(
            message: 'ZIP PNG export is not implemented yet.',
          );

        case QrExportOption.zipPdf:
          final files = <String, Uint8List>{};

          for (final student in students) {
            files['${student.admissionNumber}.pdf'] = await pdfService
                .generateSingle(student: student);
          }

          final zipBytes = await zipService.generate(files: files);

          final location = await getSaveLocation(
            suggestedName: 'attendance_qr_cards.zip',
          );

          if (location == null) {
            return QrExportResult.failure(message: 'Export cancelled.');
          }

          await File(location.path).writeAsBytes(zipBytes);

          return QrExportResult.success(exportedCount: students.length);
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
