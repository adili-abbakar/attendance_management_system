import 'dart:typed_data';

import 'package:attendance_management_system/features/qr/constants/constants.dart';
import 'package:attendance_management_system/features/qr/pdf/pdf.dart';
import 'package:attendance_management_system/features/students/models/student.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class QrPdfService {
  const QrPdfService();

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

  Future<void> print({required List<Student> students}) async {
    await Printing.layoutPdf(
      name: 'attendance_qr_cards',
      onLayout: (_) => generate(students: students),
    );
  }

  Future<void> printSingle({required Student student}) async {
    await Printing.layoutPdf(
      name: '${student.admissionNumber}.pdf',
      onLayout: (_) => generateSingle(student: student),
    );
  }
}
