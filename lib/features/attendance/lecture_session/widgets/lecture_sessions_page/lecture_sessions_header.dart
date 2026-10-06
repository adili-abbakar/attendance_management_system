import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/dialogs/lecture_session_form_dialog.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/providers/lecture_session_provider.dart';
import 'package:attendance_management_system/features/courses/models/course.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LectureSessionsHeader extends StatelessWidget {
  const LectureSessionsHeader({super.key, required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);
    final isPhone = r.isPhone;

    final headerContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${course.title} (${course.code})',
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
          builder: (_) => LectureSessionFormDialog(courseId: course.id!),
        );

        if (!context.mounted || created != true) {
          return;
        }

        await context
            .read<LectureSessionProvider>()
            .loadLectureSessionsByCourse(course.id!);
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
}
