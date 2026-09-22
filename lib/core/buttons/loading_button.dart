import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:flutter/material.dart';

class LoadingButton extends StatelessWidget {
  const LoadingButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.isLoading,
    this.icon,
    this.isIconLeading = true,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool isIconLeading;

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
          color: colorScheme.onPrimary,
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
      width: double.infinity,
      height: r.buttonHeight,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        child: buttonContent,
      ),
    );
  }
}
