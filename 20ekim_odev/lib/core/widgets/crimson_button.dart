import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

class CrimsonButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;
  final double? width;
  final double height;

  const CrimsonButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.width,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return SizedBox(
        width: width,
        height: height,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.crimsonAccent, width: 1.2),
            shape: RoundedRectangleBorder(borderRadius: AppSpacing.radiusMd),
          ),
          child: _buildContent(context, AppColors.crimsonLight),
        ),
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: AppSpacing.radiusMd,
          gradient: onPressed == null
              ? null
              : const LinearGradient(
                  colors: [AppColors.crimsonPrimary, AppColors.crimsonAccent],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          boxShadow: onPressed == null
              ? null
              : [
                  BoxShadow(
                    color: AppColors.crimsonPrimary.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: AppColors.gunmetalGrey,
            shape: RoundedRectangleBorder(borderRadius: AppSpacing.radiusMd),
          ),
          child: _buildContent(context, AppColors.platinumText),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Color textColor) {
    if (isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.platinumText),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: textColor),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      );
    }

    return Text(
      label,
      style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 14),
    );
  }
}
