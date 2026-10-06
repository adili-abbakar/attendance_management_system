import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:attendance_management_system/core/widgets/widgets.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/helpers/lecture_session_helper.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/models/lecture_session.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/providers/lecture_session_provider.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/widgets/lecture_sessions_page/widgets.dart';
import 'package:attendance_management_system/features/courses/models/course.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LectureSessionsPage extends StatefulWidget {
  const LectureSessionsPage({
    super.key,
    required this.course,
  });

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
      if (!mounted) {
        return;
      }

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
      endDrawer: const AppDrawer(),
      body: Consumer<LectureSessionProvider>(
        builder: (context, provider, child) {
          final sessions = _filterSessions(provider.lectureSessions);

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(r.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LectureSessionsHeader(
                  course: widget.course,
                ),
                SizedBox(height: r.spacingM),
                LectureSessionsSearchField(
                  value: _searchQuery,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.trim().toLowerCase();
                    });
                  },
                  onClear: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                ),
                SizedBox(height: r.spacingL),
                LectureSessionTable(
                  sessions: sessions,
                  course: widget.course,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<LectureSession> _filterSessions(
    List<LectureSession> sessions,
  ) {
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

      return values.any(
        (value) => value.toLowerCase().contains(_searchQuery),
      );
    }).toList();
  }
}