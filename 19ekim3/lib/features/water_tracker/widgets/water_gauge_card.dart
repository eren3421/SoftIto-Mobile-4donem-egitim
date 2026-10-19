import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class WaterGaugeCard extends StatelessWidget {
  final int currentMl;
  final int goalMl;

  const WaterGaugeCard({
    super.key,
    required this.currentMl,
    required this.goalMl,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (currentMl / goalMl).clamp(0.0, 1.0);
    final percentage = (progress * 100).toInt();

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          children: [
            _buildCircularGauge(context, progress, percentage),
            const SizedBox(height: 16),
            _buildAmountInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularGauge(BuildContext context, double progress, int percentage) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final cyan = isDark ? AppColors.neonCyanBright : AppColors.neonCyan;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return SizedBox(
      height: 170,
      width: 170,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: 160,
            width: 160,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 14,
              backgroundColor: trackColor,
              valueColor: AlwaysStoppedAnimation<Color>(cyan),
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.water_drop_rounded, color: cyan, size: 32),
              const SizedBox(height: 4),
              Text(
                '%$percentage',
                style: TextStyle(color: textColor, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              Text(
                'Tamamlandı',
                style: TextStyle(color: subColor, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInfo(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final cyan = isDark ? AppColors.neonCyanBright : AppColors.neonCyan;
    final subColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem('Tüketilen', '$currentMl ml', cyan, subColor),
        Container(width: 1, height: 32, color: borderColor),
        _buildStatItem('Günlük Hedef', '$goalMl ml', subColor, subColor),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor, Color subColor) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: subColor, fontSize: 13)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(color: valueColor, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
