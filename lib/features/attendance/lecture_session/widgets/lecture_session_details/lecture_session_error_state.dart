import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:flutter/material.dart';

class LectureSessionErrorState extends StatelessWidget {
  const LectureSessionErrorState({
    super.key,
    this.message,
  });

  final String? message;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(r.pagePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: r.iconLarge,
              color: colors.onSurfaceVariant,
            ),
            SizedBox(height: r.spacingM),
            Text(
              message ?? 'Lecture session not found.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: r.body,
              ),
            ),
          ],
        ),
      ),
    );
  }
}