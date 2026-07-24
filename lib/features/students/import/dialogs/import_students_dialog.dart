import 'package:attendance_management_system/features/students/import/providers/student_import_provider.dart';
import 'package:attendance_management_system/features/students/import/services/student_import_service.dart';
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

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.upload_file,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),

                    const SizedBox(height: 16),

                    Text(
                      _selectedFile?.name ?? 'No file selected',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      _selectedFile == null
                          ? 'Choose a spreadsheet to begin importing students.'
                          : _formatBytes(_selectedFile!.size),
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),

                    OutlinedButton.icon(
                      onPressed: provider.isImporting ? null : _pickFile,
                      icon: const Icon(Icons.folder_open),
                      label: Text(
                        _selectedFile == null ? 'Choose File' : 'Change File',
                      ),
                    ),
                  ],
                ),
              ),

              if (_generalError != null) ...[
                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _generalError!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],

              if (provider.generalError != null) ...[
                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    provider.generalError!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],

              if (provider.preview != null) ...[
                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Validation Summary',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 10),

                      Text('Rows found: ${provider.preview!.totalRows}'),

                      Text('Ready to import: ${provider.preview!.validRows}'),

                      Text('Will be skipped: ${provider.preview!.skippedRows}'),
                    ],
                  ),
                ),
              ],

              if (provider.preview?.errors.isNotEmpty ?? false) ...[
                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Warnings',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        'The following rows will be skipped if you continue:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),

                      const SizedBox(height: 8),

                      ...provider.preview!.errors.map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            '⚠ $e',
                            style: const TextStyle(color: Colors.orange),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (provider.preview?.warnings.isNotEmpty ?? false) ...[
                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Warnings',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),

                      const SizedBox(height: 10),

                      ...provider.preview!.warnings.map(
                        (warning) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            '⚠ $warning',
                            style: const TextStyle(color: Colors.amber),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              Text('Tips', style: Theme.of(context).textTheme.titleMedium),

              const SizedBox(height: 12),

              const _TipItem(text: 'Download the template before editing.'),

              const _TipItem(text: 'Do not modify the column names.'),

              const _TipItem(
                text: 'Duplicate admission numbers will be skipped.',
              ),

              const _TipItem(text: 'Only .xlsx and .csv files are supported.'),
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

class _TipItem extends StatelessWidget {
  const _TipItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
