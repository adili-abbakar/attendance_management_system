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

  final Color? backgroundColor;
  final Color? foregroundColor;

  /// Defaults to full width for normal page/form usage.
  final double width;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);

    Widget buttonContent;

    if (isLoading) {
      buttonContent = SizedBox(
        width: r.buttonIcon,
        height: r.buttonIcon,
        child: const CircularProgressIndicator(strokeWidth: 2),
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
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
        ),
        child: buttonContent,
      ),
    );
  }
}
