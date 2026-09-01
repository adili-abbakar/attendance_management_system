import 'package:attendance_management_system/core/dialogs/app_form_dialog.dart';
import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:attendance_management_system/features/levels/providers/level_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LevelFormDialog extends StatefulWidget {
  const LevelFormDialog({super.key, this.initialName, required this.onSave});

  final String? initialName;

  final Future<bool> Function(String name) onSave;

  @override
  State<LevelFormDialog> createState() => _LevelFormDialogState();
}

class _LevelFormDialogState extends State<LevelFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;

  late String level;
  late int semester;

  bool _isSaving = false;

  String? _generalError;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.initialName ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _generalError = null;
      _isSaving = true;
    });

    final success = await widget.onSave(nameController.text.trim());

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      return;
    }

    final provider = context.read<LevelProvider>();

    setState(() {
      _generalError =
          provider.levelNameError ?? provider.error ?? 'Unable to save level.';
      _isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);

    return AppFormDialog(
      title: widget.initialName == null ? 'Add Level' : 'Edit Level',
      formKey: _formKey,
      isSaving: _isSaving,
      errorMessage: _generalError,
      saveButtonText: widget.initialName == null ? 'Save' : 'Update',
      savingButtonText: widget.initialName == null
          ? 'Saving...'
          : 'Updating...',
      saveIcon: widget.initialName == null
          ? Icons.save_rounded
          : Icons.edit_rounded,
      onSave: _save,
      children: [
        TextFormField(
          controller: nameController,
          enabled: !_isSaving,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            labelText: 'Level Name',
            prefixIcon: Icon(Icons.school_outlined, size: r.iconMedium),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Level name is required';
            }

            return null;
          },
        ),
      ],
    );
  }
}
