import 'dart:typed_data';

import 'package:attendance_management_system/features/qr/pdf/builder/pdf_qr_grid.dart';
import 'package:attendance_management_system/features/students/models/student.dart';
import 'package:pdf/widgets.dart' as pw;

class QrPdfService {
  const QrPdfService();

  /// Generates the PDF and returns its bytes.
  Future<Uint8List> generate({required List<Student> students}) async {
    final document = pw.Document();

    const PdfQrGrid().build(document: document, students: students);

    return document.save();
  }
}
