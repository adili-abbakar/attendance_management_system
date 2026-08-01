import 'package:attendance_management_system/features/qr/constants/qr_card_layout.dart';
import 'package:attendance_management_system/features/qr/constants/qr_card_style.dart';
import 'package:attendance_management_system/features/qr/widgets/qr_code_widget.dart';
import 'package:flutter/material.dart';

class StudentQrCard extends StatelessWidget {
  const StudentQrCard({
    super.key,
    required this.fullName,
    required this.admissionNumber,
    this.width = QrCardLayout.previewWidth,
  });

  final String fullName;
  final String admissionNumber;
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final height =
        width / QrCardLayout.previewWidth * QrCardLayout.previewHeight;

    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(QrCardStyle.padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(QrCardStyle.borderRadius),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            color: Colors.black.withValues(alpha: .15),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: height * QrCardStyle.nameSection,
            child: Center(
              child: Text(
                fullName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),

          SizedBox(
            height: height * QrCardStyle.admissionSection,
            child: Center(
              child: Text(
                admissionNumber,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.black54,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),

          Expanded(
            child: Center(
              child: QrCodeWidget(
                data: admissionNumber,
                size: width * QrCardStyle.qrScale,
              ),
            ),
          ),

          SizedBox(
            height: height * QrCardStyle.footerSection,
            child: Center(
              child: Text(
                'Attendance QR Card',
                style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
