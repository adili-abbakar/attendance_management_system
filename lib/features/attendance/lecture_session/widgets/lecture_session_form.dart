import 'package:flutter/material.dart';

import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:attendance_management_system/features/attendance/models/lecture_session.dart';

class AttendanceSessionForm extends StatefulWidget {
  const AttendanceSessionForm({
    super.key,
    this.initialSession,
    required this.onSubmit,
    this.isLoading = false,
  });

  final AttendanceSession? initialSession;

  final Future<void> Function(AttendanceSession session) onSubmit;

  final bool isLoading;

  bool get isEditing => initialSession != null;

  @override
  State<AttendanceSessionForm> createState() => _AttendanceSessionFormState();
}

class _AttendanceSessionFormState extends State<AttendanceSessionForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _sessionNameController;
  late final TextEditingController _weekNumberController;

  late DateTime _lectureDate;

  String? _fromTime;
  String? _toTime;

  final List<String> _availableTimes = const [
    '8:00 AM',
    '10:00 AM',
    '12:00 PM',
    '1:30 PM',
    '2:00 PM',
    '4:00 PM',
    '6:00 PM',
  ];

  @override
  void initState() {
    super.initState();

    final session = widget.initialSession;

    _sessionNameController = TextEditingController(text: session?.name ?? '');

    _weekNumberController = TextEditingController(
      text: session?.weekNumber.toString() ?? '',
    );

    _lectureDate = session?.lectureDate ?? DateTime.now();

    _fromTime = session?.fromTime;
    _toTime = session?.toTime;
  }

  @override
  void dispose() {
    _sessionNameController.dispose();
    _weekNumberController.dispose();
    super.dispose();
  }

  String? get _durationText {
    if (_fromTime == null || _toTime == null) {
      return null;
    }

    final from = _timeToMinutes(_fromTime!);
    final to = _timeToMinutes(_toTime!);

    if (to <= from) {
      return null;
    }

    final difference = to - from;
    final hours = difference ~/ 60;
    final minutes = difference % 60;

    if (hours == 0) {
      return '$minutes minutes';
    }

    if (minutes == 0) {
      return hours == 1 ? '1 hour' : '$hours hours';
    }

    return '$hours hour${hours == 1 ? '' : 's'} '
        '$minutes minutes';
  }

  int _timeToMinutes(String time) {
    final parts = time.split(' ');
    final timePart = parts[0];
    final period = parts[1];

    final hourMinute = timePart.split(':');

    var hour = int.parse(hourMinute[0]);
    final minute = int.parse(hourMinute[1]);

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

  Future<void> _pickLectureDate() async {
    final r = AppResponsive.of(context);

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _lectureDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null) {
      return;
    }

    setState(() {
      _lectureDate = selectedDate;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_fromTime == null) {
      _showValidationMessage('Please select the starting time.');
      return;
    }

    if (_toTime == null) {
      _showValidationMessage('Please select the ending time.');
      return;
    }

    final from = _timeToMinutes(_fromTime!);
    final to = _timeToMinutes(_toTime!);

    if (to <= from) {
      _showValidationMessage(
        'The ending time must be later than the starting time.',
      );
      return;
    }

    final weekNumber = int.tryParse(_weekNumberController.text.trim());

    if (weekNumber == null || weekNumber <= 0) {
      return;
    }

    final existing = widget.initialSession;

    if (existing == null) {
      // Creation is handled by the parent/provider.
      // The parent supplies the complete AttendanceSession.
      return;
    }

    final updatedSession = existing.copyWith(
      name: _sessionNameController.text.trim(),
      weekNumber: weekNumber,
      lectureDate: _lectureDate,
      fromTime: _fromTime,
      toTime: _toTime,
      updatedAt: DateTime.now(),
    );

    await widget.onSubmit(updatedSession);
  }

  void _showValidationMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Session Information',
            style: TextStyle(
              fontSize: r.titleLarge,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: r.spacingM),

          TextFormField(
            controller: _sessionNameController,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Session Name',
              hintText: 'Attendance Session',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Session name is required.';
              }

              return null;
            },
          ),

          SizedBox(height: r.spacingM),

          TextFormField(
            controller: _weekNumberController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Week Number',
              hintText: 'Enter week number',
            ),
            validator: (value) {
              final number = int.tryParse(value?.trim() ?? '');

              if (number == null || number <= 0) {
                return 'Enter a valid week number.';
              }

              return null;
            },
          ),

          SizedBox(height: r.spacingM),

          InkWell(
            onTap: widget.isLoading ? null : _pickLectureDate,
            borderRadius: BorderRadius.circular(r.radius),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Lecture Date',
                suffixIcon: Icon(Icons.calendar_today_outlined),
              ),
              child: Text(
                _formatDate(_lectureDate),
                style: TextStyle(fontSize: r.body),
              ),
            ),
          ),

          SizedBox(height: r.spacingM),

          if (r.isPhone)
            Column(
              children: [
                _buildFromTimeField(r),
                SizedBox(height: r.spacingM),
                _buildToTimeField(r),
              ],
            )
          else
            Row(
              children: [
                Expanded(child: _buildFromTimeField(r)),
                SizedBox(width: r.spacingM),
                Expanded(child: _buildToTimeField(r)),
              ],
            ),

          if (_durationText != null) ...[
            SizedBox(height: r.spacingM),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(r.cardPadding),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(r.radius),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule_outlined, size: r.iconMedium),
                  SizedBox(width: r.spacingS),
                  Text(
                    'Duration: ',
                    style: TextStyle(
                      fontSize: r.body,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(_durationText!, style: TextStyle(fontSize: r.body)),
                ],
              ),
            ),
          ],

          SizedBox(height: r.spacingL),

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
                      widget.isEditing ? 'Update Session' : 'Create Session',
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFromTimeField(AppResponsive r) {
    return DropdownButtonFormField<String>(
      initialValue: _fromTime,
      decoration: const InputDecoration(labelText: 'From'),
      items: _availableTimes
          .map(
            (time) => DropdownMenuItem<String>(value: time, child: Text(time)),
          )
          .toList(),
      onChanged: widget.isLoading
          ? null
          : (value) {
              setState(() {
                _fromTime = value;
              });
            },
      validator: (value) {
        if (value == null) {
          return 'Select starting time.';
        }

        return null;
      },
    );
  }

  Widget _buildToTimeField(AppResponsive r) {
    return DropdownButtonFormField<String>(
      initialValue: _toTime,
      decoration: const InputDecoration(labelText: 'To'),
      items: _availableTimes
          .map(
            (time) => DropdownMenuItem<String>(value: time, child: Text(time)),
          )
          .toList(),
      onChanged: widget.isLoading
          ? null
          : (value) {
              setState(() {
                _toTime = value;
              });
            },
      validator: (value) {
        if (value == null) {
          return 'Select ending time.';
        }

        return null;
      },
    );
  }
}
