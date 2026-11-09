import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'web_bildirim_stub.dart'
    if (dart.library.js_interop) 'web_bildirim_web.dart';

@pragma('vm:entry-point')
Future<void> fcmBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}
}

class FcmBildirimServisi {
  static const String kanalId = 'softito_fcm_channel_id';
  static const String kanalAdi = 'Softito Bildirimleri';
  static const String kanalAciklamasi =
      'FCM Push ve Uygulama İçi Bildirim Kanalı';

  FirebaseMessaging get _fcm => FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localPlugin =
      FlutterLocalNotificationsPlugin();

  bool _izinVerildiMi = false;
  bool get izinVerildiMi => _izinVerildiMi;

  Future<void> baslat({
    required Function(RemoteMessage message) onMesajGeldi,
    Function(String? payload)? onBildirimTiklandi,
  }) async {
    if (kIsWeb) {
      webBildirimIzinIste();
      _izinVerildiMi = true;
    } else {
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        defaultPresentAlert: true,
        defaultPresentBadge: true,
        defaultPresentSound: true,
        defaultPresentBanner: true,
        defaultPresentList: true,
      );
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
        macOS: iosSettings,
      );

      try {
        await _localPlugin.initialize(
          initSettings,
          onDidReceiveNotificationResponse: (NotificationResponse response) {
            onBildirimTiklandi?.call(response.payload);
          },
        );

        final androidPlugin = _localPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        if (androidPlugin != null) {
          const channel = AndroidNotificationChannel(
            kanalId,
            kanalAdi,
            description: kanalAciklamasi,
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
          );
          await androidPlugin.createNotificationChannel(channel);
          final androidGranted =
              await androidPlugin.requestNotificationsPermission();
          if (androidGranted != null) {
            _izinVerildiMi = androidGranted;
          }
        }

        final iosPlugin = _localPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
        if (iosPlugin != null) {
          final iosGranted = await iosPlugin.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
          if (iosGranted != null) {
            _izinVerildiMi = iosGranted;
          }
        }

        final macosPlugin = _localPlugin
            .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin
            >();
        if (macosPlugin != null) {
          final macosGranted = await macosPlugin.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
          if (macosGranted != null) {
            _izinVerildiMi = macosGranted;
          }
        }
      } catch (_) {}
    }

    if (Firebase.apps.isEmpty) {
      _izinVerildiMi = true;
      return;
    }

    try {
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      _izinVerildiMi =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;

      if (!kIsWeb) {
        await _fcm.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
        FirebaseMessaging.onBackgroundMessage(fcmBackgroundHandler);
      }

      // Uygulama açıkken (foreground) gelen bildirimler
      FirebaseMessaging.onMessage.listen((message) {
        _fcmYerelBildirimGoster(message);
        onMesajGeldi(message);
      });

      // Uygulama arka plandayken bildirime tıklanarak açıldığında
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        onMesajGeldi(message);
        onBildirimTiklandi?.call(message.messageId);
      });

      // Uygulama tamamen kapalıyken bildirime tıklanarak açıldığında
      final initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        onMesajGeldi(initialMessage);
        onBildirimTiklandi?.call(initialMessage.messageId);
      }
    } catch (_) {
      _izinVerildiMi = true;
    }
  }

  Future<String?> tokenAl() async {
    if (Firebase.apps.isEmpty) return null;
    try {
      return await _fcm.getToken();
    } catch (e) {
      return null;
    }
  }

  Future<void> konuyaAboneOl(String konu) async {
    if (kIsWeb || Firebase.apps.isEmpty) return;
    try {
      await _fcm.subscribeToTopic(konu);
    } catch (_) {}
  }

  Future<void> konudanAyril(String konu) async {
    if (kIsWeb || Firebase.apps.isEmpty) return;
    try {
      await _fcm.unsubscribeFromTopic(konu);
    } catch (_) {}
  }

  Future<void> yerelBildirimGoster({
    required String baslik,
    required String icerik,
    String? payload,
    int? id,
  }) async {
    if (kIsWeb) {
      webBildirimGoster(baslik, icerik);
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      kanalId,
      kanalAdi,
      channelDescription: kanalAciklamasi,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );
    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      presentBanner: true,
      presentList: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );
    try {
      await _localPlugin.show(
        id ?? DateTime.now().millisecondsSinceEpoch.remainder(100000),
        baslik,
        icerik,
        details,
        payload: payload,
      );
    } catch (_) {}
  }

  Future<void> _fcmYerelBildirimGoster(RemoteMessage message) async {
    final baslik =
        message.notification?.title ??
        message.data['title']?.toString() ??
        'Yeni Bildirim';
    final icerik =
        message.notification?.body ?? message.data['body']?.toString() ?? '';

    await yerelBildirimGoster(
      id: message.hashCode,
      baslik: baslik,
      icerik: icerik,
      payload: message.messageId,
    );
  }

  Future<void> tumSistemBildirimleriniTemizle() async {
    if (kIsWeb) return;
    try {
      await _localPlugin.cancelAll();
    } catch (_) {}
  }
}