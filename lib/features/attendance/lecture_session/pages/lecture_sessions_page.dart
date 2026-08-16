import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:attendance_management_system/core/widgets/tables/tables.dart';
import 'package:attendance_management_system/features/attendance/providers/attendance_provider.dart';
import 'package:attendance_management_system/features/attendance/pages/create_lecture_session_page.dart';

class AttendanceSessionsPage extends StatefulWidget {
  const AttendanceSessionsPage({
    super.key,
    required this.courseId,
    required this.courseName,
  });

  final int courseId;
  final String courseName;

  @override
  State<AttendanceSessionsPage> createState() => _AttendanceSessionsPageState();
}

class _AttendanceSessionsPageState extends State<AttendanceSessionsPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceProvider>().loadSessions(widget.courseId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Attendance Sessions',
          style: TextStyle(fontSize: r.titleLarge),
        ),
      ),
      body: Consumer<AttendanceProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding: EdgeInsets.all(r.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, r),
                SizedBox(height: r.spacingL),
                Expanded(
                  child: AppDataTable(
                    columns: const [
                      AppTableColumn(label: 'Session', flex: 2),
                      AppTableColumn(label: 'Week'),
                      AppTableColumn(label: 'Date'),
                      AppTableColumn(label: 'Time', flex: 2),
                      AppTableColumn(label: 'Duration'),
                      AppTableColumn(label: 'Status'),
                      AppTableColumn(
                        label: 'Actions',
                        width: 100,
                        alignment: Alignment.center,
                      ),
                    ],
                    rows: provider.sessions.map((session) {
                      return AppTableRow(
                        onTap: () {
                          // Details page will be added next.
                        },
                        cells: [
                          AppTableCell(Text(session.name)),
                          AppTableCell(Text(session.weekNumber.toString())),
                          AppTableCell(Text(_formatDate(session.lectureDate))),
                          AppTableCell(
                            Text(
                              '${session.fromTime} – '
                              '${session.toTime}',
                            ),
                          ),
                          AppTableCell(
                            Text(
                              _formatDuration(session.fromTime, session.toTime),
                            ),
                          ),
                          AppTableCell(
                            _buildStatus(context, r, session.status),
                          ),
                          AppTableCell(
                            _buildActions(context, r, session),
                            alignment: Alignment.center,
                          ),
                        ],
                      );
                    }).toList(),
                    isLoading: provider.isLoading,
                    errorMessage: provider.errorMessage,
                    emptyMessage:
                        'No attendance sessions have been created for ${widget.courseName}.',
                    onRetry: () {
                      provider.loadSessions(widget.courseId);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppResponsive r) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.courseName,
                style: TextStyle(
                  fontSize: r.headline,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: r.spacingXS),
              Text(
                'Attendance Sessions',
                style: TextStyle(
                  fontSize: r.body,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: r.spacingM),
        FilledButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CreateAttendanceSessionPage(
                  courseId: widget.courseId,
                  courseName: widget.courseName,
                ),
              ),
            );
          },
          icon: Icon(Icons.add, size: r.buttonIcon),
          label: const Text('Create Session'),
        ),
      ],
    );
  }

  Widget _buildStatus(BuildContext context, AppResponsive r, dynamic status) {
    return Text(
      status.toString().split('.').last,
      style: TextStyle(fontSize: r.bodySmall),
    );
  }

  Widget _buildActions(BuildContext context, AppResponsive r, dynamic session) {
    return PopupMenuButton<String>(
      iconSize: r.iconMedium,
      onSelected: (value) {
        // Edit, details, start, delete
        // will be connected as those pages/dialogs
        // are implemented.
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'details', child: Text('View Details')),
        PopupMenuItem(value: 'edit', child: Text('Edit')),
        PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatDuration(String from, String to) {
    final fromMinutes = _timeToMinutes(from);
    final toMinutes = _timeToMinutes(to);

    final difference = toMinutes - fromMinutes;

    if (difference <= 0) {
      return '-';
    }

    final hours = difference ~/ 60;
    final minutes = difference % 60;

    if (hours == 0) {
      return '$minutes min';
    }

    if (minutes == 0) {
      return '$hours hr';
    }

    return '$hours hr $minutes min';
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
    } else if (hour != 12) {
      hour += 12;
    }

    return hour * 60 + minute;
  }
}
