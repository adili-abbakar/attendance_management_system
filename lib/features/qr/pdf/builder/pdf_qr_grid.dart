import 'dart:math';

import 'package:attendance_management_system/features/qr/constants/qr_card_layout.dart';
import 'package:attendance_management_system/features/qr/pdf/widgets/pdf_student_qr_card.dart';
import 'package:attendance_management_system/features/students/models/student.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfQrGrid {
  const PdfQrGrid();

  static const _pageFormat = PdfPageFormat.a4;

  void build({required pw.Document document, required List<Student> students}) {
    final cardsPerPage = QrCardLayout.columns * QrCardLayout.rows;

    final totalPages = (students.length / cardsPerPage).ceil();

    for (int page = 0; page < totalPages; page++) {
      final start = page * cardsPerPage;
      final end = min(start + cardsPerPage, students.length);

      final pageStudents = students.sublist(start, end);

      document.addPage(
        pw.Page(
          pageFormat: _pageFormat,
          margin: pw.EdgeInsets.all(
            QrCardLayout.pageMarginMm * PdfPageFormat.mm,
          ),
          build: (_) {
            // Available printable width
            final availableWidth =
                _pageFormat.availableWidth -
                (QrCardLayout.pageMarginMm * 2 * PdfPageFormat.mm);

            // Width of one card
            final cardWidth =
                (availableWidth -
                    ((QrCardLayout.columns - 1) *
                        QrCardLayout.horizontalSpacingMm *
                        PdfPageFormat.mm)) /
                QrCardLayout.columns;

            // Keep the same ratio as Flutter preview
            final cardHeight = cardWidth * QrCardLayout.portraitHeightFactor;

            int index = 0;

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: List.generate(QrCardLayout.rows, (row) {
                return pw.Padding(
                  padding: pw.EdgeInsets.only(
                    bottom: row == QrCardLayout.rows - 1
                        ? 0
                        : QrCardLayout.verticalSpacingMm * PdfPageFormat.mm,
                  ),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: List.generate(QrCardLayout.columns, (column) {
                      final hasStudent = index < pageStudents.length;

                      final widget = pw.SizedBox(
                        width: cardWidth,
                        height: cardHeight,
                        child: hasStudent
                            ? PdfStudentQrCard(
                                fullName: pageStudents[index].fullName,
                                admissionNumber:
                                    pageStudents[index].admissionNumber,
                              )
                            : pw.SizedBox(),
                      );

                      index++;

                      if (column == QrCardLayout.columns - 1) {
                        return widget;
                      }

                      return pw.Row(
                        children: [
                          widget,
                          pw.SizedBox(
                            width:
                                QrCardLayout.horizontalSpacingMm *
                                PdfPageFormat.mm,
                          ),
                        ],
                      );
                    }),
                  ),
                );
              }),
            );
          },
        ),
      );
    }
  }
}
