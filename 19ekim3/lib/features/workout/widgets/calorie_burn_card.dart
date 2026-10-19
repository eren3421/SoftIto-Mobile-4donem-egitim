import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CalorieBurnCard extends StatelessWidget {
  final int totalCalories;
  final int goalCalories;
  final int totalMinutes;

  const CalorieBurnCard({
    super.key,
    required this.totalCalories,
    required this.goalCalories,
    required this.totalMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (totalCalories / goalCalories).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildHeaderRow(context),
            const SizedBox(height: 16),
            _buildProgressBar(context, progress),
            const SizedBox(height: 16),
            _buildStatsFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final lime = isDark ? AppColors.neonLimeBright : AppColors.neonLime;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.local_fire_department_rounded, color: AppColors.neonOrange, size: 28),
            const SizedBox(width: 8),
            Text(
              'Aktif Kalori',
              style: TextStyle(color: titleColor, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Text(
          '$totalCalories / $goalCalories kcal',
          style: TextStyle(color: lime, fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context, double progress) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 12,
        backgroundColor: trackColor,
        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.neonOrange),
      ),
    );
  }

  Widget _buildStatsFooter(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Toplam Süre: $totalMinutes dk',
          style: TextStyle(color: subColor, fontSize: 13),
        ),
        Text(
          'Kalan: ${(goalCalories - totalCalories).clamp(0, goalCalories)} kcal',
          style: TextStyle(color: subColor, fontSize: 13),
        ),
      ],
    );
  }
}
