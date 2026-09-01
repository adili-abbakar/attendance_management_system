import 'package:attendance_management_system/core/dialogs/app_form_dialog.dart';
import 'package:attendance_management_system/core/responsive/app_responsive.dart';
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

  bool get isEditing => initialCode != null;

  @override
  State<CourseFormDialog> createState() => _CourseFormDialogState();
}

class _CourseFormDialogState extends State<CourseFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _codeController;
  late final TextEditingController _titleController;

  late int _levelId;
  late int _semester;
  late int _academicSessionId;

  bool _isSaving = false;
  String? _generalError;

  @override
  void initState() {
    super.initState();

    _codeController = TextEditingController(text: widget.initialCode ?? '');

    _titleController = TextEditingController(text: widget.initialTitle ?? '');

    _levelId = widget.initialLevelId ?? 0;
    _semester = widget.initialSemester ?? 1;
    _academicSessionId = widget.initialAcademicSessionId ?? 0;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      await context.read<LevelProvider>().loadLevels();
      await context.read<AcademicSessionProvider>().loadAcademicSessions();
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;

    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_levelId == 0) {
      setState(() {
        _generalError = 'Please select a level.';
      });
      return;
    }

    if (_academicSessionId == 0) {
      setState(() {
        _generalError = 'Please select an academic session.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _generalError = null;
    });

    final success = await widget.onSave(
      _codeController.text.trim(),
      _titleController.text.trim(),
      _levelId,
      _semester,
      _academicSessionId,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
      return;
    }

    setState(() {
      _generalError =
          'This course already exists for the selected level, '
          'semester and academic session.';
      _isSaving = false;
    });
  }

  Future<void> _addLevel() async {
    if (_isSaving) return;

    await widget.onAddLevel();

    if (!mounted) return;

    await context.read<LevelProvider>().loadLevels();
  }

  Future<void> _addAcademicSession() async {
    if (_isSaving) return;

    await widget.onAddAcademicSession();

    if (!mounted) return;

    await context.read<AcademicSessionProvider>().loadAcademicSessions();
  }

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);

    final levelProvider = context.watch<LevelProvider>();
    final sessionProvider = context.watch<AcademicSessionProvider>();

    final levels = levelProvider.levels;
    final sessions = sessionProvider.academicSessions;

    if (levels.isNotEmpty && !levels.any((level) => level.id == _levelId)) {
      _levelId = levels.first.id!;
    }

    if (sessions.isNotEmpty &&
        !sessions.any((session) => session.id == _academicSessionId)) {
      _academicSessionId = sessions.first.id!;
    }

    return AppFormDialog(
      title: widget.isEditing ? 'Edit Course' : 'Add Course',
      formKey: _formKey,
      isSaving: _isSaving,
      errorMessage: _generalError,
      saveButtonText: widget.isEditing ? 'Update' : 'Save',
      savingButtonText: widget.isEditing ? 'Updating...' : 'Saving...',
      saveIcon: widget.isEditing ? Icons.edit_rounded : Icons.save_rounded,
      onSave: _save,
      children: [
        _buildCourseCodeField(r),

        SizedBox(height: r.spacingM),

        _buildCourseTitleField(r),

        SizedBox(height: r.spacingM),

        _buildLevelField(r, levels),

        _buildAddLevelButton(r),

        SizedBox(height: r.spacingM),

        _buildSemesterField(r),

        SizedBox(height: r.spacingM),

        _buildAcademicSessionField(r, sessions),

        _buildAddAcademicSessionButton(r),
      ],
    );
  }

  Widget _buildCourseCodeField(AppResponsive r) {
    return TextFormField(
      controller: _codeController,
      enabled: !_isSaving,
      textCapitalization: TextCapitalization.characters,
      decoration: InputDecoration(
        labelText: 'Course Code',
        prefixIcon: Icon(Icons.code_rounded, size: r.iconMedium),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Course code is required';
        }

        return null;
      },
    );
  }

  Widget _buildCourseTitleField(AppResponsive r) {
    return TextFormField(
      controller: _titleController,
      enabled: !_isSaving,
      decoration: InputDecoration(
        labelText: 'Course Title',
        prefixIcon: Icon(Icons.menu_book_outlined, size: r.iconMedium),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Course title is required';
        }

        return null;
      },
    );
  }

  Widget _buildLevelField(AppResponsive r, List levels) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return DropdownMenu<int>(
          width: constraints.maxWidth,
          expandedInsets: EdgeInsets.zero,
          initialSelection: levels.isEmpty ? null : _levelId,
          enabled: !_isSaving,

          label: const Text('Level'),

          leadingIcon: Icon(Icons.school_outlined, size: r.iconMedium),

          textStyle: TextStyle(fontSize: r.body),

          menuHeight: 300,

          dropdownMenuEntries: levels
              .map(
                (level) => DropdownMenuEntry<int>(
                  value: level.id,
                  label: level.name,
                  style: ButtonStyle(
                    textStyle: WidgetStatePropertyAll(
                      TextStyle(fontSize: r.body),
                    ),
                  ),
                ),
              )
              .toList(),

          onSelected: _isSaving
              ? null
              : (value) {
                  if (value == null) return;

                  setState(() {
                    _levelId = value;
                  });
                },
        );
      },
    );
  }

  Widget _buildAddLevelButton(AppResponsive r) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        style: TextButton.styleFrom(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.symmetric(
            horizontal: r.spacingXS,
            vertical: r.spacingXS,
          ),
        ),
        onPressed: _isSaving ? null : _addLevel,
        icon: Icon(Icons.add_rounded, size: r.buttonIcon),
        label: Text('Add New Level', style: TextStyle(fontSize: r.body)),
      ),
    );
  }

  Widget _buildSemesterField(AppResponsive r) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return DropdownMenu<int>(
          width: constraints.maxWidth,
          expandedInsets: EdgeInsets.zero,
          initialSelection: _semester,
          enabled: !_isSaving,

          label: const Text('Semester'),

          leadingIcon: Icon(Icons.calendar_month_outlined, size: r.iconMedium),

          textStyle: TextStyle(fontSize: r.body),

          dropdownMenuEntries: const [
            DropdownMenuEntry<int>(value: 1, label: '1st Semester'),
            DropdownMenuEntry<int>(value: 2, label: '2nd Semester'),
          ],

          onSelected: _isSaving
              ? null
              : (value) {
                  if (value == null) return;

                  setState(() {
                    _semester = value;
                  });
                },
        );
      },
    );
  }

  Widget _buildAcademicSessionField(AppResponsive r, List sessions) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return DropdownMenu<int>(
          width: constraints.maxWidth,
          expandedInsets: EdgeInsets.zero,
          initialSelection: sessions.isEmpty ? null : _academicSessionId,
          enabled: !_isSaving,

          label: const Text('Academic Session'),

          leadingIcon: Icon(Icons.school_rounded, size: r.iconMedium),

          textStyle: TextStyle(fontSize: r.body),

          menuHeight: 300,

          dropdownMenuEntries: sessions
              .map(
                (session) => DropdownMenuEntry<int>(
                  value: session.id,
                  label: session.name,
                  style: ButtonStyle(
                    textStyle: WidgetStatePropertyAll(
                      TextStyle(fontSize: r.body),
                    ),
                  ),
                ),
              )
              .toList(),

          onSelected: _isSaving
              ? null
              : (value) {
                  if (value == null) return;

                  setState(() {
                    _academicSessionId = value;
                  });
                },
        );
      },
    );
  }

  Widget _buildAddAcademicSessionButton(AppResponsive r) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        style: TextButton.styleFrom(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.symmetric(
            horizontal: r.spacingXS,
            vertical: r.spacingXS,
          ),
        ),
        onPressed: _isSaving ? null : _addAcademicSession,
        icon: Icon(Icons.add_rounded, size: r.buttonIcon),
        label: Text(
          'Add New Academic Session',
          style: TextStyle(fontSize: r.body),
        ),
      ),
    );
  }
}
