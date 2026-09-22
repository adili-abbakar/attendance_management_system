import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isIconLeading = true,
    this.backgroundColor,
    this.foregroundColor,
    this.width = double.infinity,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isIconLeading;

  /// Optional override for special cases.
  ///
  /// When null, the application theme is used.
  final Color? backgroundColor;

  /// Optional override for special cases.
  ///
  /// When null, the application theme is used.
  final Color? foregroundColor;

  /// Defaults to full width for normal page/form usage.
  final double width;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    Widget buttonContent;

    if (isLoading) {
      buttonContent = SizedBox(
        width: r.buttonIcon,
        height: r.buttonIcon,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: foregroundColor ?? colorScheme.onPrimary,
        ),
      );
    } else if (icon == null) {
      buttonContent = Text(text, style: TextStyle(fontSize: r.body));
    } else {
      buttonContent = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isIconLeading) ...[
            Icon(icon, size: r.buttonIcon),
            SizedBox(width: r.spacingS),
          ],

          Text(text, style: TextStyle(fontSize: r.body)),

          if (!isIconLeading) ...[
            SizedBox(width: r.spacingS),
            Icon(icon, size: r.buttonIcon),
          ],
        ],
      );
    }

    return SizedBox(
      width: width,
      height: r.buttonHeight,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        child: buttonContent,
      ),
    );
  }
}
