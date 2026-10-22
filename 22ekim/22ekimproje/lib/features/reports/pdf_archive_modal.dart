import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../data/services/pdf_generator_service.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_pink_button.dart';
import '../../data/models/habit_model.dart';
import '../../data/repositories/report_repository.dart';

class PdfArchiveModal extends ConsumerWidget {
  final HabitModel? specificHabit;

  const PdfArchiveModal({super.key, this.specificHabit});

  static void show(BuildContext context, {HabitModel? specificHabit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PdfArchiveModal(specificHabit: specificHabit),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = ref.watch(userReportsProvider);

    final filteredReports = specificHabit != null
        ? reports.where((r) => r.habitId == specificHabit!.id).toList()
        : reports;

    final title = specificHabit != null
        ? '${specificHabit!.title} - Kayıtlı PDF Raporları'
        : 'Kayıtlı PDF Rapor Arşivi';

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: AppColors.borderHighlight, width: 2),
        ),
      ),
      child: Column(
        children: [
          // Başlık
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.picture_as_pdf, color: AppColors.accent, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Liste
          Expanded(
            child: filteredReports.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder_open_outlined,
                          size: 54,
                          color: AppColors.textMuted.withOpacity(0.5),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Henüz oluşturulmuş bir PDF raporu yok.',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          '"Rapor Oluştur" butonuna basarak yeni bir rapor oluşturabilirsiniz.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredReports.length,
                    itemBuilder: (context, index) {
                      final report = filteredReports[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    report.title,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryVariant,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '%${(report.completionRate * 100).toStringAsFixed(0)} Başarı',
                                    style: const TextStyle(
                                      color: AppColors.accent,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Oluşturulma: ${DateFormat("dd MMMM yyyy HH:mm", "tr_TR").format(report.createdAt)}',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.delete_outline,
                                      size: 16, color: AppColors.danger),
                                  label: const Text('Sil',
                                      style: TextStyle(
                                          color: AppColors.danger, fontSize: 12)),
                                  onPressed: () async {
                                    await ref
                                        .read(userReportsProvider.notifier)
                                        .deleteReport(report.id);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Rapor silindi.'),
                                          backgroundColor: AppColors.danger,
                                        ),
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  tooltip: 'İndir',
                                  icon: const Icon(Icons.download_rounded,
                                      size: 20, color: AppColors.accent),
                                  onPressed: () {
                                    PdfGeneratorService.downloadPdf(report);
                                  },
                                ),
                                const SizedBox(width: 4),
                                CustomPinkButton(
                                  text: 'Aç / Görüntüle',
                                  icon: Icons.open_in_new,
                                  height: 36,
                                  fontSize: 12,
                                  onPressed: () {
                                    PdfGeneratorService.openPdf(report);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
