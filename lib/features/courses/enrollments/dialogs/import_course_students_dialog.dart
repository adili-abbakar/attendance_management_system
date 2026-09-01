import 'package:attendance_management_system/core/dialogs/app_form_dialog.dart';
import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:attendance_management_system/features/courses/enrollments/providers/course_student_import_provider.dart';
import 'package:attendance_management_system/features/courses/enrollments/services/course_student_import_service.dart';
import 'package:attendance_management_system/features/students/import/widgets/import_error_box.dart';
import 'package:attendance_management_system/features/students/import/widgets/import_file_picker_card.dart';
import 'package:attendance_management_system/features/students/import/widgets/import_tips.dart';
import 'package:attendance_management_system/features/students/import/widgets/import_validation_summary.dart';
import 'package:attendance_management_system/features/students/import/widgets/import_warning_box.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ImportCourseStudentsDialog extends StatefulWidget {
  const ImportCourseStudentsDialog({super.key, required this.courseId});

  final int courseId;

  @override
  State<ImportCourseStudentsDialog> createState() =>
      _ImportCourseStudentsDialogState();
}

class _ImportCourseStudentsDialogState
    extends State<ImportCourseStudentsDialog> {
  final _formKey = GlobalKey<FormState>();

  PlatformFile? _selectedFile;
  String? _generalError;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<CourseStudentImportProvider>().clear();
    });
  }

  Future<void> _pickFile() async {
    final provider = context.read<CourseStudentImportProvider>();

    if (provider.isImporting) return;

    provider.clear();

    setState(() {
      _selectedFile = null;
      _generalError = null;
    });

    final result = await CourseStudentImportService.instance.pickFile();

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

    await context.read<CourseStudentImportProvider>().validateImport(
      _selectedFile!,
      widget.courseId,
    );

    if (!mounted) return;

    setState(() {});
  }

  Future<void> _continueImport() async {
    final provider = context.read<CourseStudentImportProvider>();

    final summary = await provider.confirmImport(widget.courseId);

    if (!mounted) return;

    if (summary.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Created ${summary.createdStudents} new students, '
            'linked ${summary.linkedExistingStudents} existing students, '
            '${summary.alreadyEnrolled} already enrolled.',
          ),
        ),
      );

      provider.clear();

      Navigator.pop(context, true);
    }
  }

  Future<void> _handleImport() async {
    final provider = context.read<CourseStudentImportProvider>();

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
    final provider = context.read<CourseStudentImportProvider>();

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
    final provider = context.watch<CourseStudentImportProvider>();

    return AppFormDialog(
      title: 'Import Students',
      formKey: _formKey,
      isSaving: provider.isImporting,
      errorMessage: null,
      saveButtonText: provider.hasPreview ? 'Continue Import' : 'Import',
      savingButtonText: provider.hasPreview ? 'Importing...' : 'Validating...',
      saveIcon: provider.hasPreview
          ? Icons.check_rounded
          : Icons.upload_rounded,
      onSave: _handleImport,
      saveButtonEnabled: _selectedFile != null,
      onCancel: _cancel,
      children: [
        Text(
          'Import students from an Excel (.xlsx) or CSV (.csv) file.',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontSize: r.body),
        ),

        SizedBox(height: r.spacingM),

        ImportFilePickerCard(
          selectedFile: _selectedFile,
          onPickFile: _pickFile,
          isLoading: provider.isImporting,
        ),

        if (_generalError != null) ...[
          SizedBox(height: r.spacingS),
          ImportErrorBox(message: _generalError!),
        ],

        if (provider.generalError != null) ...[
          SizedBox(height: r.spacingS),
          ImportErrorBox(message: provider.generalError!),
        ],

        if (provider.preview != null) ...[
          SizedBox(height: r.spacingS),
          ImportValidationSummary(
            totalRows: provider.preview!.totalRows,
            validRows: provider.preview!.validRows,
            skippedRows: provider.preview!.skippedRows,
          ),
        ],

        if (provider.preview?.errors.isNotEmpty ?? false) ...[
          SizedBox(height: r.spacingS),
          ImportWarningBox(
            title: 'Errors',
            messages: provider.preview!.errors,
            color: Colors.orange,
            showDescription: true,
          ),
        ],

        if (provider.preview?.warnings.isNotEmpty ?? false) ...[
          SizedBox(height: r.spacingS),
          ImportWarningBox(
            title: 'Warnings',
            messages: provider.preview!.warnings,
            color: Colors.amber,
          ),
        ],

        SizedBox(height: r.spacingM),

        const ImportTips(),
      ],
    );
  }
}
