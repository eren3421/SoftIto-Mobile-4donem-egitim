import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/curriculum_provider.dart';
import '../../../providers/question_provider.dart';

class CoursePieChart extends StatelessWidget {
  final Map<String, CourseStats> courseStats;
  final CurriculumProvider curriculumProv;

  const CoursePieChart({
    super.key,
    required this.courseStats,
    required this.curriculumProv,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeEntries = courseStats.entries.where((e) => e.value.totalQuestions > 0).toList();

    if (activeEntries.isEmpty) {
      return const SizedBox.shrink();
    }

    final total = activeEntries.fold(0, (sum, e) => sum + e.value.totalQuestions);

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ders Bazlı Soru Dağılımı',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 36,
                    sections: activeEntries.map((e) {
                      final color = AppColors.getCourseColor(e.key);
                      final percentage = (e.value.totalQuestions / total) * 100;
                      return PieChartSectionData(
                        color: color,
                        value: e.value.totalQuestions.toDouble(),
                        title: '%${percentage.toInt()}',
                        radius: 36,
                        titleStyle: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: activeEntries.map((e) {
                    final color = AppColors.getCourseColor(e.key);
                    final courseTitle = curriculumProv.courses
                        .firstWhere((c) => c.id == e.key, orElse: () => curriculumProv.courses.first)
                        .title;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              courseTitle,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${e.value.totalQuestions} s',
                            style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
