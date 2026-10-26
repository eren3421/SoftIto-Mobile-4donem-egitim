// Flutter Material Design bileşenlerini içe aktarıyoruz
import 'package:flutter/material.dart';
// Durum yönetimi için Provider kütüphanesini içe aktarıyoruz
import 'package:provider/provider.dart';
// Renk paleti sabitlerini içe aktarıyoruz
import '../../core/constants/app_colors.dart';
// Tarih ve süre formatlama yardımcılarını içe aktarıyoruz
import '../../core/utils/date_utils.dart';
// Müfredat ve ders bilgilerine erişmek için CurriculumProvider'ı içe aktarıyoruz
import '../../providers/curriculum_provider.dart';
// Soru çözümleri ve istatistik verilerini almak için QuestionProvider'ı içe aktarıyoruz
import '../../providers/question_provider.dart';
// Hızlı soru ekleme modal penceresini içe aktarıyoruz
import '../question_tracker/widgets/add_question_sheet.dart';
// Ders dağılımı pasta grafiğini içe aktarıyoruz
import 'widgets/course_pie_chart.dart';
// Son 7 günün soru çubuk grafiğini içe aktarıyoruz
import 'widgets/weekly_bar_chart.dart';

// KPSS çalışma verilerini, net puanları, fl_chart grafiklerini ve ders karnesini sunan İstatistik Ekranı
class StatisticsScreen extends StatelessWidget {
  // StatisticsScreen kurucu fonksiyonu
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Soru ve müfredat sağlayıcılarını dinliyoruz
    final questionProv = context.watch<QuestionProvider>();
    final curriculumProv = context.watch<CurriculumProvider>();
    final theme = Theme.of(context);

    // Bugüne kadar çözülmüş genel toplam soru sayısı
    final totalQuestions = questionProv.totalAllQuestions;
    // Bugüne kadar yapılan toplam net puan
    final totalNet = questionProv.totalAllNetScore;
    // Genel doğru yapma (başarı) yüzdesi
    final accuracy = questionProv.overallAccuracyRate;
    // Toplam çalışma süresi (dakika)
    final totalStudyMinutes = questionProv.totalAllStudyMinutes;
    // Ders bazında gruplanmış soru istatistikleri
    final courseStats = questionProv.getCourseStats();
    // Son 7 güne ait soru dağılım verileri
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
            // Genel Toplam Metrik Kartları (Net, Soru, Başarı, Süre)
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

            // Henüz soru çözülmediyse boş durum (Empty State) kartı göster
            if (totalQuestions == 0)
              _buildEmptyStateCard(context)
            else ...[
              // Son 7 Gün Soru Dağılım Çubuk Grafiği (WeeklyBarChart)
              WeeklyBarChart(last7DaysData: last7Days),
              const SizedBox(height: 20),

              // Ders Dağılım Pasta Grafiği (CoursePieChart)
              CoursePieChart(
                courseStats: courseStats,
                curriculumProv: curriculumProv,
              ),
              const SizedBox(height: 24),

              // Ders Bazlı Başarı Karnesi Bölüm Başlığı
              Text(
                'Ders Bazlı Başarı Karnesi',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              // Her dersin net ve doğruluk yüzdesini listeleyen kartlar
              _buildCourseBreakdown(context, curriculumProv, courseStats),
              const SizedBox(height: 24),

              // Son Soru Çözüm Kayıtları Başlığı
              Text(
                'Son Soru Çözüm Kayıtları',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              // Geçmiş soru çözümlerini silme özellikli listeleyen bileşen
              _buildLogsList(context, questionProv),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // Henüz veri girilmediğinde kullanıcıyı karşılayan ve soru eklemeye teşvik eden kart
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
            // İlk soru kaydını ekleten buton
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

  // Genel metrik gösterge kartı (Toplam Net, Soru vb.) oluşturan yardımcı metot
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

  // Her dersin netini, doğru/yanlış oranını ve başarı karnesini oluşturan metot
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

  // Son çözülen soruların geçmiş listesini oluşturan metot
  Widget _buildLogsList(BuildContext context, QuestionProvider questionProv) {
    final theme = Theme.of(context);
    // Son 6 kaydı alıyoruz
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
              // İlgili kaydı silme butonu
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
