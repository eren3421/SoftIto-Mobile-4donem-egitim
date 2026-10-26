// Flutter Material Design bileşenlerini içe aktarıyoruz
import 'package:flutter/material.dart';
// Durum yönetimi için Provider paketini içe aktarıyoruz
import 'package:provider/provider.dart';
// Ders renklerini almak için renk sabitlerini içe aktarıyoruz
import '../../../core/constants/app_colors.dart';
// Müfredat ve ders ilerleme verilerini sağlayan provider'ı içe aktarıyoruz
import '../../../providers/curriculum_provider.dart';

// Ana sayfada tüm KPSS derslerinin ilerleme çubuklarını listeleyen hızlı özet kartı bileşeni
class QuickCourseProgress extends StatelessWidget {
  // "Tümünü Gör" tıklandığında Konular sekmesine yönlendiren geri çağrım (callback)
  final VoidCallback onNavigateToCurriculum;

  // QuickCourseProgress kurucu fonksiyonu
  const QuickCourseProgress({
    super.key,
    required this.onNavigateToCurriculum,
  });

  @override
  Widget build(BuildContext context) {
    // Müfredat durumunu provider üzerinden dinliyoruz
    final curriculumProv = context.watch<CurriculumProvider>();
    final courses = curriculumProv.courses;
    final theme = Theme.of(context);

    // Veriler henüz yüklenmemişse veya ders listesi boşsa ekranda yer kaplamayan boş bir kutu döneriz
    if (curriculumProv.isLoading || courses.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Başlık ve "Tümünü Gör" butonu satırı
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Bölüm başlığı
            const Text(
              'Ders İlerlemeleri',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            // Konular ekranına yönlendiren şık buton
            TextButton(
              onPressed: onNavigateToCurriculum,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Row(
                children: [
                  Text('Tümünü Gör'),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios, size: 12),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Derslerin ilerleme çubuklarını barındıran beyaz/koyu kart kutusu
        Container(
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
            // Tüm dersleri haritalayarak (map) tek tek dikey satırlar oluşturuyoruz
            children: courses.map((course) {
              // Dersin tamamlanma yüzdesi (0.0 - 1.0)
              final progress = curriculumProv.getCourseProgress(course.id);
              // Tamamlanan konu sayısı
              final completed = curriculumProv.getCourseCompletedTopics(course.id);
              // Toplam alt konu sayısı
              final total = course.topics.length;
              // Dersi temsil eden renk (Mavi, Mor, Turuncu vb.)
              final courseColor = AppColors.getCourseColor(course.id);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [
                    // Ders adı ve ilerleme metni (Örn: 5 / 12 (%41))
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            // Ders renginde dairesel simge
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: courseColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Dersin başlığı
                            Text(
                              course.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        // Tamamlanma detayı metni
                        Text(
                          '$completed / $total (%${(progress * 100).toInt()})',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: courseColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Dersin renkli çizgisel ilerleme çubuğu
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: courseColor.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(courseColor),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
