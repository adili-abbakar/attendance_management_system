import 'package:flutter/material.dart';

class AddStudentPagination extends StatelessWidget {
  const AddStudentPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPrevious,
    required this.onNext,
  });

  final int currentPage;
  final int totalPages;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) {
      return const SizedBox.shrink();
    }

    final compact = MediaQuery.sizeOf(context).width < 500;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 12,
        children: [
          OutlinedButton.icon(
            onPressed: currentPage == 1 ? null : onPrevious,
            icon: const Icon(Icons.chevron_left),
            label: Text(compact ? 'Prev' : 'Previous'),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              compact
                  ? '$currentPage / $totalPages'
                  : 'Page $currentPage of $totalPages',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),

          FilledButton.icon(
            onPressed: currentPage >= totalPages ? null : onNext,
            icon: const Icon(Icons.chevron_right),
            label: const Text('Next'),
          ),
        ],
      ),
    );
  }
}
