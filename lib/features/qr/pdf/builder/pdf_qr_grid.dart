import 'package:attendance_management_system/features/qr/constants/qr_card_layout.dart';
import 'package:attendance_management_system/features/qr/pdf/widgets/pdf_student_qr_card.dart';
import 'package:attendance_management_system/features/students/models/student.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfQrGrid {
  const PdfQrGrid();

  static const _pageFormat = PdfPageFormat.a4;

  void build({required pw.Document document, required List<Student> students}) {
    if (students.isEmpty) return;

    final cardsPerPage = QrCardLayout.columns * QrCardLayout.rows;

    final totalPages = (students.length / cardsPerPage).ceil();

    final cardWidth = QrCardLayout.cardWidthMm * PdfPageFormat.mm;

    final cardHeight = QrCardLayout.cardHeightMm * PdfPageFormat.mm;

    final horizontalSpacing =
        QrCardLayout.horizontalSpacingMm * PdfPageFormat.mm;

    final verticalSpacing = QrCardLayout.verticalSpacingMm * PdfPageFormat.mm;

    for (int pageIndex = 0; pageIndex < totalPages; pageIndex++) {
      final start = pageIndex * cardsPerPage;
      final end = (start + cardsPerPage).clamp(0, students.length);

      final pageStudents = students.sublist(start, end);

      document.addPage(
        pw.Page(
          pageFormat: _pageFormat,
          margin: pw.EdgeInsets.all(
            QrCardLayout.pageMarginMm * PdfPageFormat.mm,
          ),
          build: (_) {
            int studentIndex = 0;

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: List.generate(QrCardLayout.rows, (rowIndex) {
                final rowChildren = <pw.Widget>[];

                for (
                  int columnIndex = 0;
                  columnIndex < QrCardLayout.columns;
                  columnIndex++
                ) {
                  final hasStudent = studentIndex < pageStudents.length;

                  rowChildren.add(
                    pw.SizedBox(
                      width: cardWidth,
                      height: cardHeight,
                      child: hasStudent
                          ? PdfStudentQrCard(
                              fullName: pageStudents[studentIndex].fullName,
                              admissionNumber:
                                  pageStudents[studentIndex].admissionNumber,
                            )
                          : pw.SizedBox(),
                    ),
                  );

                  if (hasStudent) {
                    studentIndex++;
                  }

                  if (columnIndex < QrCardLayout.columns - 1) {
                    rowChildren.add(pw.SizedBox(width: horizontalSpacing));
                  }
                }

                return pw.Padding(
                  padding: pw.EdgeInsets.only(
                    bottom: rowIndex < QrCardLayout.rows - 1
                        ? verticalSpacing
                        : 0,
                  ),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: rowChildren,
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
