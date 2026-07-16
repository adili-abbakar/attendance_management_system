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

  final Function(
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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return AlertDialog(
      title: Text(widget.initialCode == null ? "Add Course" : "Edit Course"),

      content: SizedBox(
        width: width > 600 ? 450 : double.maxFinite,

        child: Form(
          key: _formKey,

          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                TextFormField(
                  controller: codeController,
                  decoration: const InputDecoration(labelText: "Course Code"),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? "Required" : null,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: "Course Title"),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? "Required" : null,
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: level,
                  decoration: const InputDecoration(labelText: "Level"),
                  items: const ['100', '200', '300', '400', '500']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {
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
                    DropdownMenuItem(value: 1, child: Text("Semester 1")),
                    DropdownMenuItem(value: 2, child: Text("Semester 2")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      semester = value!;
                    });
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: sessionController,
                  decoration: const InputDecoration(
                    labelText: "Academic Session",
                    hintText: "2025/2026",
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? "Required" : null,
                ),
              ],
            ),
          ),
        ),
      ),

      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),

        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;

            widget.onSave(
              codeController.text.trim(),
              titleController.text.trim(),
              level,
              semester,
              sessionController.text.trim(),
            );

            Navigator.pop(context);
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
