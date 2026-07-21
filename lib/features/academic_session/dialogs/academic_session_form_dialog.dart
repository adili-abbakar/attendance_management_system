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

  @override
  State<AcademicSessionFormDialog> createState() =>
      _AcademicSessionFormDialogState();
}

class _AcademicSessionFormDialogState extends State<AcademicSessionFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;

  late String academicSession;
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

    final provider = context.read<AcademicSessionProvider>();

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      return;
    }

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
    final width = MediaQuery.sizeOf(context).width;

    return AlertDialog(
      title: Text(widget.initialName == null ? "Add session" : "Edit session"),

      content: SizedBox(
        width: width > 600 ? 450 : double.maxFinite,

        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,

          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,

              children: [
                TextFormField(
                  controller: nameController,
                  enabled: !_isSaving,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(labelText: "Session Name"),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Session name is required";
                    }

                    return null;
                  },
                ),

                if (_generalError != null) ...[
                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            _generalError!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),

      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),

        FilledButton.icon(
          onPressed: _isSaving ? null : _save,
          icon: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save),

          label: Text(_isSaving ? "Saving..." : "Save"),
        ),
      ],
    );
  }
}
