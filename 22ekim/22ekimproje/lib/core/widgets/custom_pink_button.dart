import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum PinkButtonVariant { primary, secondary, danger, outline }

class CustomPinkButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final PinkButtonVariant variant;
  final double? width;
  final double height;
  final double fontSize;

  const CustomPinkButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.variant = PinkButtonVariant.primary,
    this.width,
    this.height = 48,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color fgColor;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case PinkButtonVariant.primary:
        bgColor = AppColors.primary;
        fgColor = Colors.white;
        break;
      case PinkButtonVariant.secondary:
        bgColor = AppColors.primaryVariant;
        fgColor = AppColors.softPink;
        break;
      case PinkButtonVariant.danger:
        bgColor = AppColors.danger;
        fgColor = Colors.white;
        break;
      case PinkButtonVariant.outline:
        bgColor = Colors.transparent;
        fgColor = AppColors.softPink;
        borderSide = const BorderSide(color: AppColors.primary, width: 1.5);
        break;
    }

    final buttonWidget = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: variant == PinkButtonVariant.primary
            ? AppColors.buttonGradient
            : null,
        boxShadow: variant == PinkButtonVariant.primary
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: variant == PinkButtonVariant.primary ? Colors.transparent : bgColor,
          foregroundColor: fgColor,
          elevation: 0,
          shadowColor: Colors.transparent,
          side: borderSide,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: fgColor),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w700,
                      color: fgColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
      ),
    );

    return buttonWidget;
  }
}
