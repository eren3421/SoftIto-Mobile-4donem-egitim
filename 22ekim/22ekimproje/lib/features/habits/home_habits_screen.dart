import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../core/widgets/custom_pink_button.dart';
import '../../core/widgets/right_action_sidebar.dart';
import '../../data/models/habit_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/habit_repository.dart';
import '../../data/repositories/note_repository.dart';
import '../../data/services/notification_service.dart';
import '../mentor/mentor_chat_screen.dart';
import '../notes/notes_modal_sheet.dart';
import '../reports/pdf_archive_modal.dart';
import '../reports/report_preview_dialog.dart';
import '../settings/legal_and_account_dialog.dart';
import 'habit_detail_screen.dart';
import 'widgets/add_habit_dialog.dart';

class HomeHabitsScreen extends ConsumerWidget {
  const HomeHabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsListProvider);
    final user = ref.watch(currentUserProvider);
    final notes = ref.watch(allNotesProvider);

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
                  // Üst Başlık Bandı: YAPILACAKLAR
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      border: Border(
                        bottom: BorderSide(color: AppColors.border, width: 1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) =>
                                      AppColors.logoGradient.createShader(bounds),
                                  child: Text(
                                    'MENTOR',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: const BoxDecoration(
                                    color: AppColors.accent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Hoş geldin, ${user?.username ?? "Kullanıcı"}',
                                  style: const TextStyle(
                                    color: AppColors.softPink,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'YAPILACAKLAR',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        // Günlük Tamamlanma Sayacı
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.primary, width: 1),
                          ),
                          child: Text(
                            '${habits.where((h) => h.isCompletedToday).length} / ${habits.length} Bitti',
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Alışkanlıklar Listesi
                  Expanded(
                    child: habits.isEmpty
                        ? Center(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    size: 64,
                                    color: AppColors.textMuted.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Henüz alışkanlık eklemediniz!',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Aşağıdaki "[Ekle]" butonuna basarak ilk alışkanlığınızı ekleyebilir ve zinciri başlatabilirsiniz.',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 20),
                                  CustomPinkButton(
                                    text: 'İlk Alışkanlığını Ekle',
                                    icon: Icons.add,
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) => const AddHabitDialog(),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            itemCount: habits.length,
                            itemBuilder: (context, index) {
                              final habit = habits[index];
                              return _buildHabitCard(context, ref, habit);
                            },
                          ),
                  ),

                  // Alt Aksiyon Çubuğu: [Rapor Oluştur] ve [Ekle]
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
                        // [Rapor Oluştur] Butonu (Eskiz 1 - Sol Alt)
                        Expanded(
                          child: CustomPinkButton(
                            text: 'Rapor Oluştur',
                            variant: PinkButtonVariant.secondary,
                            icon: Icons.analytics_outlined,
                            height: 48,
                            onPressed: () {
                              ReportPreviewDialog.show(context);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        // [Ekle] Butonu (Eskiz 1 - Sağ Alt)
                        Expanded(
                          child: CustomPinkButton(
                            text: 'Ekle',
                            variant: PinkButtonVariant.primary,
                            icon: Icons.add,
                            height: 48,
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => const AddHabitDialog(),
                              );
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
              notesCount: notes.length,
              notesTooltip: 'Not Ekle / Notları Görüntüle (Tüm Notlar)',
              documentsTooltip: 'Gizlilik, Belgeler & PDF Arşivi',
              onNotificationsTap: () async {
                await NotificationService.instance.showNotification(
                  title: 'MENTOR Hatırlatıcı',
                  body: 'Bugünkü alışkanlık zincirini kırmamak için tek dokunuş yapmayı unutma!',
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Hatırlatıcı bildirimi gönderildi!'),
                      backgroundColor: AppColors.primaryVariant,
                    ),
                  );
                }
              },
              onNotesTap: () {
                NotesModalSheet.show(context);
              },
              onMentorTap: () {
                MentorChatScreen.show(context);
              },
              onDocumentsTap: () {
                _showDocumentsMenu(context);
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

  void _showDocumentsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Belgeler & Bilgi Menüsü',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textMuted),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf, color: AppColors.accent),
                  title: const Text('Kayıtlı PDF Rapor Arşivi',
                      style: TextStyle(color: AppColors.textPrimary)),
                  subtitle: const Text('Cihazda saklanan tüm raporlar',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.softPink),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    PdfArchiveModal.show(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.softPink),
                  title: const Text('Gizlilik Politikası',
                      style: TextStyle(color: AppColors.textPrimary)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.softPink),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    LegalAndAccountDialog.show(context, initialTab: LegalTab.privacy);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.help_outline, color: AppColors.softPink),
                  title: const Text('Sıkça Sorulan Sorular (S.S.S.)',
                      style: TextStyle(color: AppColors.textPrimary)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.softPink),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    LegalAndAccountDialog.show(context, initialTab: LegalTab.faq);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.contact_support_outlined, color: AppColors.softPink),
                  title: const Text('İletişim & Hakkında',
                      style: TextStyle(color: AppColors.textPrimary)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.softPink),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    LegalAndAccountDialog.show(context, initialTab: LegalTab.contact);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHabitCard(
    BuildContext context,
    WidgetRef ref,
    HabitModel habit,
  ) {
    final isDoneToday = habit.isCompletedToday;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDoneToday ? AppColors.accent.withOpacity(0.6) : AppColors.border,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Sol Baştaki Tek Dokunuşla Onay Dairesi
          InkWell(
            onTap: () async {
              await ref
                  .read(habitsListProvider.notifier)
                  .toggleDate(habit.id, HabitDateUtils.todayString);

              if (!isDoneToday) {
                NotificationService.instance.showNotification(
                  title: 'Harika İş!',
                  body: '"${habit.title}" bugün tamamlandı! Zincirin ${habit.currentStreak + 1} güne ulaştı 🔥',
                );
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isDoneToday ? AppColors.accent : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDoneToday ? AppColors.accent : AppColors.softPink,
                  width: 2,
                ),
                boxShadow: isDoneToday
                    ? [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: isDoneToday
                  ? const Icon(Icons.check, size: 20, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 14),

          // Alışkanlık Adı & Streak Rozeti
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    decoration: isDoneToday ? TextDecoration.lineThrough : null,
                    decorationColor: AppColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryVariant.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '🔥 ${habit.currentStreak} gün',
                        style: const TextStyle(
                          color: AppColors.softPink,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (habit.reminderTime != null) ...[
                      const SizedBox(width: 6),
                      Icon(Icons.alarm, size: 12, color: AppColors.textMuted),
                      const SizedBox(width: 2),
                      Text(
                        habit.reminderTime!,
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Sağ Butonlar: [Görüntüle] ve [Sil]
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // [Görüntüle] Butonu
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.surfaceVariant,
                  foregroundColor: AppColors.softPink,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: AppColors.primary, width: 1),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => HabitDetailScreen(habitId: habit.id),
                    ),
                  );
                },
                child: const Text(
                  'Görüntüle',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 6),

              // [Sil] Butonu
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
                tooltip: 'Alışkanlığı Sil',
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: AppColors.surface,
                      title: const Text('Alışkanlığı Sil'),
                      content: Text(
                        '"${habit.title}" alışkanlığını ve ilgili tüm notlarını silmek istiyor musunuz?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Vazgeç'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text('Sil'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await ref.read(habitsListProvider.notifier).deleteHabit(habit.id);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
