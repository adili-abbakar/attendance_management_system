import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:flutter/material.dart';

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isIconLeading = true,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isIconLeading;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);

    Widget buttonContent;

    if (icon == null) {
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
      child: FilledButton.tonal(onPressed: onPressed, child: buttonContent),
    );
  }
}
