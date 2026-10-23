import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../core/widgets/custom_pink_button.dart';
import '../../data/models/habit_model.dart';
import '../../data/models/pdf_report_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/habit_repository.dart';
import '../../data/repositories/note_repository.dart';
import '../../data/repositories/report_repository.dart';
import '../../data/services/huggingface_service.dart';
import '../../data/services/pdf_generator_service.dart';
import '../habits/widgets/github_heatmap_grid.dart';

class ReportPreviewDialog extends ConsumerStatefulWidget {
  final HabitModel? specificHabit; // null ise genel değerlendirme raporu

  const ReportPreviewDialog({super.key, this.specificHabit});

  static Future<void> show(BuildContext context, {HabitModel? specificHabit}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => ReportPreviewDialog(specificHabit: specificHabit),
    );
  }

  @override
  ConsumerState<ReportPreviewDialog> createState() => _ReportPreviewDialogState();
}

class _ReportPreviewDialogState extends ConsumerState<ReportPreviewDialog> {
  bool _isLoadingAi = true;
  bool _isGeneratingPdf = false;
  String _expertOpinion = '';
  PdfReportModel? _generatedReport;
  Map<String, dynamic>? _dayPatterns;

  @override
  void initState() {
    super.initState();
    _fetchExpertOpinion();
  }

  Future<void> _fetchExpertOpinion() async {
    final habit = widget.specificHabit;
    final allHabits = ref.read(habitsListProvider);
    final allNotes = ref.read(allNotesProvider);

    int streak;
    int longest;
    double weeklyRate;
    double monthlyRate;
    List<String> noteContents;
    List<String> relevantDates;

    if (habit != null) {
      streak = habit.currentStreak;
      longest = habit.longestStreak;
      weeklyRate = habit.weeklyCompletionRate;
      monthlyRate = habit.monthlyCompletionRate;
      relevantDates = habit.completedDates;
      noteContents = allNotes
          .where((n) => n.habitId == habit.id)
          .map((n) => n.content)
          .toList();
    } else {
      streak = allHabits.isEmpty
          ? 0
          : (allHabits.map((h) => h.currentStreak).reduce((a, b) => a + b) ~/
              allHabits.length);
      longest = allHabits.isEmpty
          ? 0
          : allHabits.map((h) => h.longestStreak).reduce((a, b) => a > b ? a : b);
      weeklyRate = allHabits.isEmpty
          ? 0.0
          : (allHabits.map((h) => h.weeklyCompletionRate).reduce((a, b) => a + b) /
              allHabits.length);
      monthlyRate = allHabits.isEmpty
          ? 0.0
          : (allHabits
                  .map((h) => h.monthlyCompletionRate)
                  .reduce((a, b) => a + b) /
              allHabits.length);
      relevantDates = allHabits.expand((h) => h.completedDates).toSet().toList();
      noteContents = allNotes.map((n) => n.content).toList();
    }

    final dayPatterns = HabitDateUtils.analyzeDayPatterns(relevantDates);

    final user = ref.read(currentUserProvider);
    final opinion = await HuggingFaceService.instance.generateExpertEvaluation(
      username: user?.username ?? 'Kullanıcı',
      habitTitle: habit?.title,
      streak: streak,
      longestStreak: longest,
      weeklyRate: weeklyRate,
      monthlyRate: monthlyRate,
      notes: noteContents,
      isCompletedToday: habit?.isCompletedToday ?? false,
      dayPatternsSummary: dayPatterns['summary'] as String?,
    );

    if (mounted) {
      setState(() {
        _dayPatterns = dayPatterns;
        _expertOpinion = opinion;
        _isLoadingAi = false;
      });
    }
  }

