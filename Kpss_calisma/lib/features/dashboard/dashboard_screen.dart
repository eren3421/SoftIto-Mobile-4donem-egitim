import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/settings_provider.dart';
import 'widgets/daily_goal_card.dart';
import 'widgets/quick_course_progress.dart';
import 'widgets/today_stats_grid.dart';


class DashboardScreen extends StatelessWidget {
  final VoidCallback onNavigateToCurriculum;
  final VoidCallback onNavigateToTimer;
  final VoidCallback onOpenAddQuestion;
  final VoidCallback onOpenMockExams;

  const DashboardScreen({
    super.key,
    required this.onNavigateToCurriculum,
    required this.onNavigateToTimer,
    required this.onOpenAddQuestion,
    required this.onOpenMockExams,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                AppConstants.assetLogo,
                width: 36,
                height: 36,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.school, color: Colors.white, size: 22),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConstants.appName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  AppConstants.appSubtitle,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => context.read<SettingsProvider>().toggleTheme(),
            icon: Icon(
              context.watch<SettingsProvider>().isDarkTheme
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            tooltip: 'Tema Değiştir',
          ),
          IconButton(
            onPressed: onOpenMockExams,
            icon: const Icon(Icons.assignment_outlined),
            tooltip: 'Deneme Sınavları',
          ),
        ],

      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daily Goal Card
            const DailyGoalCard(),
            const SizedBox(height: 20),

            // Quick Actions Bar
            _buildQuickActions(context),
            const SizedBox(height: 24),

            // Today's Stats Grid
            const TodayStatsGrid(),
            const SizedBox(height: 24),

            // Course Progress Overview
            QuickCourseProgress(
              onNavigateToCurriculum: onNavigateToCurriculum,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            context,
            title: 'Soru Ekle',
            icon: Icons.add_circle_outline,
            color: AppColors.primary,
            onTap: onOpenAddQuestion,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            context,
            title: 'Sayaç Başlat',
            icon: Icons.timer_outlined,
            color: AppColors.secondary,
            onTap: onNavigateToTimer,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            context,
            title: 'Denemeler',
            icon: Icons.assignment_outlined,
            color: AppColors.accentGold,
            onTap: onOpenMockExams,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
