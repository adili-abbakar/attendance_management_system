import 'package:flutter/material.dart';

class StudentFilters extends StatelessWidget {
  const StudentFilters({
    super.key,
    required this.showActiveOnly,
    required this.onShowActiveChanged,
    required this.sortAscending,
    required this.onSortChanged,
  });

  final bool showActiveOnly;
  final ValueChanged<bool> onShowActiveChanged;

  final bool sortAscending;
  final ValueChanged<bool> onSortChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: FilterChip(
            showCheckmark: false,
            selected: showActiveOnly,
            elevation: 0,
            pressElevation: 0,
            side: BorderSide(
              color: showActiveOnly ? colors.primary : colors.outlineVariant,
            ),
            backgroundColor: colors.surface,
            selectedColor: colors.surfaceContainerHighest,
            avatar: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              ),
              child: Icon(
                Icons.check_circle_outline,
                key: ValueKey(showActiveOnly),
                size: 18,
                color: showActiveOnly
                    ? colors.primary
                    : colors.onSurfaceVariant,
              ),
            ),
            label: const Text('Active Only'),
            onSelected: onShowActiveChanged,
          ),
        ),

        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: FilterChip(
            showCheckmark: false,
            elevation: 0,
            pressElevation: 0,
            side: BorderSide(color: colors.outlineVariant),
            backgroundColor: colors.surface,
            selectedColor: colors.surfaceContainerHighest,
            avatar: AnimatedRotation(
              turns: sortAscending ? 0.0 : 0.5,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOutCubic,
              child: Icon(
                Icons.arrow_downward,
                size: 18,
                color: colors.primary,
              ),
            ),
            label: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: Text(
                sortAscending ? 'A → Z' : 'Z → A',
                key: ValueKey(sortAscending),
              ),
            ),
            onSelected: (_) => onSortChanged(!sortAscending),
          ),
        ),
      ],
    );
  }
}
