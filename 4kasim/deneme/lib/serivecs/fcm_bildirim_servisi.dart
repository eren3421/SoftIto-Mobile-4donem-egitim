import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> fcmBackgroundHandler(RemoteMessage message) async {}

class FcmBildirimServisi {
  FirebaseMessaging get _fcm => FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> baslat({
    required Function(RemoteMessage message) onMesajGeldi,
  }) async {
    const androidSettings = AndroidInitializationSettings(
      "@mipmap/ic_launcher",
    );
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: iosSettings,
    );
    try {
      await _localPlugin.initialize(initSettings);
    } catch (_) {}

    try {
      await _fcm.requestPermission(alert: true, badge: true, sound: true);
      FirebaseMessaging.onMessage.listen((message) {
        _yerelBildirimGoster(message);
        onMesajGeldi(message);
      });
      FirebaseMessaging.onBackgroundMessage(fcmBackgroundHandler);
    } catch (_) {}
  }

  Future<String?> tokenAl() async {
    try {
      return await _fcm.getToken();
    } catch (e) {
      return null;
    }
  }

  Future<void> konuyaAboneOl(String konu) async {
    try {
      await _fcm.subscribeToTopic(konu);
    } catch (_) {}
  }

  Future<void> konudanAyril(String konu) async {
    try {
      await _fcm.unsubscribeFromTopic(konu);
    } catch (_) {}
  }

  Future<void> _yerelBildirimGoster(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'softito_fcm_channel_id',
      "Softito Bildirimleri",
      channelDescription: "FCM Push bildirimi",
      importance: Importance.max,
      priority: Priority.high,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
    );
    await _localPlugin.show(
      message.hashCode,
      message.notification?.title ?? "Yeni Bildirim",
      message.notification?.body ?? '',
      details,
    );
  }
}