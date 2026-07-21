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
    if (totalItems == 0) return const SizedBox.shrink();

    final width = MediaQuery.sizeOf(context).width;

    final start = ((currentPage - 1) * itemsPerPage) + 1;
    final end = (currentPage * itemsPerPage).clamp(0, totalItems);

    final infoText = Text(
      'Showing $start-$end of $totalItems students',
      style: Theme.of(context).textTheme.bodyMedium,
    );

    final pageIndicator = Text(
      'Page $currentPage of $totalPages',
      style: Theme.of(context).textTheme.titleSmall,
    );

    final previousButton = OutlinedButton.icon(
      onPressed: currentPage == 1 ? null : onPrevious,
      icon: const Icon(Icons.chevron_left),
      label: const Text('Previous'),
    );

    final nextButton = OutlinedButton.icon(
      onPressed: currentPage == totalPages ? null : onNext,
      icon: const Icon(Icons.chevron_right),
      label: const Text('Next'),
    );

    // ===========================
    // Phone Layout
    // ===========================
    if (width < 500) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          infoText,
          const SizedBox(height: 16),

          Center(child: pageIndicator),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(child: previousButton),
              const SizedBox(width: 12),
              Expanded(child: nextButton),
            ],
          ),
        ],
      );
    }

    // ===========================
    // Tablet Layout
    // ===========================
    if (width < 700) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          infoText,
          const SizedBox(height: 12),

          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [previousButton, pageIndicator, nextButton],
            ),
          ),
        ],
      );
    }

    // ===========================
    // Desktop Layout
    // ===========================
    return Row(
      children: [
        infoText,
        const Spacer(),
        previousButton,
        const SizedBox(width: 12),
        pageIndicator,
        const SizedBox(width: 12),
        nextButton,
      ],
    );
  }
}
