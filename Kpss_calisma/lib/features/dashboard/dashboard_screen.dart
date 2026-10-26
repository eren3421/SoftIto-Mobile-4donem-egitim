// Flutter Material Design bileşenlerini içe aktarıyoruz
import 'package:flutter/material.dart';
// Durum yönetimi için Provider kütüphanesini içe aktarıyoruz
import 'package:provider/provider.dart';
// Renk sabitlerini içe aktarıyoruz
import '../../core/constants/app_colors.dart';
// Uygulama adı ve görsel yolları gibi sabitleri içe aktarıyoruz
import '../../core/constants/app_constants.dart';
// Tema değiştirme işlemleri için SettingsProvider'ı içe aktarıyoruz
import '../../providers/settings_provider.dart';
// Günlük hedef kartı bileşenini içe aktarıyoruz
import 'widgets/daily_goal_card.dart';
// Ders bazlı hızlı ilerleme çubukları bileşenini içe aktarıyoruz
import 'widgets/quick_course_progress.dart';
// Bugünün net, çalışma ve istatistik özeti grid bileşenini içe aktarıyoruz
import 'widgets/today_stats_grid.dart';

// KPSS Çalışma Koçu'nun ana sayfası (Dashboard); günlük hedef, hızlı aksiyonlar ve istatistik özetlerini barındırır
class DashboardScreen extends StatelessWidget {
  // Konular sekmesine yönlendiren geri çağrım
  final VoidCallback onNavigateToCurriculum;

  // Sayaç sekmesine yönlendiren geri çağrım
  final VoidCallback onNavigateToTimer;

  // Soru ekleme penceresini açan geri çağrım
  final VoidCallback onOpenAddQuestion;

  // Deneme sınavları ekranını açan geri çağrım
  final VoidCallback onOpenMockExams;

  // DashboardScreen kurucu fonksiyonu
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
      // Sayfanın üst çubuğu (AppBar)
      appBar: AppBar(
        titleSpacing: 16,
        // Uygulama logosu ve başlığını içeren sol bölüm
        title: Row(
          children: [
            // Köşeleri yuvarlatılmış logo görseli
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                AppConstants.assetLogo,
                width: 36,
                height: 36,
                fit: BoxFit.cover,
                // Görsel bulunamazsa yedek okul ikonu kutusu göster
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
            // Uygulama ana adı ve alt sloganı
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
        // Sağ üstteki işlem butonları
        actions: [
          // Açık/koyu tema geçiş butonu
          IconButton(
            onPressed: () => context.read<SettingsProvider>().toggleTheme(),
            icon: Icon(
              context.watch<SettingsProvider>().isDarkTheme
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            tooltip: 'Tema Değiştir',
          ),
          // Deneme sınavları ekranını açan buton
          IconButton(
            onPressed: onOpenMockExams,
            icon: const Icon(Icons.assignment_outlined),
            tooltip: 'Deneme Sınavları',
          ),
        ],
      ),
      // Sayfanın dikey kaydırılabilir ana gövdesi
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        physics: const BouncingScrollPhysics(), // iOS tarzı esnek kaydırma efekti
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Günlük Soru Hedefi Kartı
            const DailyGoalCard(),
            const SizedBox(height: 20),

            // 2. Hızlı İşlem Butonları (Soru Ekle, Sayaç, Denemeler)
            _buildQuickActions(context),
            const SizedBox(height: 24),

            // 3. Bugünün İstatistikleri (Net, Süre, Başarı vb.)
            const TodayStatsGrid(),
            const SizedBox(height: 24),

            // 4. KPSS Derslerinin İlerleme Durumu Özeti
            QuickCourseProgress(
              onNavigateToCurriculum: onNavigateToCurriculum,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // Hızlı işlem butonları satırını oluşturan yardımcı metot
  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        // Soru Ekle butonu
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
        // Sayaç Başlat butonu
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
        // Deneme Sınavları butonu
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

  // Tekil hızlı işlem kartını oluşturan yardımcı metot
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
