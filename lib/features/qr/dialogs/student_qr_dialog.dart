import 'package:attendance_management_system/features/qr/enums/qr_export_option.dart';
import 'package:attendance_management_system/features/qr/providers/qr_export_provider.dart';
import 'package:attendance_management_system/features/qr/widgets/student_qr_card.dart';
import 'package:attendance_management_system/features/students/models/student.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StudentQrDialog extends StatelessWidget {
  const StudentQrDialog({super.key, required this.student});

  final Student student;

  Future<void> _export(BuildContext context, QrExportOption option) async {
    final exportProvider = context.read<QrExportProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final result = await exportProvider.export(
      students: [student],
      option: option,
    );

    if (!context.mounted) return;

    if (result.success) {
      navigator.pop();

      messenger.showSnackBar(
        SnackBar(
          content: Text(result.message ?? 'Export completed successfully.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(result.message ?? 'Export failed.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<QrExportProvider>().isLoading;

    return Dialog(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Student QR Code',
                style: Theme.of(context).textTheme.titleLarge,
              ),

              const SizedBox(height: 20),

              StudentQrCard(
                fullName: student.fullName,
                admissionNumber: student.admissionNumber,
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: loading
                      ? null
                      : () => _export(context, QrExportOption.pdf),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Save as PDF'),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: loading
                      ? null
                      : () => _export(context, QrExportOption.png),
                  icon: const Icon(Icons.image_outlined),
                  label: const Text('Save as PNG'),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: loading
                      ? null
                      : () => _export(context, QrExportOption.pdf),
                  icon: const Icon(Icons.print),
                  label: const Text('Print'),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: loading ? null : () => Navigator.pop(context),
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
