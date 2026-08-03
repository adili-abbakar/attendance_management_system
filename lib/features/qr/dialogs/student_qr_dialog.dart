import 'package:attendance_management_system/features/qr/constants/qr_card_layout.dart';
import 'package:attendance_management_system/features/qr/enums/qr_export_option.dart';
import 'package:attendance_management_system/features/qr/providers/qr_export_provider.dart';
import 'package:attendance_management_system/features/qr/widgets/student_qr_card.dart';
import 'package:attendance_management_system/features/students/models/student.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StudentQrDialog extends StatefulWidget {
  const StudentQrDialog({super.key, required this.student});
  final Student student;

  @override
  State<StudentQrDialog> createState() => _StudentQrDialogState();
}

class _StudentQrDialogState extends State<StudentQrDialog> {
  final _pngKey = GlobalKey();

  Future<void> _export(BuildContext context, QrExportOption option) async {
    final exportProvider = context.read<QrExportProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (option == QrExportOption.png) {
      await WidgetsBinding.instance.endOfFrame;
    }

    final result = await exportProvider.export(
      students: [widget.student],
      option: option,
      repaintKey: option == QrExportOption.png ? _pngKey : null,
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

  Future<void> _print(BuildContext context) async {
    final exportProvider = context.read<QrExportProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final result = await exportProvider.printStudent(student: widget.student);

    if (!context.mounted) return;

    if (result.success) {
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Print dialog closed.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(result.message ?? 'Unable to open print dialog.'),
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

              RepaintBoundary(
                key: _pngKey,
                child: SizedBox(
                  width: QrCardLayout.previewWidth,
                  child: StudentQrCard(
                    fullName: widget.student.fullName,
                    admissionNumber: widget.student.admissionNumber,
                  ),
                ),
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
                  onPressed: loading ? null : () => _print(context),
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
