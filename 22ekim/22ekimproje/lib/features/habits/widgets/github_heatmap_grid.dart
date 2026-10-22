import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';

class GithubHeatmapGrid extends StatelessWidget {
  final List<String> completedDates;
  final int weeksCount;

  const GithubHeatmapGrid({
    super.key,
    required this.completedDates,
    this.weeksCount = 10, // Son 10 hafta (70 gün)
  });

  @override
  Widget build(BuildContext context) {
    final Set<String> dateSet = completedDates.toSet();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Bitiş tarihi: Bu haftanın son günü (Pazar)
    final daysUntilSunday = 7 - today.weekday;
    final endDate = today.add(Duration(days: daysUntilSunday));
    final totalDays = weeksCount * 7;
    final startDate = endDate.subtract(Duration(days: totalDays - 1));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.grid_view_rounded, color: AppColors.accent, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Aktivite Yoğunluk Izgarası (Heatmap)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                'Son $weeksCount Hafta',
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Scrollable Grid (Haftalık sütunlar x 7 günlük satırlar)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true, // En güncel sağda
            child: Row(
              children: List.generate(weeksCount, (weekIdx) {
                return Column(
                  children: List.generate(7, (dayIdx) {
                    final dayOffset = (weekIdx * 7) + dayIdx;
                    final currentDay = startDate.add(Duration(days: dayOffset));
                    final isFuture = currentDay.isAfter(today);
                    final dateStr = HabitDateUtils.formatDate(currentDay);
                    final isDone = dateSet.contains(dateStr);

                    Color cellColor;
                    if (isFuture) {
                      cellColor = Colors.transparent;
                    } else if (isDone) {
                      cellColor = AppColors.accent;
                    } else {
                      cellColor = AppColors.surfaceVariant;
                    }

                    return Tooltip(
                      message: isFuture
                          ? 'Gelecek Gün'
                          : '${HabitDateUtils.formatTurkishFull(currentDay)}: ${isDone ? "Tamamlandı" : "Yapılmadı"}',
                      child: Container(
                        width: 14,
                        height: 14,
                        margin: const EdgeInsets.all(2.5),
                        decoration: BoxDecoration(
                          color: cellColor,
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(
                            color: isDone
                                ? AppColors.primary
                                : (isFuture ? Colors.transparent : AppColors.border.withOpacity(0.4)),
                            width: 0.8,
                          ),
                          boxShadow: isDone
                              ? [
                                  BoxShadow(
                                    color: AppColors.accent.withOpacity(0.3),
                                    blurRadius: 3,
                                  )
                                ]
                              : null,
                        ),
                      ),
                    );
                  }),
                );
              }),
            ),
          ),
          const SizedBox(height: 10),

          // Alt Yoğunluk Açıklaması
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text('Az', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
              const SizedBox(width: 4),
              _buildSampleBox(AppColors.surfaceVariant),
              _buildSampleBox(AppColors.primaryVariant),
              _buildSampleBox(AppColors.primary),
              _buildSampleBox(AppColors.accent),
              const SizedBox(width: 4),
              const Text('Çok', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSampleBox(Color color) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.symmetric(horizontal: 1.5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
