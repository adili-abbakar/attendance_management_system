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

    final colors = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: colors.primary),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              '$selectedCount ${selectedCount == 1 ? "student" : "students"} selected',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),

          TextButton.icon(
            onPressed: onClearSelection,
            icon: const Icon(Icons.clear),
            label: const Text('Clear Selection'),
          ),
        ],
      ),
    );
  }
}
