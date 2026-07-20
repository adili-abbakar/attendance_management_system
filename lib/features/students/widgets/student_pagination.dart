import 'package:flutter/material.dart';

class StudentPagination extends StatelessWidget {
  const StudentPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.onPrevious,
    required this.onNext,
  });

  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;

  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    if (totalItems == 0) {
      return const SizedBox.shrink();
    }

    final start = ((currentPage - 1) * itemsPerPage) + 1;
    final end = (currentPage * itemsPerPage).clamp(0, totalItems);

    return Row(
      children: [
        Text('Showing $start-$end of $totalItems students'),

        const Spacer(),

        OutlinedButton.icon(
          onPressed: currentPage == 1 ? null : onPrevious,
          icon: const Icon(Icons.chevron_left),
          label: const Text('Previous'),
        ),

        const SizedBox(width: 12),

        Text(
          'Page $currentPage of $totalPages',
          style: Theme.of(context).textTheme.titleSmall,
        ),

        const SizedBox(width: 12),

        OutlinedButton.icon(
          onPressed: currentPage == totalPages ? null : onNext,
          icon: const Icon(Icons.chevron_right),
          label: const Text('Next'),
        ),
      ],
    );
  }
}
