import 'package:attendance_management_system/features/academic_session/providers/academic_session_provider.dart';
import 'package:attendance_management_system/features/levels/providers/level_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CourseFormDialog extends StatefulWidget {
  const CourseFormDialog({
    super.key,
    this.initialCode,
    this.initialTitle,
    this.initialLevelId,
    this.initialSemester,
    this.initialAcademicSessionId,
    required this.onSave,
    required this.onAddLevel,
    required this.onAddAcademicSession,
  });

  final String? initialCode;
  final String? initialTitle;
  final int? initialLevelId;
  final int? initialSemester;
  final int? initialAcademicSessionId;

  final Future<void> Function() onAddLevel;
  final Future<void> Function() onAddAcademicSession;

  final Future<bool> Function(
    String code,
    String title,
    int levelId,
    int semester,
    int academicSessionId,
  )
  onSave;

  @override
  State<CourseFormDialog> createState() => _CourseFormDialogState();
}

class _CourseFormDialogState extends State<CourseFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController codeController;
  late final TextEditingController titleController;

  late int levelId;
  late int semester;
  late int academicSessionId;

  bool _isSaving = false;
  String? _generalError;

  @override
  void initState() {
    super.initState();

    codeController = TextEditingController(text: widget.initialCode ?? '');
    titleController = TextEditingController(text: widget.initialTitle ?? '');

    levelId = widget.initialLevelId ?? 0;
    academicSessionId = widget.initialAcademicSessionId ?? 0;
    semester = widget.initialSemester ?? 1;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<LevelProvider>().loadLevels();
      await context.read<AcademicSessionProvider>().loadAcademicSessions();
    });
  }

  @override
  void dispose() {
    codeController.dispose();
    titleController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _generalError = null;
    });

    final success = await widget.onSave(
      codeController.text.trim(),
      titleController.text.trim(),
      levelId,
      semester,
      academicSessionId,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      _generalError =
          'This course already exists for the selected level, semester and academic session.';
      _isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final levelProvider = context.watch<LevelProvider>();
    final sessionProvider = context.watch<AcademicSessionProvider>();

    final levels = levelProvider.levels;
    final sessions = sessionProvider.academicSessions;

    if (levels.isNotEmpty && !levels.any((level) => level.id == levelId)) {
      levelId = levels.first.id!;
    }

    if (sessions.isNotEmpty &&
        !sessions.any((session) => session.id == academicSessionId)) {
      academicSessionId = sessions.first.id!;
    }

    return AlertDialog(
      title: Text(widget.initialCode == null ? 'Add Course' : 'Edit Course'),
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
                  controller: codeController,
                  enabled: !_isSaving,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(labelText: 'Course Code'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Course code is required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: titleController,
                  enabled: !_isSaving,
                  decoration: const InputDecoration(labelText: 'Course Title'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Course title is required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<int>(
                  value: levels.isEmpty ? null : levelId,
                  decoration: const InputDecoration(labelText: 'Level'),
                  items: levels
                      .map(
                        (level) => DropdownMenuItem(
                          value: level.id,
                          child: Text(level.name),
                        ),
                      )
                      .toList(),
                  onChanged: _isSaving
                      ? null
                      : (value) {
                          if (value == null) return;

                          setState(() {
                            levelId = value;
                          });
                        },
                ),

                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _isSaving
                        ? null
                        : () async {
                            await widget.onAddLevel();

                            if (!mounted) return;

                            await context.read<LevelProvider>().loadLevels();
                          },
                    icon: const Icon(Icons.add),
                    label: const Text('Add New Level'),
                  ),
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<int>(
                  value: semester,
                  decoration: const InputDecoration(labelText: 'Semester'),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('1st Semester')),
                    DropdownMenuItem(value: 2, child: Text('2nd Semester')),
                  ],
                  onChanged: _isSaving
                      ? null
                      : (value) {
                          if (value == null) return;

                          setState(() {
                            semester = value;
                          });
                        },
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<int>(
                  value: sessions.isEmpty ? null : academicSessionId,
                  decoration: const InputDecoration(
                    labelText: 'Academic Session',
                  ),
                  items: sessions
                      .map(
                        (session) => DropdownMenuItem(
                          value: session.id,
                          child: Text(session.name),
                        ),
                      )
                      .toList(),
                  onChanged: _isSaving
                      ? null
                      : (value) {
                          if (value == null) return;

                          setState(() {
                            academicSessionId = value;
                          });
                        },
                ),

                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _isSaving
                        ? null
                        : () async {
                            await widget.onAddAcademicSession();

                            if (!mounted) return;

                            await context
                                .read<AcademicSessionProvider>()
                                .loadAcademicSessions();
                          },
                    icon: const Icon(Icons.add),
                    label: const Text('Add New Academic Session'),
                  ),
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
