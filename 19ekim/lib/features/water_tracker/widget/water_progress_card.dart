import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';

class WaterProgressCard extends StatelessWidget {
  const WaterProgressCard({
    required this.currentMl,
    required this.targetMl,
    required this.progress,
    super.key,
  });

  final int currentMl;
  final int targetMl;
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
                Text('Günlük Hedef', style: context.textTheme.titleMedium),
                Text('$currentMl / $targetMl ml', style: context.textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 14,
                backgroundColor: AppColors.surfaceLight,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.neonCyan),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '%${(progress * 100).toInt()} Tamamlandı',
              style: context.textTheme.bodySmall?.copyWith(color: AppColors.neonCyan),
            ),
          ],
        ),
      ),
    );
  }
}
