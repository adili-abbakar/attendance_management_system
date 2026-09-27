import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:flutter/material.dart';

import 'app_table_row.dart';

class AppDataTable extends StatelessWidget {
  const AppDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.isLoading = false,
    this.errorMessage,
    this.emptyMessage = 'No records found.',
    this.onRetry,
  });

  final List<AppTableColumn> columns;
  final List<AppTableRow> rows;

  final bool isLoading;
  final String? errorMessage;
  final String emptyMessage;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);

    if (isLoading) {
      return _StateView(
        icon: Icons.hourglass_empty_rounded,
        message: 'Loading...',
      );
    }

    if (errorMessage != null) {
      return _ErrorView(
        message: errorMessage!,
        onRetry: onRetry,
      );
    }

    if (rows.isEmpty) {
      return _StateView(
        icon: Icons.inbox_outlined,
        message: emptyMessage,
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(r.radius),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(
              alpha: 0.06,
            ),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: _calculateTableWidth(context),
          child: Column(
            children: [
              _TableHeader(
                columns: columns,
              ),

              ...List.generate(
                rows.length,
                (index) {
                  return _TableDataRow(
                    index: index,
                    columns: columns,
                    row: rows[index],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateTableWidth(BuildContext context) {
    final r = AppResponsive.of(context);

    final minimumWidth = columns.fold<double>(
      0,
      (total, column) => total + column.minWidth,
    );

    final horizontalPadding = r.tableHorizontalMargin * 2;

    return minimumWidth + horizontalPadding;
  }
}

class AppTableColumn {
  const AppTableColumn({
    required this.label,
    this.flex = 1,
    this.minWidth = 120,
    this.alignment = Alignment.centerLeft,
  });

  final String label;
  final int flex;
  final double minWidth;
  final Alignment alignment;
}

class _TableHeader extends StatelessWidget {
  const _TableHeader({
    required this.columns,
  });

  final List<AppTableColumn> columns;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);
    final colors = Theme.of(context).colorScheme;

    return Container(
      height: r.tableHeadingHeight,
      decoration: BoxDecoration(
        color: colors.primary,
        border: Border(
          bottom: BorderSide(
            color: colors.primary.withValues(alpha: 0.7),
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: r.tableHorizontalMargin,
      ),
      child: Row(
        children: columns.map((column) {
          return Expanded(
            flex: column.flex,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: r.tableColumnSpacing / 2,
              ),
              child: Align(
                alignment: column.alignment,
                child: Text(
                  column.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.onPrimary,
                    fontSize: r.bodySmall,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TableDataRow extends StatelessWidget {
  const _TableDataRow({
    required this.index,
    required this.columns,
    required this.row,
  });

  final int index;
  final List<AppTableColumn> columns;
  final AppTableRow row;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);
    final colors = Theme.of(context).colorScheme;

    final rowColor = index.isEven
        ? colors.surface
        : colors.surfaceContainerHighest.withValues(alpha: 0.25);

    return Material(
      color: rowColor,
      child: InkWell(
        onTap: row.onTap,
        child: Container(
          height: r.tableRowHeight,
          padding: EdgeInsets.symmetric(
            horizontal: r.tableHorizontalMargin,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: colors.outlineVariant.withValues(alpha: 0.7),
              ),
            ),
          ),
          child: Row(
            children: List.generate(
              columns.length,
              (index) {
                final column = columns[index];

                return Expanded(
                  flex: column.flex,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: r.tableColumnSpacing / 2,
                    ),
                    child: Align(
                      alignment: column.alignment,
                      child: DefaultTextStyle(
                        style: TextStyle(
                          fontSize: r.body,
                          color: colors.onSurface,
                        ),
                        child: row.cells[index],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _StateView extends StatelessWidget {
  const _StateView({
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: r.pagePadding,
        vertical: r.spacingXL,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(r.radius),
        border: Border.all(
          color: colors.outlineVariant,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: r.iconLarge,
            color: colors.onSurfaceVariant,
          ),
          SizedBox(height: r.spacingM),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: r.body,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(r.cardPadding),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(r.radius),
        border: Border.all(
          color: colors.error.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: r.iconMedium,
            color: colors.onErrorContainer,
          ),
          SizedBox(width: r.spacingS),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: r.body,
                color: colors.onErrorContainer,
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: Text(
                'Retry',
                style: TextStyle(
                  fontSize: r.body,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}