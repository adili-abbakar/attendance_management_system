import 'package:flutter/material.dart';

class AppTablePagination {
  const AppTablePagination({
    required this.currentPage,
    required this.itemsPerPage,
    required this.totalItems,
    required this.onPageChanged,
    this.itemsPerPageOptions = const [10, 20, 50, 100],
    this.onItemsPerPageChanged,
  });

  final int currentPage;
  final int itemsPerPage;
  final int totalItems;

  final ValueChanged<int> onPageChanged;

  final List<int> itemsPerPageOptions;

  final ValueChanged<int>? onItemsPerPageChanged;

  int get totalPages {
    if (totalItems <= 0) {
      return 1;
    }

    return (totalItems / itemsPerPage).ceil();
  }

  int get startItem {
    if (totalItems == 0) {
      return 0;
    }

    return ((currentPage - 1) * itemsPerPage) + 1;
  }

  int get endItem {
    final end = currentPage * itemsPerPage;

    return end > totalItems ? totalItems : end;
  }
}
