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
      padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
            title: title,
            actionText: actionText,
            onActionPressed: onActionPressed,
          ),

          const SizedBox(height: 16),

          child,
        ],
      ),
    );
  }
}
