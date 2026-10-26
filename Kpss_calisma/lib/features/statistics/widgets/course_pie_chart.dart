// fl_chart grafik çizim paketini içe aktarıyoruz
import 'package:fl_chart/fl_chart.dart';
// Flutter Material Design bileşenlerini içe aktarıyoruz
import 'package:flutter/material.dart';
// Renk paletini içe aktarıyoruz
import '../../../core/constants/app_colors.dart';
// Ders adlarını çekmek için CurriculumProvider'ı içe aktarıyoruz
import '../../../providers/curriculum_provider.dart';
// Ders bazlı soru istatistik modellerini içe aktarıyoruz
import '../../../providers/question_provider.dart';

// Ders bazlı çözülen soruların oranını dairesel pasta grafiği (PieChart) olarak görselleştiren bileşen
class CoursePieChart extends StatelessWidget {
  // Ders kimlikleri ve soru sayılarını içeren harita
  final Map<String, CourseStats> courseStats;

  // Ders isimlerine ve bilgilerine erişmek için müfredat sağlayıcısı
  final CurriculumProvider curriculumProv;

  // CoursePieChart kurucu fonksiyonu
  const CoursePieChart({
    super.key,
    required this.courseStats,
    required this.curriculumProv,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Soru çözülmüş olan aktif dersleri filtreliyoruz
    final activeEntries = courseStats.entries.where((e) => e.value.totalQuestions > 0).toList();

    // Henüz hiçbir dersten soru çözülmemişse bileşeni ekranda gizliyoruz
    if (activeEntries.isEmpty) {
      return const SizedBox.shrink();
    }

    // Çözülen toplam soru adedini hesaplıyoruz
    final total = activeEntries.fold(0, (sum, e) => sum + e.value.totalQuestions);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          // Koyu veya açık tema kenarlık çizgisi
          color: theme.brightness == Brightness.dark
              ? const Color(0xFF334155)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Grafik başlığı
          const Text(
            'Ders Bazlı Soru Dağılımı',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 18),
          // Pasta grafiği ve sağdaki renkli lejant (açıklama) satırı
          Row(
            children: [
              // Sol: fl_chart Dairesel Pasta Grafiği (PieChart)
              SizedBox(
                width: 140,
                height: 140,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 3, // Dilimler arasındaki beyaz/koyu boşluk
                    centerSpaceRadius: 36, // Halka şekli için ortadaki boşluğun yarıçapı
                    // Her bir aktif ders için pasta dilimi (PieChartSectionData) oluşturuyoruz
                    sections: activeEntries.map((e) {
                      final color = AppColors.getCourseColor(e.key);
                      final percentage = (e.value.totalQuestions / total) * 100;
                      return PieChartSectionData(
                        color: color,
                        value: e.value.totalQuestions.toDouble(),
                        title: '%${percentage.toInt()}', // Dilim üzerindeki yüzde metni
                        radius: 36, // Dilimin kalınlığı
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
              // Sağ: Ders isimleri ve çözülen soru sayıları listesi
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: activeEntries.map((e) {
                    final color = AppColors.getCourseColor(e.key);
                    // Dersin adına CurriculumProvider üzerinden ulaşıyoruz
                    final courseTitle = curriculumProv.courses
                        .firstWhere((c) => c.id == e.key, orElse: () => curriculumProv.courses.first)
                        .title;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          // Ders rengi noktası
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          // Ders adı metni
                          Expanded(
                            child: Text(
                              courseTitle,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Çözülen soru sayısı
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
