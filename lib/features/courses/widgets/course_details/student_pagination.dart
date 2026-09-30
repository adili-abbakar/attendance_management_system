import 'package:flutter/material.dart';

class StudentPagination extends StatelessWidget {
  const StudentPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPrevious,
    required this.onNext,
    this.totalItems,
    this.itemsPerPage,
  });

  final int currentPage;
  final int totalPages;

  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  /// Optional values used to show how many items are being paginated.
  final int? totalItems;
  final int? itemsPerPage;

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          OutlinedButton.icon(
            onPressed: currentPage == 1 ? null : onPrevious,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 40),
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            icon: const Icon(
              Icons.chevron_left,
              size: 18,
            ),
            label: const Text('Previous'),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Page $currentPage of $totalPages',
              style: theme.textTheme.bodySmall,
            ),
          ),

          FilledButton.icon(
            onPressed: currentPage >= totalPages ? null : onNext,
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 40),
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            icon: const Icon(
              Icons.chevron_right,
              size: 18,
            ),
            label: const Text('Next'),
          ),
        ],
      ),
    );
  }
}
