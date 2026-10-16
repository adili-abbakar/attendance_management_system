import 'package:flutter/material.dart';

class AddStudentFilters extends StatelessWidget {
  const AddStudentFilters({
    super.key,
    required this.sortAscending,
    required this.onSortChanged,
  });

  final bool sortAscending;
  final ValueChanged<bool> onSortChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        FilterChip(
          showCheckmark: false,
          elevation: 0,
          pressElevation: 0,
          side: BorderSide(color: colors.outlineVariant),
          backgroundColor: colors.surface,
          selectedColor: colors.surfaceContainerHighest,
          avatar: AnimatedRotation(
            turns: sortAscending ? 0.0 : 0.5,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOutCubic,
            child: Icon(Icons.arrow_downward, size: 18, color: colors.primary),
          ),
          label: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: Text(
              sortAscending ? 'A → Z' : 'Z → A',
              key: ValueKey(sortAscending),
            ),
          ),
          onSelected: (_) => onSortChanged(!sortAscending),
        ),
      ],
    );
  }
}
