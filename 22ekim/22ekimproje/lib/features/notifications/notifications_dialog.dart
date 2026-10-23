import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_pink_button.dart';
import '../../data/models/habit_model.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/habit_repository.dart';
import '../../data/services/notification_service.dart';

class NotificationsDialog extends ConsumerStatefulWidget {
  final HabitModel? specificHabit;

  const NotificationsDialog({super.key, this.specificHabit});

  static Future<void> show(BuildContext context, {HabitModel? specificHabit}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => NotificationsDialog(specificHabit: specificHabit),
    );
  }

  @override
  ConsumerState<NotificationsDialog> createState() => _NotificationsDialogState();
}

class _NotificationsDialogState extends ConsumerState<NotificationsDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isWebPermitted = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkPermission();
  }

  void _checkPermission() {
    setState(() {
      _isWebPermitted = NotificationService.instance.isWebNotificationGranted();
    });
  }

  Future<void> _requestPermission() async {
    final granted = await NotificationService.instance.requestWebPermission();
    setState(() {
      _isWebPermitted = granted;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            granted
                ? 'Tarayıcı bildirim izni başarıyla verildi! 🎉'
                : 'Bildirim izni verilmedi veya engellendi.',
          ),
          backgroundColor: granted ? AppColors.success : AppColors.danger,
        ),
      );
    }
  }

  Future<void> _sendTestNotification() async {
    await NotificationService.instance.testNotification();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test bildirimi gönderildi! (Pop-up ve uygulama içi kontrol edin)'),
          backgroundColor: AppColors.primaryVariant,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _editHabitReminder(HabitModel habit) async {
    final initial = habit.reminderTime != null
        ? _parseTime(habit.reminderTime!)
        : const TimeOfDay(hour: 20, minute: 0);

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final hour = picked.hour.toString().padLeft(2, '0');
      final minute = picked.minute.toString().padLeft(2, '0');
      final newTimeStr = '$hour:$minute';

      await ref.read(habitsListProvider.notifier).updateReminderTime(habit.id, newTimeStr);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${habit.title}" hatırlatıcı saati $newTimeStr olarak güncellendi!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Future<void> _removeHabitReminder(HabitModel habit) async {
    await ref.read(habitsListProvider.notifier).updateReminderTime(habit.id, null);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${habit.title}" hatırlatıcısı kaldırıldı.'),
          backgroundColor: AppColors.primaryVariant,
        ),
      );
    }
  }

  TimeOfDay _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (_) {
      return const TimeOfDay(hour: 20, minute: 0);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(habitsListProvider);
    final recentNotifications = NotificationService.instance.recentNotifications;

    return Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.borderHighlight, width: 1.5),
      ),
      child: Container(
        width: 560,
        height: 620,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Üst Başlık & Kapat Butonu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.accent.withOpacity(0.4)),
                      ),
                      child: const Icon(Icons.notifications_active, color: AppColors.accent, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bildirimler & Hatırlatıcılar',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Text(
                          'Canlı pop-up ve zamanlı alışkanlık alarmları',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tab Başlıkları
            TabBar(
              controller: _tabController,
              labelColor: AppColors.accent,
              unselectedLabelColor: AppColors.textMuted,
              indicatorColor: AppColors.accent,
              indicatorWeight: 3,
              tabs: [
                Tab(
                  icon: const Icon(Icons.alarm, size: 18),
                  text: 'Hatırlatıcı Saatleri (${habits.where((h) => h.reminderTime != null).length})',
                ),
                Tab(
                  icon: const Icon(Icons.history, size: 18),
                  text: 'Bildirim Geçmişi (${recentNotifications.length})',
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Tab İçerikleri
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // 1. TAB: Hatırlatıcı Saatleri ve Sistem İzinleri
                  _buildRemindersTab(habits),

                  // 2. TAB: Bildirim Geçmişi
                  _buildHistoryTab(recentNotifications),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemindersTab(List<HabitModel> habits) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Masaüstü Bildirim İzni Kartı
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _isWebPermitted
                  ? AppColors.success.withOpacity(0.12)
                  : AppColors.accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isWebPermitted
                    ? AppColors.success.withOpacity(0.5)
                    : AppColors.accent.withOpacity(0.5),
                width: 1.2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _isWebPermitted ? Icons.check_circle : Icons.warning_amber_rounded,
                      color: _isWebPermitted ? AppColors.success : AppColors.accent,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _isWebPermitted
                            ? 'Masaüstü & Tarayıcı Pop-up Bildirimleri Aktif'
                            : 'Masaüstü / Tarayıcı Pop-up Bildirimi Kapalı',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _isWebPermitted ? AppColors.success : AppColors.accent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _isWebPermitted
                      ? 'Harika! Uygulama simge durumundayken veya başka penceredeyken de Windows bildirim merkezinden canlı pop-up alacaksınız.'
                      : 'Uygulama arka plandayken veya başka penceredeyken hatırlatıcıları kaçırmamak için bildirim izni verin.',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
                if (!_isWebPermitted) ...[
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    icon: const Icon(Icons.notifications_active, size: 16),
                    label: const Text('Pop-up Bildirim İznini Aç', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    onPressed: _requestPermission,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 2. Anlık Test Butonu
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Bildirimleri Test Et',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      Text(
                        'Pop-up ve uygulama içi animasyonu hemen dene',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  icon: const Icon(Icons.send, size: 14),
                  label: const Text('Test Bildirimi Gönder', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  onPressed: _sendTestNotification,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Alışkanlıklar Listesi & Hatırlatıcı Ayarları
          Text(
            'ALIŞKANLIK HATIRLATICILARI',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),

          if (habits.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: const Text(
                'Henüz eklenmiş bir alışkanlığınız yok.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            )
          else
            ...habits.map((habit) {
              final hasReminder = habit.reminderTime != null && habit.reminderTime!.isNotEmpty;
              final isDone = habit.isCompletedToday;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: hasReminder ? AppColors.accent.withOpacity(0.4) : AppColors.border,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Sol İkon
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: hasReminder
                            ? AppColors.accent.withOpacity(0.15)
                            : AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: hasReminder ? AppColors.accent : AppColors.border,
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        hasReminder ? Icons.alarm_on : Icons.alarm_off,
                        color: hasReminder ? AppColors.accent : AppColors.textMuted,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Alışkanlık Adı & Durum
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habit.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                hasReminder ? '⏰ Her gün ${habit.reminderTime!}' : 'Hatırlatıcı yok',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: hasReminder ? AppColors.softPink : AppColors.textMuted,
                                  fontWeight: hasReminder ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                              if (isDone) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    '✓ Tamamlandı',
                                    style: TextStyle(color: AppColors.success, fontSize: 9, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    // İşlem Butonları
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Saat Belirle / Değiştir
                        IconButton(
                          icon: const Icon(Icons.edit_calendar, color: AppColors.softPink, size: 20),
                          tooltip: hasReminder ? 'Saati Değiştir' : 'Hatırlatıcı Saati Ekle',
                          onPressed: () => _editHabitReminder(habit),
                        ),
                        // Anında Test Et
                        IconButton(
                          icon: const Icon(Icons.notifications_active_outlined, color: AppColors.accent, size: 20),
                          tooltip: 'Bu Alışkanlık İçin Şimdi Bildirim Gönder',
                          onPressed: () async {
                            await NotificationService.instance.showNotification(
                              id: habit.id.hashCode,
                              title: '⏰ Alışkanlık Vakti: ${habit.title}',
                              body: 'Bugünkü hedefini tamamlamak ve zincirini korumak için tek dokunuş yap! 🔥',
                              habitId: habit.id,
                              habitTitle: habit.title,
                              type: 'reminder',
                            );
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('"${habit.title}" için canlı bildirim gönderildi!'),
                                  backgroundColor: AppColors.success,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        ),
                        if (hasReminder)
                          IconButton(
                            icon: const Icon(Icons.alarm_off, color: AppColors.danger, size: 18),
                            tooltip: 'Hatırlatıcıyı Kaldır',
                            onPressed: () => _removeHabitReminder(habit),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(List<NotificationModel> recentNotifications) {
    if (recentNotifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off_outlined, size: 48, color: AppColors.textMuted.withOpacity(0.4)),
            const SizedBox(height: 12),
            const Text(
              'Henüz kayıtlı bir bildirim yok.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surfaceVariant,
                foregroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.send, size: 16),
              label: const Text('Test Bildirimi Gönder'),
              onPressed: _sendTestNotification,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'GÖNDERİLEN BİLDİRİMLER',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.textMuted,
              ),
            ),
            TextButton.icon(
              icon: const Icon(Icons.delete_sweep, size: 16, color: AppColors.textMuted),
              label: const Text('Temizle', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
              onPressed: () {
                setState(() {
                  NotificationService.instance.clearHistory();
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: recentNotifications.length,
            itemBuilder: (context, index) {
              final item = recentNotifications[index];
              final timeFormatted =
                  '${item.timestamp.hour.toString().padLeft(2, '0')}:${item.timestamp.minute.toString().padLeft(2, '0')}';

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.notifications_outlined, size: 16, color: AppColors.accent),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                timeFormatted,
                                style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.body,
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
