import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../providers/curriculum_provider.dart';
import '../../providers/question_provider.dart';
import '../question_tracker/widgets/add_question_sheet.dart';
import 'widgets/course_pie_chart.dart';
import 'widgets/weekly_bar_chart.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final questionProv = context.watch<QuestionProvider>();
    final curriculumProv = context.watch<CurriculumProvider>();
    final theme = Theme.of(context);

    final totalQuestions = questionProv.totalAllQuestions;
    final totalNet = questionProv.totalAllNetScore;
    final accuracy = questionProv.overallAccuracyRate;
    final totalStudyMinutes = questionProv.totalAllStudyMinutes;
    final courseStats = questionProv.getCourseStats();
    final last7Days = questionProv.getLast7DaysQuestionCounts();

    return Scaffold(
      appBar: AppBar(
        title: const Text('İstatistik ve Analiz'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Stats Cards
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    context,
                    title: 'Toplam Net',
                    value: totalNet.toStringAsFixed(2),
                    icon: Icons.trending_up,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(
                    context,
                    title: 'Toplam Soru',
                    value: totalQuestions.toString(),
                    icon: Icons.checklist_outlined,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    context,
                    title: 'Genel Başarı',
                    value: '%${accuracy.toInt()}',
                    icon: Icons.verified_outlined,
                    color: AppColors.completed,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(
                    context,
                    title: 'Toplam Süre',
                    value: AppDateUtils.formatDuration(totalStudyMinutes),
                    icon: Icons.access_time_outlined,
                    color: AppColors.accentGold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Empty State Protection Rule from SKILL.md
            if (totalQuestions == 0)
              _buildEmptyStateCard(context)
            else ...[
              // Weekly Bar Chart
              WeeklyBarChart(last7DaysData: last7Days),
              const SizedBox(height: 20),

              // Course Pie Chart
              CoursePieChart(
                courseStats: courseStats,
                curriculumProv: curriculumProv,
              ),
              const SizedBox(height: 24),

              // Course Performance Breakdown Table
              Text(
                'Ders Bazlı Başarı Karnesi',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              _buildCourseBreakdown(context, curriculumProv, courseStats),
              const SizedBox(height: 24),

              // Question Logs History
              Text(
                'Son Soru Çözüm Kayıtları',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              _buildLogsList(context, questionProv),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStateCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? const Color(0xFF334155)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.query_stats,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Henüz veri girişi yapılmadı',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Grafiklerin ve analizlerin oluşması için ilk soru kaydını ekle!',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => AddQuestionSheet.show(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('İlk Soru Kaydını Ekle'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? const Color(0xFF334155)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseBreakdown(
    BuildContext context,
    CurriculumProvider curriculumProv,
    Map<String, CourseStats> courseStats,
  ) {
    final theme = Theme.of(context);
    return Column(
      children: curriculumProv.courses.map((course) {
        final stat = courseStats[course.id];
        final color = AppColors.getCourseColor(course.id);
        final solved = stat?.totalQuestions ?? 0;
        final correct = stat?.totalCorrect ?? 0;
        final wrong = stat?.totalWrong ?? 0;
        final net = stat?.netScore ?? 0.0;
        final accuracy = stat?.accuracyRate ?? 0.0;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: theme.brightness == Brightness.dark
                  ? const Color(0xFF334155)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        course.title,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ],
                  ),
                  Text(
                    'Net: ${net.toStringAsFixed(2)}',
                    style: TextStyle(fontWeight: FontWeight.w800, color: color, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$solved Soru ($correct D • $wrong Y)',
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                  ),
                  Text(
                    'Başarı: %${accuracy.toInt()}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: accuracy >= 70 ? AppColors.completed : AppColors.needsReview,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLogsList(BuildContext context, QuestionProvider questionProv) {
    final theme = Theme.of(context);
    final logs = questionProv.logs.take(6).toList();

    return Column(
      children: logs.map((log) {
        final color = AppColors.getCourseColor(log.courseId);
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.brightness == Brightness.dark
                  ? const Color(0xFF334155)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 36,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.courseId.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${log.correct} D • ${log.wrong} Y • ${log.empty} B  (${AppDateUtils.getRelativeDay(log.date)})',
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${log.netScore.toStringAsFixed(2)} Net',
                    style: TextStyle(fontWeight: FontWeight.w800, color: color, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${log.totalQuestions} Soru',
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                onPressed: () => questionProv.deleteQuestionLog(log.id),
                tooltip: 'Kaydı Sil',
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
