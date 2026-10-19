import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../models/workout_item.dart';

class WorkoutListTile extends StatelessWidget {
  const WorkoutListTile({
    required this.item,
    required this.onDelete,
    super.key,
  });

  final WorkoutItem item;
  final VoidCallback onDelete;

  IconData _iconForType(WorkoutType type) {
    switch (type) {
      case WorkoutType.running:
        return Icons.directions_run;
      case WorkoutType.cycling:
        return Icons.directions_bike;
      case WorkoutType.gym:
        return Icons.fitness_center;
      case WorkoutType.swimming:
        return Icons.pool;
      case WorkoutType.yoga:
        return Icons.self_improvement;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(_iconForType(item.type), color: AppColors.neonOrange, size: 24),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.type.label, style: context.textTheme.titleMedium),
              Text('${item.durationMinutes} dakika', style: context.textTheme.bodySmall),
            ],
          ),
          const Spacer(),
          Text(
            '+${item.caloriesBurned} kcal',
            style: context.textTheme.titleMedium?.copyWith(color: AppColors.neonGreen),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.textMuted, size: 20),
            onPressed: onDelete,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
