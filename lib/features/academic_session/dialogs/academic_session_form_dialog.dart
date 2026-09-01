import 'package:attendance_management_system/core/dialogs/app_form_dialog.dart';
import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:attendance_management_system/features/academic_session/providers/academic_session_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AcademicSessionFormDialog extends StatefulWidget {
  const AcademicSessionFormDialog({
    super.key,
    this.initialName,
    required this.onSave,
  });

  final String? initialName;
  final Future<bool> Function(String name) onSave;

  bool get isEditing => initialName != null;

  @override
  State<AcademicSessionFormDialog> createState() =>
      _AcademicSessionFormDialogState();
}

class _AcademicSessionFormDialogState extends State<AcademicSessionFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;

  bool _isSaving = false;
  String? _generalError;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.initialName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;

    setState(() {
      _generalError = null;
      _isSaving = true;
    });

    final success = await widget.onSave(_nameController.text.trim());

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      return;
    }

    final provider = context.read<AcademicSessionProvider>();

    setState(() {
      _generalError =
          provider.academicSessionNameError ??
          provider.error ??
          'Unable to save session.';

      _isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);

    return AppFormDialog(
      title: widget.isEditing ? 'Edit Session' : 'Add Session',
      formKey: _formKey,
      isSaving: _isSaving,
      errorMessage: _generalError,
      saveButtonText: widget.isEditing ? 'Update' : 'Save',
      savingButtonText: widget.isEditing ? 'Updating...' : 'Saving...',
      saveIcon: widget.isEditing ? Icons.edit_rounded : Icons.save_rounded,
      onSave: _save,
      children: [_buildSessionNameField(r)],
    );
  }

  Widget _buildSessionNameField(AppResponsive r) {
    return TextFormField(
      controller: _nameController,
      enabled: !_isSaving,
      textCapitalization: TextCapitalization.characters,
      decoration: InputDecoration(
        labelText: 'Session Name',
        prefixIcon: Icon(Icons.calendar_month_outlined, size: r.iconMedium),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Session name is required';
        }

        return null;
      },
    );
  }
}
