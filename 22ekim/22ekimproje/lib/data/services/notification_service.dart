import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../core/services/web_notification_helper.dart';
import '../../core/utils/date_utils.dart';
import '../local/hive_storage_service.dart';
import '../models/notification_model.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  Timer? _reminderTimer;

  // Hatırlatıcıların aynı gün/dakikada tekrar tekrar çalmasını önleyen anahtarlar
  final Set<String> _firedKeys = {};

  // Uygulama içi banner'lar için canlı yayın akışı
  final StreamController<NotificationModel> _inAppController =
      StreamController<NotificationModel>.broadcast();
  Stream<NotificationModel> get inAppStream => _inAppController.stream;

  // Bildirim geçmişi listesi (Son 50 bildirim)
  final List<NotificationModel> _recentNotifications = [];
  List<NotificationModel> get recentNotifications =>
      List.unmodifiable(_recentNotifications);

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      if (!kIsWeb) {
        const AndroidInitializationSettings androidSettings =
            AndroidInitializationSettings('@mipmap/ic_launcher');

        const DarwinInitializationSettings iosSettings =
            DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

        const InitializationSettings initSettings = InitializationSettings(
          android: androidSettings,
          iOS: iosSettings,
          macOS: iosSettings,
        );

        await _notificationsPlugin.initialize(
          initSettings,
          onDidReceiveNotificationResponse: (details) {
            debugPrint('Notification clicked: ${details.payload}');
          },
        );
      }

      _isInitialized = true;
      debugPrint('NotificationService initialized successfully.');

      // Arka plan hatırlatıcı motorunu başlat (Her 15 saniyede kontrol eder)
      _startReminderEngine();
    } catch (e) {
      debugPrint('NotificationService init error (Safe fallback): $e');
    }
  }

  /// Web tarayıcı bildirim iznini sor
  Future<bool> requestWebPermission() async {
    try {
      final granted = await WebNotificationHelper.requestPermission();
      return granted;
    } catch (e) {
      debugPrint('Web permission request error: $e');
      return false;
    }
  }

  /// Tarayıcı izin durumunu döndür ('granted', 'denied', 'default', 'unsupported')
  String getWebPermissionStatus() {
    return WebNotificationHelper.getPermission();
  }

  bool isWebNotificationGranted() {
    return WebNotificationHelper.getPermission() == 'granted';
  }

  /// Periyodik hatırlatıcı motoru: Zamanı gelen alışkanlıkları otomatik tetikler
  void _startReminderEngine() {
    _reminderTimer?.cancel();
    _reminderTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _checkReminders();
    });
    // İlk çalıştırmada hemen bir kontrol yap
    _checkReminders();
  }

  void _checkReminders() {
    try {
      final now = DateTime.now();
      final currentHour = now.hour.toString().padLeft(2, '0');
      final currentMinute = now.minute.toString().padLeft(2, '0');
      final currentFormattedTime = '$currentHour:$currentMinute';
      final todayStr = HabitDateUtils.todayString;

      final habits = HiveStorageService.instance.getAllHabits();

      for (final habit in habits) {
        if (habit.reminderTime == null || habit.reminderTime!.trim().isEmpty) {
          continue;
        }

        final habitTime = _normalizeTime(habit.reminderTime!);
        if (habitTime == currentFormattedTime) {
          final fireKey = '$todayStr-${habit.id}-$habitTime';

          // Zaten bu dakika tetiklendiyse geç
          if (_firedKeys.contains(fireKey)) {
            continue;
          }

          // Eğer bugün zaten tamamlandıysa hatırlatıp rahatsız etme
          if (habit.isCompletedToday) {
            continue;
          }

          _firedKeys.add(fireKey);

          showNotification(
            id: habit.id.hashCode,
            title: '⏰ Alışkanlık Vakti: ${habit.title}',
            body: habit.currentStreak > 0
                ? 'Zincirini (${habit.currentStreak} gün) kırmamak için şimdi hedefini tamamla! 🔥'
                : 'Bugünkü hedefini tamamlamak ve yeni bir zincir başlatmak için tek dokunuş yap! ✨',
            habitId: habit.id,
            habitTitle: habit.title,
            type: 'reminder',
          );
        }
      }
    } catch (e) {
      debugPrint('Reminder engine check error: $e');
    }
  }

  String _normalizeTime(String raw) {
    final parts = raw.split(':');
    if (parts.length != 2) return raw.trim();
    final h = parts[0].trim().padLeft(2, '0');
    final m = parts[1].trim().padLeft(2, '0');
    return '$h:$m';
  }

  /// Anlık bildirim gösterimi (Pop-up + Uygulama İçi Canlı Bildirim)
  Future<void> showNotification({
    int id = 0,
    required String title,
    required String body,
    String? habitId,
    String? habitTitle,
    String type = 'reminder',
    String? payload,
  }) async {
    final notificationItem = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      habitId: habitId,
      habitTitle: habitTitle,
      type: type,
      timestamp: DateTime.now(),
    );

    // 1. Bildirim Geçmişine Ekle (En fazla 50 adet)
    _recentNotifications.insert(0, notificationItem);
    if (_recentNotifications.length > 50) {
      _recentNotifications.removeLast();
    }

    // 2. Uygulama İçi Canlı Bildirim Akışına Gönder
    _inAppController.add(notificationItem);

    // 3. Web Pop-up Bildirimi Göster (Tarayıcı / Windows Masaüstü)
    if (kIsWeb) {
      WebNotificationHelper.show(title, body);
    } else {
      // 4. Mobil / Masaüstü Native Bildirimi
      try {
        const AndroidNotificationDetails androidDetails =
            AndroidNotificationDetails(
          'mentor_channel',
          'Mentor Alışkanlık Bildirimleri',
          channelDescription:
              'Günlük alışkanlık hatırlatıcıları ve tebrik mesajları',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        );

        const DarwinNotificationDetails darwinDetails =
            DarwinNotificationDetails();

        const NotificationDetails platformDetails = NotificationDetails(
          android: androidDetails,
          iOS: darwinDetails,
          macOS: darwinDetails,
        );

        await _notificationsPlugin.show(
          id,
          title,
          body,
          platformDetails,
          payload: payload ?? habitId,
        );
      } catch (e) {
        debugPrint('Native bildirim hatası: $e');
      }
    }
  }

  /// Hızlı test bildirimi gönder (Kullanıcının pop-up ve uygulama içi bildirimi görmesi için)
  Future<void> testNotification() async {
    await showNotification(
      id: 999999,
      title: '🔔 MENTOR Bildirim Sistemi Aktif',
      body:
          'Tebrikler! Masaüstü pop-up bildirimleri ve uygulama içi hatırlatıcılar başarıyla çalışıyor 🎉',
      type: 'test',
    );
  }

  void markAllAsRead() {
    for (int i = 0; i < _recentNotifications.length; i++) {
      _recentNotifications[i] =
          _recentNotifications[i].copyWith(isRead: true);
    }
  }

  void clearHistory() {
    _recentNotifications.clear();
  }

  void dispose() {
    _reminderTimer?.cancel();
    _inAppController.close();
  }
}
