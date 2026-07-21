import 'package:attendance_management_system/features/students/models/student.dart';
import 'package:flutter/material.dart';

class StudentFormDialog extends StatefulWidget {
  const StudentFormDialog({super.key, this.student, required this.onSave});

  final Student? student;

  final Future<bool> Function(Student student) onSave;

  @override
  State<StudentFormDialog> createState() => _StudentFormDialogState();
}

class _StudentFormDialogState extends State<StudentFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController admissionNumberController;
  late final TextEditingController nameController;

  bool isActive = true;

  bool _isSaving = false;
  String? _generalError;

  @override
  void initState() {
    super.initState();

    admissionNumberController = TextEditingController(
      text: widget.student?.admissionNumber ?? '',
    );

    nameController = TextEditingController(text: widget.student?.fullName ?? '');

    isActive = widget.student?.isActive ?? true;
  }

  @override
  void dispose() {
    admissionNumberController.dispose();
    nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _generalError = null;
    });

    final now = DateTime.now();

    final student = Student(
      id: widget.student?.id,
      admissionNumber: admissionNumberController.text.trim(),
      fullName: nameController.text.trim(),
      isActive: isActive,
      createdAt: widget.student?.createdAt ?? now,
      updatedAt: now,
    );

    final success = await widget.onSave(student);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      _generalError = 'A student with this admission number already exists.';
      _isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return AlertDialog(
      title: Text(widget.student == null ? 'Add Student' : 'Edit Student'),
      content: SizedBox(
        width: width > 600 ? 450 : double.maxFinite,
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: admissionNumberController,
                  enabled: !_isSaving,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Admission Number',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Admission number is required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: nameController,
                  enabled: !_isSaving,
                  decoration: const InputDecoration(labelText: 'Student Name'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Student name is required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                SwitchListTile(
                  value: isActive,
                  onChanged: _isSaving
                      ? null
                      : (value) {
                          setState(() {
                            isActive = value;
                          });
                        },
                  title: const Text('Active'),
                  contentPadding: EdgeInsets.zero,
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
          child: const Text('Cancel'),
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
          label: Text(_isSaving ? 'Saving...' : 'Save'),
        ),
      ],
    );
  }
}
