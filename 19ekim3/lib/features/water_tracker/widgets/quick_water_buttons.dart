import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class QuickWaterButtons extends StatelessWidget {
  final ValueChanged<int> onAddWater;

  const QuickWaterButtons({
    super.key,
    required this.onAddWater,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hızlı Su Ekle',
          style: TextStyle(
            color: titleColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildButton(context, '150 ml', 150, Icons.local_cafe_outlined)),
            const SizedBox(width: 8),
            Expanded(child: _buildButton(context, '250 ml', 250, Icons.water_drop_outlined)),
            const SizedBox(width: 8),
            Expanded(child: _buildButton(context, '500 ml', 500, Icons.sports_bar_outlined)),
          ],
        ),
      ],
    );
  }

  Widget _buildButton(BuildContext context, String label, int amount, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurfaceCard : AppColors.lightSurfaceCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final cyan = isDark ? AppColors.neonCyanBright : AppColors.neonCyan;

    return InkWell(
      onTap: () => onAddWater(amount),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            Icon(icon, color: cyan, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
