import 'package:attendance_management_system/features/qr/constants/qr_card_layout.dart';
import 'package:attendance_management_system/features/qr/constants/qr_card_style.dart';
import 'package:attendance_management_system/features/qr/widgets/qr_code_widget.dart';
import 'package:flutter/material.dart';

class PngStudentQrCard extends StatelessWidget {
  const PngStudentQrCard({super.key, 
    required this.fullName,
    required this.admissionNumber,
    this.width = QrCardLayout.previewWidth,
  });

  final String fullName;
  final String admissionNumber;
  final double width;

  @override
  Widget build(BuildContext context) {
    final height =
        width / QrCardLayout.previewWidth * QrCardLayout.previewHeight;

    return Material(
      color: Colors.white,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(QrCardStyle.exportBorderRadius),
        child: Container(
          width: width,
          height: height,
          padding: const EdgeInsets.all(QrCardStyle.padding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(QrCardStyle.exportBorderRadius),
            border: Border.all(
              color: Colors.grey.shade400,
              width: QrCardStyle.exportBorderWidth,
            ),
          ),
          child: Column(
            children: [
              SizedBox(
                height: height * QrCardStyle.nameSection,
                child: Center(
                  child: Text(
                    fullName,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

              SizedBox(
                height: height * QrCardStyle.admissionSection,
                child: Center(
                  child: Text(
                    admissionNumber,
                    style: const TextStyle(fontSize: 10, color: Colors.black54),
                  ),
                ),
              ),

              Expanded(
                child: Center(
                  child: QrCodeWidget(
                    data: admissionNumber,
                    size: width * QrCardStyle.exportQrScale,
                  ),
                ),
              ),

              SizedBox(
                height: height * QrCardStyle.footerSection,
                child: const Center(
                  child: Text(
                    'Attendance QR Card',
                    style: TextStyle(fontSize: 8, color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
