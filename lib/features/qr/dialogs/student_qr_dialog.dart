import 'package:attendance_management_system/features/qr/widgets/student_qr_card.dart';
import 'package:flutter/material.dart';

class StudentQrDialog extends StatelessWidget {
  const StudentQrDialog({
    super.key,
    required this.fullName,
    required this.admissionNumber,
  });

  final String fullName;
  final String admissionNumber;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Student QR Code',
                style: Theme.of(context).textTheme.titleLarge,
              ),

              const SizedBox(height: 24),

              Center(
                child: StudentQrCard(
                  fullName: fullName,
                  admissionNumber: admissionNumber,
                  width: 250,
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    // TODO: Show export options
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Export'),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
