import 'package:attendance_management_system/features/qr/enums/qr_export_option.dart';
import 'package:attendance_management_system/features/qr/pdf/pdf.dart';
import 'package:attendance_management_system/features/qr/png/png.dart';
import 'package:attendance_management_system/features/qr/zip/zip.dart';
import 'package:attendance_management_system/features/qr/results/qr_export_result.dart';
import 'package:attendance_management_system/features/students/models/student.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

  final Set<int> _selectedStudentIds = {};

  int _progress = 0;
  int _total = 0;
  String _progressMessage = '';

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get hasSelection => _selectedStudentIds.isNotEmpty;

  int get selectedCount => _selectedStudentIds.length;

  Set<int> get selectedStudentIds => Set.unmodifiable(_selectedStudentIds);

  int get progress => _progress;

  int get total => _total;

  String get progressMessage => _progressMessage;

  double get progressValue {
    if (_total <= 0) return 0;

    return (_progress / _total).clamp(0.0, 1.0);
  }

  // ---------------------------------------------------------------------------
  // Selection
  // ---------------------------------------------------------------------------

  bool isSelected(Student student) {
    final id = student.id;

    return id != null && _selectedStudentIds.contains(id);
  }

  void toggleStudent(Student student) {
    final id = student.id;

    if (id == null) return;

    if (_selectedStudentIds.contains(id)) {
      _selectedStudentIds.remove(id);
    } else {
      _selectedStudentIds.add(id);
    }

    notifyListeners();
  }

  void selectStudent(Student student) {
    final id = student.id;

    if (id == null) return;

    if (_selectedStudentIds.add(id)) {
      notifyListeners();
    }
  }

  void unselectStudent(Student student) {
    final id = student.id;

    if (id == null) return;

    if (_selectedStudentIds.remove(id)) {
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
    if (_selectedStudentIds.isEmpty) return;

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

  // ---------------------------------------------------------------------------
  // Progress
  // ---------------------------------------------------------------------------

  void _updateProgress({
    required int current,
    required int total,
    required String message,
  }) {
    _total = total;
    _progress = current.clamp(0, total);
    _progressMessage = message;

    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Main export
  // ---------------------------------------------------------------------------

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

    if (students.isEmpty) {
      return QrExportResult.failure(
        message: 'No students selected for export.',
      );
    }

    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      switch (option) {
        // Printing has its own dedicated method.
        case QrExportOption.printPdf:
          return QrExportResult.failure(
            message: 'Use printStudents() for printing.',
          );

        // Bulk PDF.
        case QrExportOption.pdf:
          return await _exportPdf(students);

        // Individual PNG.
        //
        // This remains here because the provider also supports individual
        // student QR export. It is NOT part of the bulk export workflow.
        case QrExportOption.png:
          return await _exportSinglePng(
            students: students,
            repaintKey: repaintKey,
          );

        // Bulk PNG ZIP.
        case QrExportOption.zipPng:
          return await _exportZipPng(students);

        // Bulk PDF ZIP.
        case QrExportOption.zipPdf:
          return await _exportZipPdf(students);
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

  // ---------------------------------------------------------------------------
  // PDF export
  // ---------------------------------------------------------------------------

  Future<QrExportResult> _exportPdf(List<Student> students) async {
    final bytes = await pdfService.generate(students: students);

    final fileName = students.length == 1
        ? '${students.first.admissionNumber}.pdf'
        : 'attendance_qr_cards.pdf';

    return _deliverFile(
      bytes: bytes,
      fileName: fileName,
      successMessage: 'PDF exported successfully.',
      exportedCount: students.length,
    );
  }

  // ---------------------------------------------------------------------------
  // Individual PNG export
  // ---------------------------------------------------------------------------
  //
  // This is intentionally kept separate from the bulk export workflow.
  // The bulk export UI should not expose this option.
  // ---------------------------------------------------------------------------

  Future<QrExportResult> _exportSinglePng({
    required List<Student> students,
    required GlobalKey? repaintKey,
  }) async {
    if (students.length != 1) {
      return QrExportResult.failure(
        message: 'PNG export is only available for one student at a time.',
      );
    }

    if (repaintKey == null) {
      return QrExportResult.failure(message: 'Unable to capture QR card.');
    }

    final bytes = await pngService.generate(repaintKey: repaintKey);

    return _deliverFile(
      bytes: bytes,
      fileName: '${students.first.admissionNumber}.png',
      successMessage: 'PNG exported successfully.',
      exportedCount: 1,
    );
  }

  // ---------------------------------------------------------------------------
  // Bulk PNG ZIP export
  // ---------------------------------------------------------------------------

  Future<QrExportResult> _exportZipPng(List<Student> students) async {
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
        pixelRatio: 2,
      );

      files['${student.admissionNumber}.png'] = bytes;
    }

    _updateProgress(
      current: students.length,
      total: students.length,
      message: 'Creating ZIP archive...',
    );

    final zipBytes = await zipService.generate(files: files);

    _updateProgress(
      current: students.length,
      total: students.length,
      message: 'Preparing ZIP file...',
    );

    return _deliverFile(
      bytes: zipBytes,
      fileName: 'attendance_qr_cards_png.zip',
      successMessage: 'PNG ZIP exported successfully.',
      exportedCount: students.length,
    );
  }

  // ---------------------------------------------------------------------------
  // Bulk PDF ZIP export
  // ---------------------------------------------------------------------------

  Future<QrExportResult> _exportZipPdf(List<Student> students) async {
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

      files['${student.admissionNumber}.pdf'] = await pdfService.generateSingle(
        student: student,
      );
    }

    _updateProgress(
      current: students.length,
      total: students.length,
      message: 'Creating ZIP archive...',
    );

    final zipBytes = await zipService.generate(files: files);

    _updateProgress(
      current: students.length,
      total: students.length,
      message: 'Preparing ZIP file...',
    );

    return _deliverFile(
      bytes: zipBytes,
      fileName: 'attendance_qr_cards_pdf.zip',
      successMessage: 'PDF ZIP exported successfully.',
      exportedCount: students.length,
    );
  }

  // ---------------------------------------------------------------------------
  // Save generated files using the native file picker on every platform.
  Future<QrExportResult> _deliverFile({
    required Uint8List bytes,
    required String fileName,
    required String successMessage,
    required int exportedCount,
  }) async {
    if (bytes.isEmpty) {
      return QrExportResult.failure(message: 'The generated file is empty.');
    }

    return _saveFile(
      bytes: bytes,
      fileName: fileName,
      successMessage: successMessage,
      exportedCount: exportedCount,
    );
  }

  Future<QrExportResult> _saveFile({
    required Uint8List bytes,
    required String fileName,
    required String successMessage,
    required int exportedCount,
  }) async {
    final extension = _fileExtension(fileName);

    final savedPath = await FilePicker.saveFile(
      dialogTitle: 'Save QR Card Export',
      fileName: fileName,
      bytes: bytes,
      type: FileType.custom,
      allowedExtensions: [extension],
    );

    if (savedPath == null && !kIsWeb) {
      return QrExportResult.failure(message: 'Export cancelled.');
    }

    return QrExportResult.success(
      exportedCount: exportedCount,
      message: successMessage,
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _fileExtension(String fileName) {
    final index = fileName.lastIndexOf('.');

    if (index == -1 || index == fileName.length - 1) {
      return fileName;
    }

    return fileName.substring(index + 1);
  }

  // ---------------------------------------------------------------------------
  // Printing
  // ---------------------------------------------------------------------------

  Future<QrExportResult> printStudent({required Student student}) async {
    if (_isLoading) {
      return QrExportResult.failure(
        message: 'Another operation is already in progress.',
      );
    }

    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      await pdfService.printSingle(student: student);

      return QrExportResult.success(
        exportedCount: 1,
        message: 'Print dialog opened.',
      );
    } catch (e) {
      _errorMessage = e.toString();

      return QrExportResult.failure(message: _errorMessage);
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

    if (students.isEmpty) {
      return QrExportResult.failure(
        message: 'No students selected for printing.',
      );
    }

    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      await pdfService.print(students: students);

      return QrExportResult.success(
        exportedCount: students.length,
        message: 'Print dialog opened.',
      );
    } catch (e) {
      _errorMessage = e.toString();

      return QrExportResult.failure(message: _errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
