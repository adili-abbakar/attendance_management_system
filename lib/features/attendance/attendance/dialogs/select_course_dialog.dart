import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:attendance_management_system/features/courses/models/course.dart';
import 'package:flutter/material.dart';

class SelectCourseDialog extends StatelessWidget {
  const SelectCourseDialog({
    super.key,
    required this.courses,
    this.title = 'Select Course',
    this.emptyMessage = 'No courses available.',
  });

  final List<Course> courses;
  final String title;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final screenWidth = MediaQuery.sizeOf(context).width;
    final availableWidth = screenWidth - (r.dialogInset * 2);

    final dialogWidth = availableWidth < r.dialogWidth
        ? availableWidth
        : r.dialogWidth;

    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: r.dialogInset,
        vertical: r.dialogInset,
      ),
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontSize: r.titleLarge,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SizedBox(
        width: dialogWidth,
        child: courses.isEmpty
            ? Padding(
                padding: EdgeInsets.symmetric(vertical: r.spacingXL),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: r.iconLarge,
                      color: colors.onSurfaceVariant,
                    ),
                    SizedBox(height: r.spacingM),
                    Text(
                      emptyMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: r.body,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: courses.map((course) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: r.spacingS),
                      child: _CourseOption(
                        course: course,
                        onTap: () => Navigator.pop(context, course),
                      ),
                    );
                  }).toList(),
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

class _CourseOption extends StatelessWidget {
  const _CourseOption({
    required this.course,
    required this.onTap,
  });

  final Course course;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surfaceBright,
      borderRadius: BorderRadius.circular(r.radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(r.radius),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(r.cardPadding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(r.radius),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(r.spacingS),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(r.radius),
                ),
                child: Icon(
                  Icons.menu_book_outlined,
                  size: r.iconMedium,
                  color: colors.primary,
                ),
              ),
              SizedBox(width: r.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.code,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: r.titleMedium,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                    SizedBox(height: r.spacingXS),
                    Text(
                      course.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: r.bodySmall,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    if (_hasAcademicSession(course)) ...[
                      SizedBox(height: r.spacingS),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: r.iconSmall,
                            color: colors.primary,
                          ),
                          SizedBox(width: r.spacingXS),
                          Expanded(
                            child: Text(
                              course.academicSessionName!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: r.bodySmall,
                                fontWeight: FontWeight.w700,
                                color: colors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (_hasLevel(course)) ...[
                      SizedBox(height: r.spacingXS),
                      Text(
                        course.levelName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: r.caption,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: r.spacingS),
              Icon(
                Icons.chevron_right_rounded,
                size: r.iconMedium,
                color: colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static bool _hasAcademicSession(Course course) {
    return course.academicSessionName != null &&
        course.academicSessionName!.trim().isNotEmpty;
  }

  static bool _hasLevel(Course course) {
    return course.levelName != null &&
        course.levelName!.trim().isNotEmpty;
  }
}
