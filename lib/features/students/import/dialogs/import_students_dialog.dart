import 'package:attendance_management_system/core/dialogs/app_form_dialog.dart';
import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:attendance_management_system/features/students/import/providers/student_import_provider.dart';
import 'package:attendance_management_system/features/students/import/services/student_import_service.dart';
import 'package:attendance_management_system/features/students/import/widgets/widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ImportStudentsDialog extends StatefulWidget {
  const ImportStudentsDialog({super.key});

  @override
  State<ImportStudentsDialog> createState() => _ImportStudentsDialogState();
}

class _ImportStudentsDialogState extends State<ImportStudentsDialog> {
  final _formKey = GlobalKey<FormState>();

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

  Future<void> _handleAction() async {
    final provider = context.read<StudentImportProvider>();

    if (_selectedFile == null || provider.isImporting) {
      return;
    }

    if (provider.hasPreview) {
      await _continueImport();
    } else {
      await _validateImport();
    }
  }

  void _cancel() {
    final provider = context.read<StudentImportProvider>();

    if (provider.isImporting) return;

    provider.clear();

    setState(() {
      _selectedFile = null;
      _generalError = null;
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);
    final provider = context.watch<StudentImportProvider>();

    return AppFormDialog(
      title: 'Import Students',
      formKey: _formKey,
      isSaving: provider.isImporting,
      errorMessage: _generalError ?? provider.generalError,

      // Import is disabled until a file has been selected.
      saveButtonEnabled: _selectedFile != null,

      saveButtonText: provider.hasPreview ? 'Continue Import' : 'Import',
      savingButtonText: provider.hasPreview ? 'Importing...' : 'Validating...',
      saveIcon: provider.hasPreview
          ? Icons.check_rounded
          : Icons.upload_rounded,
      onSave: _handleAction,
      onCancel: _cancel,

      children: [
        Text(
          'Import students from an Excel (.xlsx) or CSV (.csv) file.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontSize: r.body),
        ),

        SizedBox(height: r.spacingL),

        _buildFilePicker(r),

        if (provider.preview != null) ...[
          SizedBox(height: r.spacingM),

          _buildValidationSummary(r, provider),
        ],

        if (provider.preview?.errors.isNotEmpty ?? false) ...[
          SizedBox(height: r.spacingM),

          ImportWarningBox(
            title: 'Warnings',
            messages: provider.preview!.errors,
            color: Colors.orange,
            showDescription: true,
          ),
        ],

        if (provider.preview?.warnings.isNotEmpty ?? false) ...[
          SizedBox(height: r.spacingM),

          ImportWarningBox(
            title: 'Warnings',
            messages: provider.preview!.warnings,
            color: Colors.amber,
          ),
        ],

        SizedBox(height: r.spacingL),

        _buildTips(r),
      ],
    );
  }

  Widget _buildFilePicker(AppResponsive r) {
    final provider = context.watch<StudentImportProvider>();

    return ImportFilePickerCard(
      selectedFile: _selectedFile,
      onPickFile: _pickFile,
      isLoading: provider.isImporting,
    );
  }

  Widget _buildValidationSummary(
    AppResponsive r,
    StudentImportProvider provider,
  ) {
    return ImportValidationSummary(
      totalRows: provider.preview!.totalRows,
      validRows: provider.preview!.validRows,
      skippedRows: provider.preview!.skippedRows,
    );
  }

  Widget _buildTips(AppResponsive r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tips',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: r.titleMedium,
            fontWeight: FontWeight.w600,
          ),
        ),

        SizedBox(height: r.spacingS),

        const _TipItem(text: 'Download the template before editing.'),

        const _TipItem(text: 'Do not modify the column names.'),

        const _TipItem(text: 'Duplicate admission numbers will be skipped.'),

        const _TipItem(text: 'Only .xlsx and .csv files are supported.'),
      ],
    );
  }
}

class _TipItem extends StatelessWidget {
  const _TipItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: r.spacingS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: r.iconSmall,
            color: Theme.of(context).colorScheme.primary,
          ),

          SizedBox(width: r.spacingS),

          Expanded(
            child: Text(text, style: TextStyle(fontSize: r.body)),
          ),
        ],
      ),
    );
  }
}
