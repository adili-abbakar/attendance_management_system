import 'package:attendance_management_system/features/qr/widgets/qr_code_widget.dart';
import 'package:flutter/material.dart';

class StudentQrCard extends StatelessWidget {
  const StudentQrCard({
    super.key,
    required this.fullName,
    required this.admissionNumber,
    this.width = 220,
  });

  final String fullName;
  final String admissionNumber;
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Portrait ID card ratio
    final height = width * 1.35;

    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Text(
            fullName,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            admissionNumber,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.black54,
              letterSpacing: 1,
            ),
          ),

          const Spacer(),

          QrCodeWidget(data: admissionNumber, size: width * 0.72),

          const Spacer(),

          Text(
            'Attendance QR Card',
            style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
