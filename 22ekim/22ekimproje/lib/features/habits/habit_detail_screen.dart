import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_pink_button.dart';
import '../../core/widgets/right_action_sidebar.dart';
import '../../data/repositories/habit_repository.dart';
import '../../data/repositories/note_repository.dart';
import '../../data/services/notification_service.dart';
import '../mentor/mentor_chat_screen.dart';
import '../notes/notes_modal_sheet.dart';
import '../reports/pdf_archive_modal.dart';
import '../reports/report_preview_dialog.dart';
import '../settings/legal_and_account_dialog.dart';
import 'widgets/github_heatmap_grid.dart';
import 'widgets/streak_calendar_widget.dart';

class HabitDetailScreen extends ConsumerStatefulWidget {
  final String habitId;

  const HabitDetailScreen({super.key, required this.habitId});

  @override
  ConsumerState<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends ConsumerState<HabitDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(habitsListProvider);
    final allNotes = ref.watch(allNotesProvider);

    final habitIndex = habits.indexWhere((h) => h.id == widget.habitId);
    if (habitIndex == -1) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Alışkanlık Bulunamadı')),
        body: const Center(
          child: Text('Bu alışkanlık silinmiş veya mevcut değil.'),
        ),
      );
    }

    final habit = habits[habitIndex];
    final habitNotes = allNotes.where((n) => n.habitId == habit.id).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Row(
          children: [
            // ================= SOL / ANA GÖVDE (SPLIT LAYOUT %82) =================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Üst Başlık Bandı: ALIŞKANLIK DETAY
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      border: Border(
                        bottom: BorderSide(color: AppColors.border, width: 1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ALIŞKANLIK DETAY',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                habit.title,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.accent,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // İki Sayaç Rozeti: Aktif Zincir & En Uzun Zincir
                        Row(
                          children: [
                            _buildStatBadge(
                              label: 'Aktif',
                              value: '${habit.currentStreak} Gün',
                              color: AppColors.accent,
                            ),
                            const SizedBox(width: 8),
                            _buildStatBadge(
                              label: 'Rekor',
                              value: '${habit.longestStreak} Gün',
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Ana İçerik: Takvim + Heatmap Grid
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 1. Merkez Kart: Takvim (Yapılan Günleri Onayla)
                          StreakCalendarWidget(
                            completedDates: habit.completedDates,
                            onDayToggled: (dateStr) async {
                              await ref
                                  .read(habitsListProvider.notifier)
                                  .toggleDate(habit.id, dateStr);
                            },
                          ),
                          const SizedBox(height: 16),

                          // 2. Takvimin Hemen Altındaki GitHub Katkı Grafiği (Heatmap)
                          GithubHeatmapGrid(
                            completedDates: habit.completedDates,
                            weeksCount: 10,
                          ),
                          const SizedBox(height: 16),

                          // Başarı Yüzdeleri Özet Kartı
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildPercentColumn(
                                  'Haftalık Başarı',
                                  '%${(habit.weeklyCompletionRate * 100).toStringAsFixed(0)}',
                                  AppColors.accent,
                                ),
                                Container(
                                  width: 1,
                                  height: 36,
                                  color: AppColors.border,
                                ),
                                _buildPercentColumn(
                                  'Aylık Başarı',
                                  '%${(habit.monthlyCompletionRate * 100).toStringAsFixed(0)}',
                                  AppColors.softPink,
                                ),
                                Container(
                                  width: 1,
                                  height: 36,
                                  color: AppColors.border,
                                ),
                                _buildPercentColumn(
                                  'Özel Notlar',
                                  '${habitNotes.length} Adet',
                                  AppColors.textPrimary,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),

                  // Alt Aksiyon Çubuğu: [Raporla] ve [Geri] (Eskiz 1 - Alt)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: const Border(
                        top: BorderSide(color: AppColors.border, width: 1.5),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // [Raporla] Butonu (Alışkanlığa özel PDF)
                        Expanded(
                          child: CustomPinkButton(
                            text: 'Raporla',
                            variant: PinkButtonVariant.primary,
                            icon: Icons.picture_as_pdf,
                            height: 48,
                            onPressed: () {
                              ReportPreviewDialog.show(context, specificHabit: habit);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        // [Geri] Butonu (Ana sayfaya döner)
                        Expanded(
                          child: CustomPinkButton(
                            text: 'Geri',
                            variant: PinkButtonVariant.outline,
                            icon: Icons.arrow_back,
                            height: 48,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ================= SAĞ DİKEY İKON MENÜSÜ (SPLIT LAYOUT %18) =================
            RightActionSidebar(
              notesCount: habitNotes.length,
              notesTooltip: 'Bu Alışkanlığa Özel Not Ekle / Görüntüle',
              documentsTooltip: 'Bu Alışkanlığa Ait Kayıtlı PDF Raporları',
              onNotificationsTap: () async {
                await NotificationService.instance.showNotification(
                  title: 'Alışkanlık Hatırlatıcısı',
                  body: '"${habit.title}" alışkanlığını bugün tamamladın mı?',
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('"${habit.title}" için hatırlatıcı gönderildi!'),
                      backgroundColor: AppColors.primaryVariant,
                    ),
                  );
                }
              },
              onNotesTap: () {
                NotesModalSheet.show(context, specificHabit: habit);
              },
              onMentorTap: () {
                MentorChatScreen.show(context, specificHabit: habit);
              },
              onDocumentsTap: () {
                PdfArchiveModal.show(context, specificHabit: habit);
              },
              onAccountTap: () {
                LegalAndAccountDialog.show(context, initialTab: LegalTab.account);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPercentColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
