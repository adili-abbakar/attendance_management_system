import 'package:flutter/material.dart';

import 'section_title.dart';

class DashboardSection extends StatelessWidget {
  const DashboardSection({
    super.key,
    required this.title,
    required this.child,
    this.actionText,
    this.onActionPressed,
  });

  final String title;
  final Widget child;
  final String? actionText;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SectionTitle(
            title: title,
            actionText: actionText,
            onActionPressed: onActionPressed,
          ),

          const SizedBox(height: 10),

          child,
        ],
      ),
    );
  }
}
