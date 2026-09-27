import 'package:flutter/material.dart';

class AppTableRow {
  const AppTableRow({required this.cells, this.onTap});

  final List<Widget> cells;
  final VoidCallback? onTap;
}
