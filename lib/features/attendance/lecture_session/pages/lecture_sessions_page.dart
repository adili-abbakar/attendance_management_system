import 'package:attendance_management_system/core/widgets/widgets.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/dialogs/lecture_session_form_dialog.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/helpers/lecture_session_helper.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/widgets/lecture_session_table.dart';
import 'package:attendance_management_system/features/courses/models/course.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/models/lecture_session.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/providers/lecture_session_provider.dart';

class LectureSessionsPage extends StatefulWidget {
  const LectureSessionsPage({super.key, required this.course});

  final Course course;

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
        widget.course.id!,
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
                    course: widget.course,
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
          '${widget.course.title} (${widget.course.code})',
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
          builder: (_) => LectureSessionFormDialog(courseId: widget.course.id!),
        );

        if (!context.mounted) return;

        if (created == true) {
          await context
              .read<LectureSessionProvider>()
              .loadLectureSessionsByCourse(widget.course.id!);
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
        LectureSessionHelper.formatDate(session.lectureDate),
        session.fromTime,
        session.toTime,
        session.status.name,
      ];

      return values.any((value) => value.toLowerCase().contains(_searchQuery));
    }).toList();
  }
}
