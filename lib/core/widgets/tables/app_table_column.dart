import 'package:flutter/material.dart';

class AppTableColumn {
  const AppTableColumn({
    required this.label,
    this.width,
    this.flex = 1,
    this.alignment = Alignment.centerLeft,
  });

  final String label;
  final double? width;
  final int flex;
  final Alignment alignment;
}
