import 'package:attendance_management_system/core/buttons/buttons.dart';
import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:flutter/material.dart';

class AppFormDialog extends StatelessWidget {
  const AppFormDialog({
    super.key,
    required this.title,
    required this.formKey,
    required this.children,
    required this.onSave,
    this.isSaving = false,
    this.errorMessage,
    this.saveButtonText = 'Save',
    this.savingButtonText = 'Saving...',
    this.cancelButtonText = 'Cancel',
    this.saveIcon = Icons.save_rounded,
    this.onCancel,
    this.saveButtonEnabled = true,
  });

  final String title;
  final GlobalKey<FormState> formKey;

  final List<Widget> children;

  final Future<void> Function() onSave;

  final bool isSaving;
  final String? errorMessage;

  final String saveButtonText;
  final String savingButtonText;
  final String cancelButtonText;

  final IconData saveIcon;

  final VoidCallback? onCancel;

  final bool saveButtonEnabled;

  Future<void> _handleSave(BuildContext context) async {
    if (isSaving || !saveButtonEnabled) return;

    final form = formKey.currentState;

    if (form == null || !form.validate()) {
      return;
    }

    await onSave();
  }

  void _handleCancel(BuildContext context) {
    if (isSaving) return;

    if (onCancel != null) {
      onCancel!();
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final screenWidth = MediaQuery.sizeOf(context).width;

    final availableWidth = screenWidth - (r.dialogInset * 2);

    final dialogWidth = availableWidth < r.dialogWidth
        ? availableWidth
        : r.dialogWidth;

    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: r.dialogInset,
        vertical: r.dialogInset,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(r.radius),
      ),
      contentPadding: EdgeInsets.all(r.dialogPadding),

      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontSize: r.titleLarge,
          fontWeight: FontWeight.bold,
        ),
      ),

      content: SizedBox(
        width: dialogWidth,
        child: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...children,

                if (errorMessage != null) ...[
                  SizedBox(height: r.spacingM),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: r.spacingS,
                      vertical: r.spacingS,
                    ),
                    decoration: BoxDecoration(
                      color: colors.errorContainer,
                      borderRadius: BorderRadius.circular(r.radius),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: colors.onErrorContainer,
                          size: r.iconSmall,
                        ),
                        SizedBox(width: r.spacingS),
                        Expanded(
                          child: Text(
                            errorMessage!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: r.body,
                              color: colors.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),

      actionsAlignment: MainAxisAlignment.end,

      actions: [
        AppTextButton(
          text: cancelButtonText,
          onPressed: isSaving ? null : () => _handleCancel(context),
        ),

        PrimaryButton(
          width: 120,
          text: isSaving ? savingButtonText : saveButtonText,
          icon: saveIcon,
          isLoading: isSaving,
          onPressed: saveButtonEnabled ? () => _handleSave(context) : null,
        ),
      ],
    );
  }
}
