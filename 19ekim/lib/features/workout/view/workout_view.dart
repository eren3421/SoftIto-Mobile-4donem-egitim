import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../controller/workout_controller.dart';
import '../widget/workout_add_sheet.dart';
import '../widget/workout_list_tile.dart';
import '../widget/workout_summary_card.dart';

class WorkoutView extends StatelessWidget {
  const WorkoutView({
    required this.controller,
    super.key,
  });

  final WorkoutController controller;

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WorkoutAddSheet(
        onAdd: (type, duration) {
          controller.addWorkout(type: type, durationMinutes: duration);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WorkoutSummaryCard(
                  caloriesBurned: controller.totalCaloriesBurned,
                  targetCalories: controller.targetCalories,
                  totalMinutes: controller.totalDurationMinutes,
                  progress: controller.calorieProgress,
                ),
                const SizedBox(height: 24),
                _WorkoutHeader(onReset: controller.reset),
                const SizedBox(height: 12),
                _WorkoutList(controller: controller),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppColors.neonOrange,
            foregroundColor: AppColors.background,
            onPressed: () => _showAddSheet(context),
            icon: const Icon(Icons.add),
            label: const Text('Egzersiz Ekle', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }
}

class _WorkoutHeader extends StatelessWidget {
  const _WorkoutHeader({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Bugünkü Egzersizler', style: context.textTheme.titleMedium),
        TextButton(
          onPressed: onReset,
          child: Text(
            'Sıfırla',
            style: context.textTheme.bodySmall?.copyWith(color: AppColors.error),
          ),
        ),
      ],
    );
  }
}

class _WorkoutList extends StatelessWidget {
  const _WorkoutList({required this.controller});

  final WorkoutController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.workouts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Text(
            'Henüz egzersiz kaydı bulunmuyor.',
            style: context.textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
          ),
        ),
      );
    }

    return Column(
      children: controller.workouts.map((workout) {
        return WorkoutListTile(
          item: workout,
          onDelete: () => controller.removeWorkout(workout.id),
        );
      }).toList(),
    );
  }
}
