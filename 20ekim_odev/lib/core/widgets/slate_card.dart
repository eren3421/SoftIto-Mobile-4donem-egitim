import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

class SlateCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final BorderRadius? borderRadius;

  const SlateCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = AppSpacing.cardPadding,
    this.margin = const EdgeInsets.symmetric(vertical: 6),
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.borderRadius,
  });

  @override
  State<SlateCard> createState() => _SlateCardState();
}

class _SlateCardState extends State<SlateCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark ? AppColors.slateCardGrey : AppColors.lightCardBg;
    final defaultBorder = isDark ? AppColors.steelBorderGrey : AppColors.lightBorder;
    final activeBorder = AppColors.crimsonAccent;

    final currentBorderColor = widget.borderColor ??
        (_isHovered ? activeBorder : defaultBorder);

    final cardRadius = widget.borderRadius ?? AppSpacing.radiusLg;

    return Container(
      margin: widget.margin,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? defaultBg,
            borderRadius: cardRadius,
            border: Border.all(
              color: currentBorderColor,
              width: _isHovered ? 1.5 : widget.borderWidth,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: isDark
                          ? AppColors.crimsonAccent.withValues(alpha: 0.15)
                          : Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: cardRadius,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: cardRadius,
              child: Padding(
                padding: widget.padding,
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
