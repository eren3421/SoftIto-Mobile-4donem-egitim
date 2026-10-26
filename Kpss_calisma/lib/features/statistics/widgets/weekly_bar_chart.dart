// fl_chart çubuk (bar) grafik kütüphanesini içe aktarıyoruz
import 'package:fl_chart/fl_chart.dart';
// Flutter Material Design bileşenlerini içe aktarıyoruz
import 'package:flutter/material.dart';
// Renk paleti sabitlerini içe aktarıyoruz
import '../../../core/constants/app_colors.dart';
// Gün ve ay formatlama yardımcı sınıfını içe aktarıyoruz
import '../../../core/utils/date_utils.dart';

// Son 7 günde çözülen soru sayılarını dikey sütun grafiği (BarChart) ile gösteren bileşen
class WeeklyBarChart extends StatelessWidget {
  // Son 7 güne ait normalize edilmiş tarih ve soru sayıları haritası
  final Map<DateTime, int> last7DaysData;

  // WeeklyBarChart kurucu fonksiyonu
  const WeeklyBarChart({super.key, required this.last7DaysData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Haritayı liste formatına çeviriyoruz
    final entries = last7DaysData.entries.toList();

    // Grafiğin dikey eksen (Y) tavan değerini belirlemek için en yüksek soru sayısını buluyoruz
    int maxCount = 10;
    for (final e in entries) {
      if (e.value > maxCount) maxCount = e.value;
    }
    // Grafiğin üst kısmında hoş görünmesi için en yakın 10'un katına yuvarlıyoruz
    final maxY = ((maxCount + 10) ~/ 10) * 10.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          // Koyu veya açık tema sınır çizgisi
          color: theme.brightness == Brightness.dark
              ? const Color(0xFF334155)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kart başlığı ve grafik ikonu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Son 7 Gün Soru Dağılımı',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              Icon(Icons.bar_chart, color: AppColors.primary, size: 20),
            ],
          ),
          const SizedBox(height: 24),
          // fl_chart Çubuk Grafik Alanı
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: maxY, // Y ekseninin tepe sınırı
                // Sütuna dokunulduğunda açılan bilgi balonu (Tooltip)
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final day = entries[groupIndex].key;
                      return BarTooltipItem(
                        '${AppDateUtils.formatDayMonth(day)}\n${rod.toY.toInt()} Soru',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                // Eksen başlıkları ve etiketleri yapılandırması
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  // Sol Y eksenindeki soru sayısı sayısal basamakları
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        if (value == 0 || value == maxY || value == maxY / 2) {
                          return Text(
                            value.toInt().toString(),
                            style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  // Alt X eksenindeki gün/ay etiketleri (Örn: 24 Eki)
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < entries.length) {
                          final day = entries[index].key;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              AppDateUtils.formatDayMonth(day),
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                // Yatay kılavuz çizgileri
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withValues(alpha: 0.15),
                    strokeWidth: 1,
                  ),
                ),
                // Dış sınır çerçevesini gizliyoruz
                borderData: FlBorderData(show: false),
                // 7 gün için dikey çubuk grupları oluşturuyoruz
                barGroups: List.generate(entries.length, (index) {
                  final count = entries[index].value.toDouble();
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: count, // Çubuğun yüksekliği (soru sayısı)
                        // Çubuk rengi için şık mavi gradyan
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        width: 16, // Çubuk kalınlığı
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)), // Üstü yuvarlak
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
