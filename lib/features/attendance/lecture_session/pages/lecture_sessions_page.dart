import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:attendance_management_system/core/widgets/tables/tables.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/models/lecture_session.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/pages/create_lecture_session_page.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/pages/lecture_session_details_page.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/providers/lecture_session_provider.dart';

class LectureSessionsPage extends StatefulWidget {
  const LectureSessionsPage({
    super.key,
    required this.courseId,
    required this.courseName,
  });

  final int courseId;
  final String courseName;

  @override
  State<LectureSessionsPage> createState() => _LectureSessionsPageState();
}

class _LectureSessionsPageState extends State<LectureSessionsPage> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LectureSessionProvider>().loadLectureSessions(
        widget.courseId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lecture Sessions',
          style: TextStyle(fontSize: r.titleLarge),
        ),
      ),
      body: Consumer<LectureSessionProvider>(
        builder: (context, provider, child) {
          final sessions = _filterSessions(provider.lectureSessions);

          return Padding(
            padding: EdgeInsets.all(r.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, r),

                SizedBox(height: r.spacingM),

                _buildSearchField(context, r),

                SizedBox(height: r.spacingL),

                Expanded(
                  child: AppDataTable(
                    columns: const [
                      AppTableColumn(label: 'Lecture Session', flex: 2),
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
                    rows: sessions.map((lectureSession) {
                      return AppTableRow(
                        onTap: () {
                          _openDetails(context, lectureSession);
                        },
                        cells: [
                          AppTableCell(Text(lectureSession.lectureSessionName)),
                          AppTableCell(
                            Text(lectureSession.weekNumber.toString()),
                          ),
                          AppTableCell(
                            Text(_formatDate(lectureSession.lectureDate)),
                          ),
                          AppTableCell(
                            Text(
                              '${lectureSession.fromTime} – '
                              '${lectureSession.toTime}',
                            ),
                          ),
                          AppTableCell(
                            Text(
                              _formatDuration(lectureSession.durationMinutes),
                            ),
                          ),
                          AppTableCell(
                            _buildStatus(context, r, lectureSession.status),
                          ),
                          AppTableCell(
                            _buildActions(context, r, lectureSession),
                            alignment: Alignment.center,
                          ),
                        ],
                      );
                    }).toList(),
                    isLoading: provider.isLoading,
                    errorMessage: provider.errorMessage,
                    emptyMessage: _searchQuery.isEmpty
                        ? 'No lecture sessions have been created for ${widget.courseName}.'
                        : 'No lecture sessions match your search.',
                    onRetry: () {
                      provider.loadLectureSessions(widget.courseId);
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
                'Manage lecture sessions',
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
          onPressed: () async {
            final created = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (_) => CreateLectureSessionPage(
                  courseId: widget.courseId,
                  courseName: widget.courseName,
                ),
              ),
            );

            if (created == true && mounted) {
              context.read<LectureSessionProvider>().loadLectureSessions(
                widget.courseId,
              );
            }
          },
          icon: Icon(Icons.add, size: r.buttonIcon),
          label: const Text('Create Lecture Session'),
        ),
      ],
    );
  }

  Widget _buildSearchField(BuildContext context, AppResponsive r) {
    return TextField(
      onChanged: (value) {
        setState(() {
          _searchQuery = value.trim().toLowerCase();
        });
      },
      decoration: InputDecoration(
        hintText: 'Search lecture sessions...',
        prefixIcon: Icon(Icons.search, size: r.iconMedium),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                  });
                },
                icon: const Icon(Icons.clear),
              )
            : null,
      ),
    );
  }

  List<LectureSession> _filterSessions(List<LectureSession> sessions) {
    if (_searchQuery.isEmpty) {
      return sessions;
    }

    return sessions.where((session) {
      final values = [
        session.lectureSessionName,
        session.weekNumber.toString(),
        _formatDate(session.lectureDate),
        session.fromTime,
        session.toTime,
        session.status.name,
      ];

      return values.any((value) => value.toLowerCase().contains(_searchQuery));
    }).toList();
  }

  Widget _buildStatus(
    BuildContext context,
    AppResponsive r,
    LectureSessionStatus status,
  ) {
    return Text(
      _statusLabel(status),
      style: TextStyle(fontSize: r.bodySmall, fontWeight: FontWeight.w500),
    );
  }

  Widget _buildActions(
    BuildContext context,
    AppResponsive r,
    LectureSession lectureSession,
  ) {
    return PopupMenuButton<String>(
      iconSize: r.iconMedium,
      onSelected: (value) async {
        switch (value) {
          case 'details':
            _openDetails(context, lectureSession);
            break;

          case 'start':
            await _startSession(context, lectureSession);
            break;

          case 'complete':
            await _completeSession(context, lectureSession);
            break;

          case 'delete':
            await _deleteSession(context, lectureSession);
            break;
        }
      },
      itemBuilder: (context) {
        final items = <PopupMenuEntry<String>>[
          const PopupMenuItem(value: 'details', child: Text('View Details')),
        ];

        if (lectureSession.isScheduled) {
          items.add(
            const PopupMenuItem(value: 'start', child: Text('Start Lecture')),
          );
        }

        if (lectureSession.isActive) {
          items.add(
            const PopupMenuItem(
              value: 'complete',
              child: Text('Complete Lecture'),
            ),
          );
        }

        items.add(const PopupMenuItem(value: 'delete', child: Text('Delete')));

        return items;
      },
    );
  }

  void _openDetails(BuildContext context, LectureSession lectureSession) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LectureSessionDetailsPage(
          lectureSessionId: lectureSession.id!,
          courseName: widget.courseName,
        ),
      ),
    );
  }

  Future<void> _startSession(
    BuildContext context,
    LectureSession lectureSession,
  ) async {
    final provider = context.read<LectureSessionProvider>();

    final success = await provider.startLectureSession(lectureSession);

    if (!context.mounted) return;

    _showResult(
      context,
      success
          ? 'Lecture session started.'
          : provider.errorMessage ?? 'Failed to start lecture session.',
    );
  }

  Future<void> _completeSession(
    BuildContext context,
    LectureSession lectureSession,
  ) async {
    final provider = context.read<LectureSessionProvider>();

    final success = await provider.completeLectureSession(lectureSession);

    if (!context.mounted) return;

    _showResult(
      context,
      success
          ? 'Lecture session completed.'
          : provider.errorMessage ?? 'Failed to complete lecture session.',
    );
  }

  Future<void> _deleteSession(
    BuildContext context,
    LectureSession lectureSession,
  ) async {
    // Connect this to your existing
    // DeleteConfirmationDialog.
    //
    // We intentionally leave the confirmation UI
    // separate because your project already has
    // a reusable delete dialog.

    final provider = context.read<LectureSessionProvider>();

    final success = await provider.deleteLectureSession(lectureSession);

    if (!context.mounted) return;

    _showResult(
      context,
      success
          ? 'Lecture session deleted.'
          : provider.errorMessage ?? 'Failed to delete lecture session.',
    );
  }

  void _showResult(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _statusLabel(LectureSessionStatus status) {
    switch (status) {
      case LectureSessionStatus.scheduled:
        return 'Scheduled';
      case LectureSessionStatus.active:
        return 'Active';
      case LectureSessionStatus.completed:
        return 'Completed';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
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
}
