import 'package:attendance_management_system/features/qr/constants/qr_card_style.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfStudentQrCard extends pw.StatelessWidget {
  PdfStudentQrCard({required this.fullName, required this.admissionNumber});

  final String fullName;
  final String admissionNumber;

  @override
  pw.Widget build(pw.Context context) {
    return pw.LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints!.maxWidth;
        final height = constraints.maxHeight;

        return pw.Container(
          padding: const pw.EdgeInsets.all(QrCardStyle.padding),

          decoration: pw.BoxDecoration(
            color: PdfColors.white,
            borderRadius: pw.BorderRadius.circular(QrCardStyle.borderRadius),
            border: pw.Border.all(color: PdfColors.grey400, width: .5),
          ),

          child: pw.Column(
            children: [
              pw.SizedBox(
                height: height * QrCardStyle.nameSection,
                child: pw.Center(
                  child: pw.Text(
                    fullName,
                    maxLines: 2,
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ),

              pw.SizedBox(
                height: height * QrCardStyle.admissionSection,
                child: pw.Center(
                  child: pw.Text(
                    admissionNumber,
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                ),
              ),

              pw.Expanded(
                child: pw.Center(
                  child: pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: admissionNumber,
                    width: width * QrCardStyle.qrScale,
                    height: width * QrCardStyle.qrScale,
                  ),
                ),
              ),

              pw.SizedBox(
                height: height * QrCardStyle.footerSection,
                child: pw.Center(
                  child: pw.Text(
                    'Attendance QR Card',
                    style: const pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
