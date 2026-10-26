// Flutter Material Design bileşenlerini içe aktarıyoruz
import 'package:flutter/material.dart';
// Durum yönetimi için Provider paketini içe aktarıyoruz
import 'package:provider/provider.dart';
// Renk sabitlerini içe aktarıyoruz
import '../../../core/constants/app_colors.dart';
// Süre formatlama yardımcı sınıfını içe aktarıyoruz
import '../../../core/utils/date_utils.dart';
// Müfredat ilerleme sağlayıcısını içe aktarıyoruz
import '../../../providers/curriculum_provider.dart';
// Soru ve oturum sağlayıcısını içe aktarıyoruz
import '../../../providers/question_provider.dart';

// Ana sayfada bugünün özetini (Net, Çalışma Süresi, Doğruluk Oranı, Müfredat) 2x2 grid şeklinde gösteren bileşen
class TodayStatsGrid extends StatelessWidget {
  // TodayStatsGrid kurucu fonksiyonu
  const TodayStatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    // Soru ve müfredat verilerini provider üzerinden dinliyoruz
    final questionProv = context.watch<QuestionProvider>();
    final curriculumProv = context.watch<CurriculumProvider>();

    // Bugünün toplam KPSS neti
    final todayNet = questionProv.todayNetScore;
    // Bugün yapılan toplam doğru sayısı
    final todayCorrect = questionProv.todayTotalCorrect;
    // Bugün yapılan toplam yanlış sayısı
    final todayWrong = questionProv.todayTotalWrong;
    // Bugün bırakılan toplam boş sayısı
    final todayEmpty = questionProv.todayTotalEmpty;
    // Bugün tutulan toplam çalışma süresi (dakika)
    final studyMinutes = questionProv.todayStudyDurationMinutes;
    // Tüm müfredattaki genel tamamlanma yüzdesi
    final curriculumProgress = (curriculumProv.overallProgress * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bölüm başlığı
        const Text(
          'Bugünün Özeti',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        // İlk satır: Bugünkü Net ve Çalışma Süresi kartları
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context,
                title: 'Bugünkü Net',
                value: todayNet.toStringAsFixed(2),
                subtitle: '$todayCorrect D • $todayWrong Y • $todayEmpty B',
                icon: Icons.auto_awesome,
                iconColor: AppColors.primary,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                context,
                title: 'Çalışma Süresi',
                value: AppDateUtils.formatDuration(studyMinutes),
                subtitle: studyMinutes > 0 ? 'Aktif odaklanma' : 'Sayaç başlatılmadı',
                icon: Icons.timer_outlined,
                iconColor: AppColors.secondary,
                backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // İkinci satır: Doğruluk Oranı ve Müfredat İlerleme kartları
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context,
                title: 'Doğruluk Oranı',
                value: '%${(questionProv.todayTotalQuestions == 0 ? 0 : (todayCorrect / questionProv.todayTotalQuestions * 100)).toInt()}',
                subtitle: 'Başarı yüzdesi',
                icon: Icons.verified_outlined,
                iconColor: AppColors.completed,
                backgroundColor: AppColors.completed.withValues(alpha: 0.1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                context,
                title: 'Müfredat İlerleme',
                value: '%$curriculumProgress',
                subtitle: '${curriculumProv.totalCompletedTopics}/${curriculumProv.totalTopicsCount} konu bitti',
                icon: Icons.menu_book_outlined,
                iconColor: AppColors.courseMatematik,
                backgroundColor: AppColors.courseMatematik.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // İstatistik kutucuklarını (Metric Card) oluşturan yeniden kullanılabilir metot
  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          // Koyu veya açık tema sınır rengi
          color: theme.brightness == Brightness.dark
              ? const Color(0xFF334155)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // İkon ve Başlık satırı
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Ana sayısal değer metni
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          // Alt açıklama veya detay metni
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
