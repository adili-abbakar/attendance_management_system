import 'package:flutter/material.dart';

import 'app_table_cell.dart';

class AppTableRow {
  const AppTableRow({required this.cells, this.onTap});

  final List<AppTableCell> cells;

  final VoidCallback? onTap;
}
