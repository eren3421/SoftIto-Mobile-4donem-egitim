import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import 'crimson_button.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Onayla',
    this.cancelLabel = 'Vazgeç',
    this.icon,
    this.iconColor,
    required this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Onayla',
    String cancelLabel = 'Vazgeç',
    IconData? icon,
    Color? iconColor,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        icon: icon,
        iconColor: iconColor,
        isDestructive: isDestructive,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (iconColor ?? AppColors.crimsonAccent).withValues(alpha: 0.15),
                      borderRadius: AppSpacing.radiusSm,
                    ),
                    child: Icon(
                      icon,
                      color: iconColor ?? (isDestructive ? AppColors.statusRed : AppColors.crimsonLight),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.platinumText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.silverText,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: onCancel ?? () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.silverText,
                    side: const BorderSide(color: AppColors.steelBorderGrey),
                  ),
                  child: Text(cancelLabel),
                ),
                const SizedBox(width: AppSpacing.md),
                CrimsonButton(
                  label: confirmLabel,
                  onPressed: onConfirm,
                  height: 40,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
