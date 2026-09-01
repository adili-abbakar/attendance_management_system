import 'package:attendance_management_system/core/buttons/primary_button.dart';
import 'package:flutter/material.dart';

class DangerButton extends StatelessWidget {
  const DangerButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isIconLeading = true,
    this.width = double.infinity,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isIconLeading;
  final double width;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return PrimaryButton(
      text: text,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      isIconLeading: isIconLeading,
      width: width,
      backgroundColor: colors.error,
      foregroundColor: colors.onError,
    );
  }
}
