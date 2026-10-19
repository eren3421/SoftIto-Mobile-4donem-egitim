import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/workout_model.dart';

class WorkoutCard extends StatelessWidget {
  final WorkoutSession session;

  const WorkoutCard({
    super.key,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurfaceCard : AppColors.lightSurfaceCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          _buildIconBadge(context),
          const SizedBox(width: 14),
          Expanded(child: _buildSessionDetails(context)),
          _buildCalorieBadge(context),
        ],
      ),
    );
  }

  Widget _buildIconBadge(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lime = isDark ? AppColors.neonLimeBright : AppColors.neonLime;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: lime.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.fitness_center_rounded, color: lime, size: 24),
    );
  }

  Widget _buildSessionDetails(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final mutedColor = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;
    final cyan = isDark ? AppColors.neonCyanBright : AppColors.neonCyan;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          session.title,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(session.category, style: TextStyle(color: cyan, fontSize: 12)),
            const SizedBox(width: 8),
            Text('•', style: TextStyle(color: mutedColor)),
            const SizedBox(width: 8),
            Text('${session.durationMinutes} dk', style: TextStyle(color: subColor, fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildCalorieBadge(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '+${session.caloriesBurned}',
          style: const TextStyle(
            color: AppColors.neonOrange,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text('kcal', style: TextStyle(color: subColor, fontSize: 11)),
      ],
    );
  }
}
