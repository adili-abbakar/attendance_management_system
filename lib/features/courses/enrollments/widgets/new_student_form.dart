import 'package:attendance_management_system/features/students/models/student.dart';
import 'package:attendance_management_system/features/students/results/student_result.dart';
import 'package:flutter/material.dart';

class NewStudentForm extends StatefulWidget {
  const NewStudentForm({super.key, required this.onSave});

  final Future<StudentResult> Function(Student student) onSave;

  @override
  State<NewStudentForm> createState() => _NewStudentFormState();
}

class _NewStudentFormState extends State<NewStudentForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _admissionController;
  late final TextEditingController _nameController;

  bool _isActive = true;
  bool _isSaving = false;

  String? _generalError;

  @override
  void initState() {
    super.initState();

    _admissionController = TextEditingController();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _admissionController.dispose();
    _nameController.dispose();
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
      admissionNumber: _admissionController.text.trim(),
      fullName: _nameController.text.trim(),
      isActive: _isActive,
      createdAt: now,
      updatedAt: now,
    );

    final result = await widget.onSave(student);

    if (!mounted) return;

    if (result.success) {
      Navigator.pop(context, result.student);
      return;
    }

    setState(() {
      _generalError =
          result.admissionNumberError ?? 'Unable to create student.';
      _isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _admissionController,
            enabled: !_isSaving,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Admission Number',
              isDense: true,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Admission number is required';
              }
              return null;
            },
          ),

          const SizedBox(height: 12),

          TextFormField(
            controller: _nameController,
            enabled: !_isSaving,
            decoration: const InputDecoration(
              labelText: 'Student Name',
              isDense: true,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Student name is required';
              }
              return null;
            },
          ),

          const SizedBox(height: 12),

          SwitchListTile(
            value: _isActive,
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: const Text('Active'),
            onChanged: _isSaving
                ? null
                : (value) {
                    setState(() {
                      _isActive = value;
                    });
                  },
          ),

          if (_generalError != null) ...[
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 10),
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

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.person_add_alt_1, size: 18),
              label: Text(_isSaving ? 'Adding...' : 'Create & Add Student'),
            ),
          ),
        ],
      ),
    );
  }
}