  Future<void> _createAndSavePdf() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isGeneratingPdf = true);

    try {
      final allHabits = ref.read(habitsListProvider);
      final allNotes = ref.read(allNotesProvider);

      final report = await PdfGeneratorService.instance.generateReport(
        userId: user.id,
        username: user.username,
        habit: widget.specificHabit,
        allHabits: allHabits,
        expertOpinion: _expertOpinion,
        notes: widget.specificHabit != null
            ? allNotes
                .where((n) => n.habitId == widget.specificHabit!.id)
                .toList()
            : allNotes,
      );

      ref.read(userReportsProvider.notifier).refresh();

      setState(() {
        _generatedReport = report;
        _isGeneratingPdf = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF Raporu başarıyla oluşturuldu ve saklandı: ${report.title}'),
            backgroundColor: AppColors.success,
            action: SnackBarAction(
              label: 'Görüntüle',
              textColor: Colors.white,
              onPressed: () {
                PdfGeneratorService.openPdf(report);
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGeneratingPdf = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF oluşturma hatası: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final habit = widget.specificHabit;
    final allHabits = ref.watch(habitsListProvider);

    final title = habit != null
        ? '${habit.title} - İstatistik ve AI Raporu'
        : 'Genel Grafik ve AI Uzman Raporu';

    final completedDates = habit != null
        ? habit.completedDates
        : allHabits.expand((h) => h.completedDates).toList();

    final weeklyRate = habit != null
        ? habit.weeklyCompletionRate
        : (allHabits.isEmpty
            ? 0.0
            : (allHabits.map((h) => h.weeklyCompletionRate).reduce((a, b) => a + b) /
                allHabits.length));

    final monthlyRate = habit != null
        ? habit.monthlyCompletionRate
        : (allHabits.isEmpty
            ? 0.0
            : (allHabits
                    .map((h) => h.monthlyCompletionRate)
                    .reduce((a, b) => a + b) /
                allHabits.length));

    return Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.borderHighlight, width: 1.5),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 720),
        child: Column(
          children: [
            // Başlık ve [X] Kapatma Butonu (Eskiz 1 spesifikasyonu)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.analytics_outlined, color: AppColors.accent, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textMuted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // İçerik (Grafikler + Uzman Görüşü)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Bölüm 1: Grafikler
                    Text(
                      'Grafikler & Performans Dağılımı',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.softPink,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Başarı Oranları Çubuk Grafiği
                    Container(
                      height: 140,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 100,
                          barTouchData: BarTouchData(enabled: true),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 32,
                                getTitlesWidget: (val, meta) => Text(
                                  '%${val.toInt()}',
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (val, meta) {
                                  switch (val.toInt()) {
                                    case 0:
                                      return const Text('Haftalık',
                                          style: TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold));
                                    case 1:
                                      return const Text('Aylık',
                                          style: TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold));
                                    default:
                                      return const Text('');
                                  }
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 25,
                            getDrawingHorizontalLine: (val) => FlLine(
                              color: AppColors.border.withOpacity(0.5),
                              strokeWidth: 0.8,
                            ),
                          ),
                          barGroups: [
                            BarChartGroupData(
                              x: 0,
                              barRods: [
                                BarChartRodData(
                                  toY: weeklyRate * 100,
                                  color: AppColors.accent,
                                  width: 28,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              x: 1,
                              barRods: [
                                BarChartRodData(
                                  toY: monthlyRate * 100,
                                  color: AppColors.primary,
                                  width: 28,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Aktivite Izgarası (Heatmap)
                    GithubHeatmapGrid(completedDates: completedDates, weeksCount: 8),
                    const SizedBox(height: 16),

                    // Hafta İçi vs. Hafta Sonu Dağılım Kartı
                    if (_dayPatterns != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.date_range_rounded, color: AppColors.accent, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  'Zaman & Gün Analizi (Hafta İçi vs. Hafta Sonu)',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildPatternMiniStat(
                                  'Hafta İçi',
                                  '%${_dayPatterns!['weekdayPercent']}',
                                  AppColors.accent,
                                ),
                                _buildPatternMiniStat(
                                  'Hafta Sonu',
                                  '%${_dayPatterns!['weekendPercent']}',
                                  AppColors.primary,
                                ),
                                _buildPatternMiniStat(
                                  'En İstikrarlı',
                                  '${_dayPatterns!['bestDayName']}',
                                  AppColors.success,
                                ),
                                _buildPatternMiniStat(
                                  'En Çok Aksayan',
                                  '${_dayPatterns!['worstDayName']}',
                                  AppColors.warning,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Bölüm 2: Uzman Görüşü
                    Row(
                      children: [
                        const Icon(Icons.psychology, color: AppColors.accent, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Yapay Zeka Uzman Görüşü',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.softPink,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(16),
                        border: const Border(
                          left: BorderSide(color: AppColors.accent, width: 4),
                        ),
                      ),
                      child: _isLoadingAi
                          ? const Column(
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(AppColors.accent),
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Hugging Face AI verilerinizi analiz ediyor...',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              _expertOpinion,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),

            // Alt Buton: [PDF Oluştur ve Sakla]
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  if (_generatedReport != null)
                    Expanded(
                      child: CustomPinkButton(
                        text: 'PDF Dosyasını Aç',
                        variant: PinkButtonVariant.secondary,
                        icon: Icons.open_in_new,
                        onPressed: () {
                          PdfGeneratorService.openPdf(_generatedReport!);
                        },
                      ),
                    ),
                  if (_generatedReport != null) const SizedBox(width: 12),
                  Expanded(
                    child: CustomPinkButton(
                      text: _generatedReport != null
                          ? 'Yeniden PDF Üret'
                          : 'PDF Oluştur ve Sakla',
                      icon: Icons.picture_as_pdf,
                      isLoading: _isGeneratingPdf,
                      onPressed: _createAndSavePdf,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternMiniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
