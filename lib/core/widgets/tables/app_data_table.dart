import 'package:flutter/material.dart';

import 'package:attendance_management_system/core/responsive/app_responsive.dart';

import 'app_table_cell.dart';
import 'app_table_column.dart';
import 'app_table_pagination.dart';
import 'app_table_row.dart';

class AppDataTable extends StatelessWidget {
  const AppDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.isLoading = false,
    this.emptyMessage = 'No data available.',
    this.errorMessage,
    this.onRetry,
    this.pagination,
  });

  final List<AppTableColumn> columns;
  final List<AppTableRow> rows;

  final bool isLoading;

  final String emptyMessage;

  final String? errorMessage;

  final VoidCallback? onRetry;

  /// If null, pagination is not displayed.
  final AppTablePagination? pagination;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(r.radius),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTable(context, r),
          if (pagination != null) _buildPagination(context, r),
        ],
      ),
    );
  }

  Widget _buildTable(BuildContext context, AppResponsive r) {
    if (isLoading) {
      return SizedBox(
        height: r.tableRowHeight * 3,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return _buildErrorState(context, r);
    }

    if (rows.isEmpty) {
      return _buildEmptyState(context, r);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(context, r),
                ...rows.map((row) => _buildRow(context, r, row)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, AppResponsive r) {
    return Container(
      height: r.tableHeadingHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Row(
        children: [
          for (final column in columns)
            _buildColumnContainer(
              r: r,
              column: column,
              child: Text(
                column.label,
                textAlign: _textAlign(column.alignment),
                style: TextStyle(fontSize: r.body, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, AppResponsive r, AppTableRow row) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: row.onTap,
        child: Container(
          height: r.tableRowHeight,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: Row(
            children: [
              for (int i = 0; i < columns.length; i++)
                _buildColumnContainer(
                  r: r,
                  column: columns[i],
                  child: _buildCell(row.cells, i),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCell(List<AppTableCell> cells, int index) {
    if (index >= cells.length) {
      return const SizedBox.shrink();
    }

    return Align(alignment: cells[index].alignment, child: cells[index].child);
  }

  Widget _buildColumnContainer({
    required AppResponsive r,
    required AppTableColumn column,
    required Widget child,
  }) {
    final horizontalPadding = r.tableColumnSpacing / 2;

    final content = Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Align(alignment: column.alignment, child: child),
    );

    if (column.width != null) {
      return SizedBox(width: column.width, child: content);
    }

    return Expanded(flex: column.flex, child: content);
  }

  Widget _buildEmptyState(BuildContext context, AppResponsive r) {
    return SizedBox(
      width: double.infinity,
      height: r.tableRowHeight * 2,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(r.pagePadding),
          child: Text(
            emptyMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: r.body,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, AppResponsive r) {
    return SizedBox(
      width: double.infinity,
      height: r.tableRowHeight * 2,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(r.pagePadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: r.body,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              if (onRetry != null) ...[
                SizedBox(height: r.spacingS),
                TextButton(onPressed: onRetry, child: const Text('Retry')),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPagination(BuildContext context, AppResponsive r) {
    final p = pagination!;

    if (p.totalItems == 0) {
      return _buildPaginationBar(context, r, p, showPages: false);
    }

    return _buildPaginationBar(context, r, p, showPages: true);
  }

  Widget _buildPaginationBar(
    BuildContext context,
    AppResponsive r,
    AppTablePagination p, {
    required bool showPages,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: r.pagePadding,
        vertical: r.spacingS,
      ),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: r.spacingM,
        runSpacing: r.spacingS,
        children: [
          _buildItemRange(context, r, p),
          if (p.onItemsPerPageChanged != null)
            _buildItemsPerPage(context, r, p),
          if (showPages) _buildPageControls(context, r, p),
        ],
      ),
    );
  }

  Widget _buildItemRange(
    BuildContext context,
    AppResponsive r,
    AppTablePagination p,
  ) {
    return Text(
      'Showing ${p.startItem}–${p.endItem} of ${p.totalItems}',
      style: TextStyle(
        fontSize: r.bodySmall,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildItemsPerPage(
    BuildContext context,
    AppResponsive r,
    AppTablePagination p,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Rows per page:', style: TextStyle(fontSize: r.bodySmall)),
        SizedBox(width: r.spacingS),
        DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: p.itemsPerPage,
            items: p.itemsPerPageOptions
                .map(
                  (value) => DropdownMenuItem<int>(
                    value: value,
                    child: Text(
                      value.toString(),
                      style: TextStyle(fontSize: r.bodySmall),
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                p.onItemsPerPageChanged!(value);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPageControls(
    BuildContext context,
    AppResponsive r,
    AppTablePagination p,
  ) {
    final totalPages = p.totalPages;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Previous page',
          iconSize: r.iconSmall,
          onPressed: p.currentPage > 1
              ? () => p.onPageChanged(p.currentPage - 1)
              : null,
          icon: const Icon(Icons.chevron_left),
        ),
        ..._buildPageNumbers(context, r, p, totalPages),
        IconButton(
          tooltip: 'Next page',
          iconSize: r.iconSmall,
          onPressed: p.currentPage < totalPages
              ? () => p.onPageChanged(p.currentPage + 1)
              : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  List<Widget> _buildPageNumbers(
    BuildContext context,
    AppResponsive r,
    AppTablePagination p,
    int totalPages,
  ) {
    if (totalPages <= 5) {
      return List.generate(
        totalPages,
        (index) => _buildPageButton(context, r, p, index + 1),
      );
    }

    final pages = <int>{1};

    if (p.currentPage > 2) {
      pages.add(p.currentPage - 1);
    }

    pages.add(p.currentPage);

    if (p.currentPage < totalPages - 1) {
      pages.add(p.currentPage + 1);
    }

    pages.add(totalPages);

    final sortedPages = pages.toList()..sort();

    final widgets = <Widget>[];

    for (int i = 0; i < sortedPages.length; i++) {
      if (i > 0 && sortedPages[i] - sortedPages[i - 1] > 1) {
        widgets.add(
          Padding(
            padding: EdgeInsets.symmetric(horizontal: r.spacingXS),
            child: const Text('...'),
          ),
        );
      }

      widgets.add(_buildPageButton(context, r, p, sortedPages[i]));
    }

    return widgets;
  }

  Widget _buildPageButton(
    BuildContext context,
    AppResponsive r,
    AppTablePagination p,
    int page,
  ) {
    final isSelected = page == p.currentPage;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: r.spacingXS / 2),
      child: SizedBox(
        width: r.isPhone ? 32 : 36,
        height: r.isPhone ? 32 : 36,
        child: Material(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(r.radius / 2),
          child: InkWell(
            borderRadius: BorderRadius.circular(r.radius / 2),
            onTap: isSelected ? null : () => p.onPageChanged(page),
            child: Center(
              child: Text(
                page.toString(),
                style: TextStyle(
                  fontSize: r.bodySmall,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextAlign _textAlign(Alignment alignment) {
    if (alignment == Alignment.center) {
      return TextAlign.center;
    }

    if (alignment == Alignment.centerRight ||
        alignment == Alignment.bottomRight ||
        alignment == Alignment.topRight) {
      return TextAlign.right;
    }

    return TextAlign.left;
  }
}
