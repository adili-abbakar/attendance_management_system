import 'package:attendance_management_system/core/dialogs/app_form_dialog.dart';
import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:attendance_management_system/features/students/models/student.dart';
import 'package:attendance_management_system/features/students/results/student_result.dart';
import 'package:flutter/material.dart';

class StudentFormDialog extends StatefulWidget {
  const StudentFormDialog({super.key, this.student, required this.onSave});

  final Student? student;

  final Future<StudentResult> Function(Student student) onSave;

  bool get isEditing => student != null;

  @override
  State<StudentFormDialog> createState() => _StudentFormDialogState();
}

class _StudentFormDialogState extends State<StudentFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _admissionNumberController;
  late final TextEditingController _nameController;

  bool _isActive = true;

  bool _isSaving = false;
  String? _generalError;

  @override
  void initState() {
    super.initState();

    _admissionNumberController = TextEditingController(
      text: widget.student?.admissionNumber ?? '',
    );

    _nameController = TextEditingController(
      text: widget.student?.fullName ?? '',
    );

    _isActive = widget.student?.isActive ?? true;
  }

  @override
  void dispose() {
    _admissionNumberController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
      _generalError = null;
    });

    final now = DateTime.now();

    final student = Student(
      id: widget.student?.id,
      admissionNumber: _admissionNumberController.text.trim(),
      fullName: _nameController.text.trim(),
      isActive: _isActive,
      createdAt: widget.student?.createdAt ?? now,
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
          result.admissionNumberError ??
          'A student with this admission number already exists.';
      _isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);

    return AppFormDialog(
      title: widget.isEditing ? 'Edit Student' : 'Add Student',
      formKey: _formKey,
      isSaving: _isSaving,
      errorMessage: _generalError,
      saveButtonText: widget.isEditing ? 'Update' : 'Save',
      savingButtonText: widget.isEditing ? 'Updating...' : 'Saving...',
      saveIcon: widget.isEditing ? Icons.edit_rounded : Icons.save_rounded,
      onSave: _save,
      children: [
        _buildAdmissionNumberField(r),

        SizedBox(height: r.spacingM),

        _buildNameField(r),

        SizedBox(height: r.spacingM),

        _buildActiveSwitch(r),
      ],
    );
  }

  Widget _buildAdmissionNumberField(AppResponsive r) {
    return TextFormField(
      controller: _admissionNumberController,
      enabled: !_isSaving,
      textCapitalization: TextCapitalization.characters,
      decoration: InputDecoration(
        labelText: 'Admission Number',
        prefixIcon: Icon(Icons.badge_outlined, size: r.iconMedium),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Admission number is required';
        }

        return null;
      },
    );
  }

  Widget _buildNameField(AppResponsive r) {
    return TextFormField(
      controller: _nameController,
      enabled: !_isSaving,
      decoration: InputDecoration(
        labelText: 'Student Name',
        prefixIcon: Icon(Icons.person_outline_rounded, size: r.iconMedium),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Student name is required';
        }

        return null;
      },
    );
  }

  Widget _buildActiveSwitch(AppResponsive r) {
    return SwitchListTile(
      value: _isActive,
      onChanged: _isSaving
          ? null
          : (value) {
              setState(() {
                _isActive = value;
              });
            },
      title: Text('Active', style: TextStyle(fontSize: r.body)),
      secondary: Icon(Icons.toggle_on_outlined, size: r.iconMedium),
      contentPadding: EdgeInsets.zero,
    );
  }
}
