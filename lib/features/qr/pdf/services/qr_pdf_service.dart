import 'dart:typed_data';

import 'package:attendance_management_system/features/qr/pdf/pdf.dart';
import 'package:attendance_management_system/features/students/models/student.dart';
import 'package:attendance_management_system/features/qr/constants/constants.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class QrPdfService {
  const QrPdfService();

  /// Generates the PDF and returns its bytes.
  Future<Uint8List> generate({required List<Student> students}) async {
    final document = pw.Document();

    const PdfQrGrid().build(document: document, students: students);

    return document.save();
  }

  Future<Uint8List> generateSingle({required Student student}) async {
    final document = pw.Document();

    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          QrCardLayout.cardWidthMm * PdfPageFormat.mm,
          QrCardLayout.cardHeightMm * PdfPageFormat.mm,
        ),
        build: (_) => PdfStudentQrCard(
          fullName: student.fullName,
          admissionNumber: student.admissionNumber,
        ),
      ),
    );

    return document.save();
  }
}
