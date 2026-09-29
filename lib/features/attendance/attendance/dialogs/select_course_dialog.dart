import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:attendance_management_system/features/courses/models/course.dart';
import 'package:flutter/material.dart';

class SelectCourseDialog extends StatelessWidget {
  const SelectCourseDialog({super.key, required this.courses});

  final List<Course> courses;

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
        'Select Course',
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
                      'No courses available.',
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
  const _CourseOption({required this.course, required this.onTap});

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
            ],
          ),
        ),
      ),
    );
  }
}
