import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';

class WorkoutSummaryCard extends StatelessWidget {
  const WorkoutSummaryCard({
    required this.caloriesBurned,
    required this.targetCalories,
    required this.totalMinutes,
    required this.progress,
    super.key,
  });

  final int caloriesBurned;
  final int targetCalories;
  final int totalMinutes;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatColumn(
                  title: 'Yakılan Kalori',
                  value: '$caloriesBurned kcal',
                  color: AppColors.neonOrange,
                ),
                _StatColumn(
                  title: 'Toplam Süre',
                  value: '$totalMinutes dk',
                  color: AppColors.neonGreen,
                ),
                _StatColumn(
                  title: 'Hedef',
                  value: '$targetCalories kcal',
                  color: AppColors.textPrimary,
                ),
              ],
            ),
            const SizedBox(height: 18),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                backgroundColor: AppColors.surfaceLight,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.neonOrange),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.title,
    required this.value,
    required this.color,
  });

  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          value,
          style: context.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
