import 'package:attendance_management_system/core/dialogs/delete_confirmation_dialog.dart';
import 'package:attendance_management_system/core/widgets/widgets.dart';
import 'package:attendance_management_system/features/attendance/attendance/pages/active_attendance_page.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/dialogs/lecture_session_form_dialog.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/widgets/lecture_session_table.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/models/lecture_session.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/pages/lecture_session_details_page.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/providers/lecture_session_provider.dart';

class LectureSessionsPage extends StatefulWidget {
  const LectureSessionsPage({
    super.key,
    required this.courseId,
    required this.courseName,
    required this.courseCode,
  });

  final int courseId;
  final String courseName;
  final String courseCode;

  @override
  State<LectureSessionsPage> createState() => _LectureSessionsPageState();
}

class _LectureSessionsPageState extends State<LectureSessionsPage> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LectureSessionProvider>().loadLectureSessionsByCourse(
        widget.courseId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);

    return Scaffold(
      appBar: AppBarWidget(title: 'Lecture Sessions'),
      endDrawer: AppDrawer(),
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
                  child: LectureSessionTable(
                    sessions: sessions,
                    onTap: (session) {
                      _openDetails(context, session);
                    },
                    onUpdate: (session) {
                      showDialog(
                        context: context,
                        builder: (_) => LectureSessionFormDialog(
                          courseId: widget.courseId,
                          initialSession: session,
                        ),
                      );
                    },
                    onDetails: (session) {
                      _openDetails(context, session);
                    },
                    onAttendance: (session) {
                      _viewAttendance(context, session);
                    },
                    onStart: (session) async {
                      await _startSession(context, session);
                    },
                    onComplete: (session) async {
                      await _completeSession(context, session);
                    },
                    onDelete: (session) async {
                      await _showDeleteSessionDialog(context, session);
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
    final isPhone = r.isPhone;

    final headerContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${widget.courseName} (${widget.courseCode})',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: isPhone ? r.titleLarge : r.headline,
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
    );

    final createButton = FilledButton.icon(
      onPressed: () async {
        final created = await showDialog<bool>(
          context: context,
          builder: (_) => LectureSessionFormDialog(courseId: widget.courseId),
        );

        if (!context.mounted) return;

        if (created == true) {
          await context
              .read<LectureSessionProvider>()
              .loadLectureSessionsByCourse(widget.courseId);
        }
      },
      icon: Icon(Icons.add, size: r.buttonIcon),
      label: const Text('Create Lecture Session'),
    );

    if (isPhone) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          headerContent,

          SizedBox(height: r.spacingM),

          SizedBox(width: double.infinity, child: createButton),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: headerContent),

        SizedBox(width: r.spacingM),

        createButton,
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

  void _openDetails(BuildContext context, LectureSession lectureSession) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LectureSessionDetailsPage(
          lectureSessionId: lectureSession.id!,
          courseName: widget.courseName,
          courseCode: widget.courseCode,

          startSession: (session) => _startSession(context, session),

          completeSession: (session) => _completeSession(context, session),

          viewAttendance: (session) => _viewAttendance(context, session),

          updateSession: (session) async {
            await showDialog(
              context: context,
              builder: (_) => LectureSessionFormDialog(
                courseId: widget.courseId,
                initialSession: session,
              ),
            );
          },

          deleteSession: (session) async {
            await _showDeleteSessionDialog(context, session);
          },
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

    if (!success) {
      _showResult(
        context,
        provider.errorMessage ?? 'Failed to start lecture session.',
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ActiveAttendancePage(
          lectureSession: lectureSession.copyWith(
            status: LectureSessionStatus.active,
          ),
          courseName: widget.courseName,
          courseCode: widget.courseCode,
        ),
      ),
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

  Future<void> _showDeleteSessionDialog(
    BuildContext context,
    LectureSession lectureSession,
  ) async {
    await showDialog(
      context: context,
      builder: (_) {
        return DeleteConfirmationDialog(
          title: 'Delete Lecture Session',
          itemName:
              '${widget.courseCode} — ${lectureSession.lectureSessionName}',
          onDelete: () async {
            await _deleteSession(context, lectureSession);
          },
        );
      },
    );
  }

  Future<void> _deleteSession(
    BuildContext context,
    LectureSession lectureSession,
  ) async {
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

  void _viewAttendance(BuildContext context, LectureSession lectureSession) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ActiveAttendancePage(
          lectureSession: lectureSession,
          courseCode: widget.courseCode,
          courseName: widget.courseName,
        ),
      ),
    );
  }

  void _showResult(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
