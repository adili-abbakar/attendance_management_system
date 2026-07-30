import 'package:flutter/material.dart';

class SelectedStudentsBar extends StatelessWidget {
  const SelectedStudentsBar({
    super.key,
    required this.selectedCount,
    required this.onClearSelection,
  });

  final int selectedCount;
  final VoidCallback onClearSelection;

  @override
  Widget build(BuildContext context) {
    if (selectedCount == 0) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final compact = MediaQuery.sizeOf(context).width < 600;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 12,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_rounded, color: colors.primary),

              const SizedBox(width: 10),

              Text(
                '$selectedCount ${selectedCount == 1 ? "student" : "students"} selected',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          FilledButton.tonalIcon(
            onPressed: onClearSelection,
            icon: const Icon(Icons.clear),
            label: Text(compact ? 'Clear' : 'Clear Selection'),
          ),
        ],
      ),
    );
  }
}
