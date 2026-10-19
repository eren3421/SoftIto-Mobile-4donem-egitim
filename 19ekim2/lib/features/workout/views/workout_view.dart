import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/workout_controller.dart';
import '../models/workout_model.dart';
import '../widgets/calorie_burn_card.dart';
import '../widgets/workout_card.dart';

class WorkoutView extends StatefulWidget {
  final WorkoutController controller;

  const WorkoutView({
    super.key,
    required this.controller,
  });

  @override
  State<WorkoutView> createState() => _WorkoutViewState();
}

class _WorkoutViewState extends State<WorkoutView> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCalorieSection(),
          const SizedBox(height: 20),
          _buildQuickActions(context),
          const SizedBox(height: 24),
          _buildWorkoutListSection(context),
        ],
      ),
    );
  }

  Widget _buildCalorieSection() {
    return ValueListenableBuilder<List<WorkoutSession>>(
      valueListenable: widget.controller.workouts,
      builder: (context, _, _) {
        return CalorieBurnCard(
          totalCalories: widget.controller.totalCaloriesBurned,
          goalCalories: widget.controller.dailyCalorieGoal,
          totalMinutes: widget.controller.totalMinutes,
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hızlı Egzersiz Ekle',
          style: TextStyle(
            color: titleColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionBtn(context, 'Koşu / Kardiyo', 'Kardiyo', 30, 260, Icons.directions_run_rounded),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionBtn(context, 'Ağırlık İdmanı', 'Fitness', 45, 340, Icons.fitness_center_rounded),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionBtn(BuildContext context, String title, String category, int min, int kcal, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lime = isDark ? AppColors.neonLimeBright : AppColors.neonLime;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final cardBg = isDark ? AppColors.darkSurfaceCard : AppColors.lightSurfaceCard;

    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: lime,
        side: BorderSide(color: borderColor),
        backgroundColor: cardBg,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {
        widget.controller.addWorkout(
          title: title,
          category: category,
          durationMinutes: min,
          caloriesBurned: kcal,
        );
      },
      icon: Icon(icon, size: 18),
      label: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildWorkoutListSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final mutedColor = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    return ValueListenableBuilder<List<WorkoutSession>>(
      valueListenable: widget.controller.workouts,
      builder: (context, list, _) {
        if (list.isEmpty) {
          return Center(
            child: Text(
              'Henüz kayıtlı egzersiz yok.',
              style: TextStyle(color: mutedColor),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Antrenman Günlüğü',
              style: TextStyle(
                color: titleColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) => WorkoutCard(session: list[i]),
            ),
          ],
        );
      },
    );
  }
}
