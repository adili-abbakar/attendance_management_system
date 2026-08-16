import 'package:flutter/material.dart';

import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/models/lecture_session.dart';

class LectureSessionForm extends StatefulWidget {
  const LectureSessionForm({
    super.key,
    required this.courseId,
    required this.onSubmit,
    this.initialSession,
    this.isLoading = false,
  });

  final int courseId;
  final LectureSession? initialSession;
  final bool isLoading;
  final Future<void> Function(LectureSession lectureSession) onSubmit;

  bool get isEditing => initialSession != null;

  @override
  State<LectureSessionForm> createState() => _LectureSessionFormState();
}

class _LectureSessionFormState extends State<LectureSessionForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _weekController;

  late DateTime _lectureDate;
  late String _fromTime;
  late String _toTime;

  String? _generalError;

  static const List<String> _timeOptions = [
    '08:00 AM',
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '01:00 PM',
    '01:30 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:00 PM',
    '06:00 PM',
  ];

  @override
  void initState() {
    super.initState();

    final session = widget.initialSession;

    _weekController = TextEditingController(
      text: session?.weekNumber.toString() ?? '1',
    );

    _lectureDate = session?.lectureDate ?? DateTime.now();

    _fromTime = session?.fromTime ?? '08:00 AM';

    _toTime = session?.toTime ?? '10:00 AM';
  }

  @override
  void dispose() {
    _weekController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_generalError != null) ...[
            _buildError(context, r),
            SizedBox(height: r.spacingM),
          ],

          _buildDateField(context, r),

          SizedBox(height: r.spacingM),

          _buildWeekField(context, r),

          SizedBox(height: r.spacingM),

          Row(
            children: [
              Expanded(
                child: _buildTimeDropdown(
                  context,
                  r,
                  label: 'From',
                  value: _fromTime,
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      _fromTime = value;

                      if (_timeToMinutes(_toTime) <=
                          _timeToMinutes(_fromTime)) {
                        final fromIndex = _timeOptions.indexOf(_fromTime);

                        if (fromIndex >= 0 &&
                            fromIndex + 1 < _timeOptions.length) {
                          _toTime = _timeOptions[fromIndex + 1];
                        }
                      }
                    });
                  },
                ),
              ),
              SizedBox(width: r.spacingM),
              Expanded(
                child: _buildTimeDropdown(
                  context,
                  r,
                  label: 'To',
                  value: _toTime,
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      _toTime = value;
                    });
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: r.spacingM),

          _buildDuration(context, r),

          SizedBox(height: r.spacingXL),

          SizedBox(
            width: double.infinity,
            height: r.buttonHeight,
            child: FilledButton(
              onPressed: widget.isLoading ? null : _submit,
              child: widget.isLoading
                  ? SizedBox(
                      width: r.buttonIcon,
                      height: r.buttonIcon,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      widget.isEditing
                          ? 'Update Lecture Session'
                          : 'Create Lecture Session',
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(BuildContext context, AppResponsive r) {
    return TextFormField(
      readOnly: true,
      controller: TextEditingController(text: _formatDate(_lectureDate)),
      decoration: InputDecoration(
        labelText: 'Lecture Date',
        prefixIcon: Icon(Icons.calendar_today_outlined, size: r.iconMedium),
        suffixIcon: Icon(Icons.arrow_drop_down, size: r.iconMedium),
      ),
      onTap: widget.isLoading ? null : _selectDate,
    );
  }

  Widget _buildWeekField(BuildContext context, AppResponsive r) {
    return TextFormField(
      controller: _weekController,
      keyboardType: TextInputType.number,
      enabled: !widget.isLoading,
      decoration: InputDecoration(
        labelText: 'Week Number',
        hintText: 'Enter week number',
        prefixIcon: Icon(Icons.calendar_view_week_outlined, size: r.iconMedium),
      ),
      validator: (value) {
        final week = int.tryParse(value ?? '');

        if (week == null || week < 1) {
          return 'Enter a valid week number.';
        }

        return null;
      },
    );
  }

  Widget _buildTimeDropdown(
    BuildContext context,
    AppResponsive r, {
    required String label,
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(Icons.access_time_outlined, size: r.iconMedium),
      ),
      items: _timeOptions.map((time) {
        return DropdownMenuItem<String>(value: time, child: Text(time));
      }).toList(),
      onChanged: widget.isLoading ? null : onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Required';
        }

        return null;
      },
    );
  }

  Widget _buildDuration(BuildContext context, AppResponsive r) {
    final duration = _calculateDuration();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(r.cardPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(r.radius),
      ),
      child: Row(
        children: [
          Icon(Icons.timer_outlined, size: r.iconMedium),
          SizedBox(width: r.spacingS),
          Text(
            'Duration',
            style: TextStyle(fontSize: r.body, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Text(
            _formatDuration(duration),
            style: TextStyle(fontSize: r.body, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, AppResponsive r) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(r.cardPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(r.radius),
      ),
      child: Text(
        _generalError!,
        style: TextStyle(
          fontSize: r.body,
          color: Theme.of(context).colorScheme.onErrorContainer,
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _lectureDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selected == null) return;

    setState(() {
      _lectureDate = selected;
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _generalError = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final fromMinutes = _timeToMinutes(_fromTime);
    final toMinutes = _timeToMinutes(_toTime);

    if (toMinutes <= fromMinutes) {
      setState(() {
        _generalError = 'The "To" time must be later than the "From" time.';
      });

      return;
    }

    final now = DateTime.now();

    final existing = widget.initialSession;

    final lectureSession = LectureSession(
      id: existing?.id,
      courseId: widget.courseId,
      sessionNumber: existing?.sessionNumber ?? 1,
      weekNumber: int.parse(_weekController.text.trim()),
      lectureDate: DateTime(
        _lectureDate.year,
        _lectureDate.month,
        _lectureDate.day,
      ),
      fromTime: _fromTime,
      toTime: _toTime,
      durationMinutes: toMinutes - fromMinutes,
      status: existing?.status ?? LectureSessionStatus.scheduled,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      startedAt: existing?.startedAt,
    );

    await widget.onSubmit(lectureSession);
  }

  int _calculateDuration() {
    final difference = _timeToMinutes(_toTime) - _timeToMinutes(_fromTime);

    return difference > 0 ? difference : 0;
  }

  int _timeToMinutes(String time) {
    final parts = time.split(' ');

    if (parts.length != 2) {
      return 0;
    }

    final timePart = parts[0];
    final period = parts[1];

    final hourMinute = timePart.split(':');

    if (hourMinute.length != 2) {
      return 0;
    }

    var hour = int.tryParse(hourMinute[0]) ?? 0;
    final minute = int.tryParse(hourMinute[1]) ?? 0;

    if (period == 'AM') {
      if (hour == 12) {
        hour = 0;
      }
    } else {
      if (hour != 12) {
        hour += 12;
      }
    }

    return hour * 60 + minute;
  }

  String _formatDuration(int minutes) {
    if (minutes <= 0) {
      return '-';
    }

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (hours == 0) {
      return '$remainingMinutes min';
    }

    if (remainingMinutes == 0) {
      return '$hours hr';
    }

    return '$hours hr $remainingMinutes min';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
