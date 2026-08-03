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
import 'package:screenshot/screenshot.dart';

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

  int _progress = 0;
  int _total = 0;
  String _progressMessage = '';

  int get progress => _progress;
  int get total => _total;
  String get progressMessage => _progressMessage;

  double get progressValue => _total == 0 ? 0 : _progress / _total;

  void _updateProgress({
    required int current,
    required int total,
    required String message,
  }) {
    _progress = current;
    _total = total;
    _progressMessage = message;

    if (_progress > _total) {
      _progress = _total;
    }

    notifyListeners();
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
    if (_isLoading) {
      return QrExportResult.failure(
        message: 'Another export is already in progress.',
      );
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      switch (option) {
        case QrExportOption.printPdf:
          return QrExportResult.failure(
            message: 'Use printStudents() for printing.',
          );
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
          final controller = ScreenshotController();

          final files = <String, Uint8List>{};

          _updateProgress(
            current: 0,
            total: students.length,
            message: 'Preparing PNGs...',
          );

          for (int i = 0; i < students.length; i++) {
            final student = students[i];

            _updateProgress(
              current: i + 1,
              total: students.length,
              message: 'Generating PNG ${i + 1} of ${students.length}',
            );

            final bytes = await controller.captureFromWidget(
              PngStudentQrCard(
                fullName: student.fullName,
                admissionNumber: student.admissionNumber,
              ),
              pixelRatio: 2, // Faster for bulk export
            );

            files['${student.admissionNumber}.png'] = bytes;
          }

          _updateProgress(
            current: students.length,
            total: students.length,
            message: 'Creating ZIP archive...',
          );

          final zipBytes = await zipService.generate(files: files);

          final location = await getSaveLocation(
            suggestedName: 'attendance_qr_cards.zip',
          );

          if (location == null) {
            return QrExportResult.failure(message: 'Export cancelled.');
          }

          _updateProgress(
            current: students.length,
            total: students.length,
            message: 'Saving ZIP...',
          );

          await File(location.path).writeAsBytes(zipBytes);

          return QrExportResult.success(exportedCount: students.length);

        case QrExportOption.zipPdf:
          final files = <String, Uint8List>{};

          _updateProgress(
            current: 0,
            total: students.length,
            message: 'Preparing PDFs...',
          );

          for (int i = 0; i < students.length; i++) {
            final student = students[i];

            _updateProgress(
              current: i + 1,
              total: students.length,
              message: 'Generating PDF ${i + 1} of ${students.length}',
            );

            files['${student.admissionNumber}.pdf'] = await pdfService
                .generateSingle(student: student);
          }

          _updateProgress(
            current: students.length,
            total: students.length,
            message: 'Creating ZIP archive...',
          );

          final zipBytes = await zipService.generate(files: files);

          final location = await getSaveLocation(
            suggestedName: 'attendance_qr_cards.zip',
          );

          if (location == null) {
            return QrExportResult.failure(message: 'Export cancelled.');
          }

          _updateProgress(
            current: students.length,
            total: students.length,
            message: 'Saving ZIP...',
          );

          await File(location.path).writeAsBytes(zipBytes);

          return QrExportResult.success(exportedCount: students.length);
      }
    } catch (e) {
      _errorMessage = e.toString();

      return QrExportResult.failure(message: _errorMessage);
    } finally {
      _isLoading = false;

      _progress = 0;
      _total = 0;
      _progressMessage = '';

      notifyListeners();
    }
  }

  Future<QrExportResult> printStudent({required Student student}) async {
    if (_isLoading) {
      return QrExportResult.failure(
        message: 'Another operation is already in progress.',
      );
    }

    _isLoading = true;
    notifyListeners();

    try {
      await pdfService.printSingle(student: student);

      return QrExportResult.success(
        exportedCount: 1,
        message: 'Print dialog opened.',
      );
    } catch (e) {
      return QrExportResult.failure(message: e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<QrExportResult> printStudents({
    required List<Student> students,
  }) async {
    if (_isLoading) {
      return QrExportResult.failure(
        message: 'Another operation is already in progress.',
      );
    }

    _isLoading = true;
    notifyListeners();

    try {
      await pdfService.print(students: students);

      return QrExportResult.success(
        exportedCount: students.length,
        message: 'Print dialog opened.',
      );
    } catch (e) {
      return QrExportResult.failure(message: e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
