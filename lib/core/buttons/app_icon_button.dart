import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:flutter/material.dart';

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.color,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  /// Optional color override for special actions.
  ///
  /// When null, the application theme is used.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);

    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      color: color,
      icon: Icon(icon, size: r.iconMedium),
    );
  }
}
