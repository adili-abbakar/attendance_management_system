import 'package:flutter/material.dart';

class CourseFormDialog extends StatefulWidget {
  const CourseFormDialog({
    super.key,
    this.initialCode,
    this.initialTitle,
    this.initialLevel,
    this.initialSemester,
    this.initialSession,
    required this.onSave,
  });

  final String? initialCode;
  final String? initialTitle;
  final String? initialLevel;
  final int? initialSemester;
  final String? initialSession;

  final Future<bool> Function(
    String code,
    String title,
    String level,
    int semester,
    String session,
  )
  onSave;

  @override
  State<CourseFormDialog> createState() => _CourseFormDialogState();
}

class _CourseFormDialogState extends State<CourseFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController codeController;
  late final TextEditingController titleController;
  late final TextEditingController sessionController;

  late String level;
  late int semester;

  bool _isSaving = false;

  String? _generalError;

  @override
  void initState() {
    super.initState();

    codeController = TextEditingController(text: widget.initialCode ?? '');

    titleController = TextEditingController(text: widget.initialTitle ?? '');

    sessionController = TextEditingController(
      text: widget.initialSession ?? '',
    );

    level = widget.initialLevel ?? '100';
    semester = widget.initialSemester ?? 1;
  }

  @override
  void dispose() {
    codeController.dispose();
    titleController.dispose();
    sessionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _generalError = null;
      _isSaving = true;
    });

    final success = await widget.onSave(
      codeController.text.trim(),
      titleController.text.trim(),
      level,
      semester,
      sessionController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      _generalError =
          'This course already exists for the selected semester and academic session.';
      _isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return AlertDialog(
      title: Text(widget.initialCode == null ? "Add Course" : "Edit Course"),

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
                  controller: codeController,
                  enabled: !_isSaving,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(labelText: "Course Code"),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Course code is required";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: titleController,
                  enabled: !_isSaving,
                  decoration: const InputDecoration(labelText: "Course Title"),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Course title is required";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: level,
                  decoration: const InputDecoration(labelText: "Level"),
                  items: const ['100', '200', '300', '400', '500']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: _isSaving
                      ? null
                      : (value) {
                          setState(() {
                            level = value!;
                          });
                        },
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<int>(
                  value: semester,
                  decoration: const InputDecoration(labelText: "Semester"),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text("1st Semester")),
                    DropdownMenuItem(value: 2, child: Text("2nd Semester")),
                  ],
                  onChanged: _isSaving
                      ? null
                      : (value) {
                          setState(() {
                            semester = value!;
                          });
                        },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: sessionController,
                  enabled: !_isSaving,
                  decoration: const InputDecoration(
                    labelText: "Academic Session",
                    hintText: "2025/2026",
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Academic session is required";
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
