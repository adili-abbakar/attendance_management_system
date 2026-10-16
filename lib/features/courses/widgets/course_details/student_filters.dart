import 'package:flutter/material.dart';

class StudentFilters extends StatelessWidget {
  const StudentFilters({
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
      spacing: 8,
      runSpacing: 8,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          child: FilterChip(
            showCheckmark: false,
            elevation: 0,
            pressElevation: 0,
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            side: BorderSide(color: colors.outlineVariant),
            backgroundColor: colors.surface,
            selectedColor: colors.surfaceContainerHighest,
            avatar: AnimatedRotation(
              turns: sortAscending ? 0.0 : 0.5,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: Icon(
                Icons.arrow_downward,
                size: 16,
                color: colors.primary,
              ),
            ),
            label: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.15),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: Text(
                sortAscending ? 'A → Z' : 'Z → A',
                key: ValueKey(sortAscending),
                style: const TextStyle(fontSize: 13),
              ),
            ),
            onSelected: (_) => onSortChanged(!sortAscending),
          ),
        ),
      ],
    );
  }
}
