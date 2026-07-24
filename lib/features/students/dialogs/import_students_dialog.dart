import 'package:attendance_management_system/features/students/import/providers/student_import_provider.dart';
import 'package:attendance_management_system/features/students/import/services/student_import_service.dart';
import 'package:attendance_management_system/features/students/import/widgets/import_error_box.dart';
import 'package:attendance_management_system/features/students/import/widgets/import_file_picker_card.dart';
import 'package:attendance_management_system/features/students/import/widgets/import_tips.dart';
import 'package:attendance_management_system/features/students/import/widgets/import_validation_summary.dart';
import 'package:attendance_management_system/features/students/import/widgets/import_warning_box.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ImportStudentsDialog extends StatefulWidget {
  const ImportStudentsDialog({super.key});

  @override
  State<ImportStudentsDialog> createState() => _ImportStudentsDialogState();
}

class _ImportStudentsDialogState extends State<ImportStudentsDialog> {
  PlatformFile? _selectedFile;
  String? _generalError;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<StudentImportProvider>().clear();
    });
  }

  Future<void> _pickFile() async {
    final provider = context.read<StudentImportProvider>();

    if (provider.isImporting) return;

    provider.clear();

    setState(() {
      _selectedFile = null;
      _generalError = null;
    });

    final result = await StudentImportService.instance.pickFile();

    if (!mounted) return;

    setState(() {
      if (result.success) {
        _selectedFile = result.file;
      } else {
        _generalError = result.error;
      }
    });
  }

  Future<void> _validateImport() async {
    if (_selectedFile == null) return;

    await context.read<StudentImportProvider>().validateImport(_selectedFile!);

    if (!mounted) return;

    setState(() {});
  }

  Future<void> _continueImport() async {
    final provider = context.read<StudentImportProvider>();

    final summary = await provider.confirmImport();

    if (!mounted) return;

    if (summary.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Successfully imported '
            '${summary.importedCount} students. '
            '${summary.skippedCount} skipped.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      provider.clear();

      Navigator.pop(context, true);
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }

    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }

    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final provider = context.watch<StudentImportProvider>();

    return AlertDialog(
      title: const Text('Import Students'),
      content: SizedBox(
        width: width > 600 ? 500 : double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Import students from an Excel (.xlsx) or CSV (.csv) file.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: 24),

              ImportFilePickerCard(
                selectedFile: _selectedFile,
                onPickFile: _pickFile,
                isLoading: provider.isImporting,
              ),

              if (_generalError != null) ...[
                const SizedBox(height: 20),
                ImportErrorBox(message: _generalError!),
              ],

              if (provider.generalError != null) ...[
                const SizedBox(height: 20),
                ImportErrorBox(message: provider.generalError!),
              ],

              if (provider.preview != null) ...[
                const SizedBox(height: 20),

                ImportValidationSummary(
                  totalRows: provider.preview!.totalRows,
                  validRows: provider.preview!.validRows,
                  skippedRows: provider.preview!.skippedRows,
                ),
              ],
              if (provider.preview?.errors.isNotEmpty ?? false) ...[
                const SizedBox(height: 20),

                ImportWarningBox(
                  title: 'Errors',
                  messages: provider.preview!.errors,
                  color: Colors.orange,
                  showDescription: true,
                ),
              ],

              if (provider.preview?.warnings.isNotEmpty ?? false) ...[
                const SizedBox(height: 20),

                ImportWarningBox(
                  title: 'Warnings',
                  messages: provider.preview!.warnings,
                  color: Colors.amber,
                ),
              ],
              const SizedBox(height: 24),

              const ImportTips(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: provider.isImporting
              ? null
              : () {
                  provider.clear();

                  setState(() {
                    _selectedFile = null;
                    _generalError = null;
                  });

                  Navigator.pop(context);
                },
          child: const Text('Cancel'),
        ),

        FilledButton.icon(
          onPressed: (_selectedFile == null || provider.isImporting)
              ? null
              : (provider.hasPreview ? _continueImport : _validateImport),
          icon: provider.isImporting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(provider.hasPreview ? Icons.check : Icons.upload),
          label: Text(provider.hasPreview ? 'Continue Import' : 'Import'),
        ),
      ],
    );
  }
}
