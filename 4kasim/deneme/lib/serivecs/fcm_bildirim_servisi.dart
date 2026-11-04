import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
@pragma('vm:entry-point');
Future<void> fcmBackgroundHandler(RemoteMessage message) async{}
class FcmBildirimServisi{
    final FirebaseMessaging _fcm =FirebaseMessaging.instance;
    final FlutterLocalNotificationsPlugin localPlugin=FlutterLocalNotificationsPlugin();
    Future <void> baslat( { 
        required Function(RemoteMessage message) onMesajGeldi,
    })async{
        await _fcm.requestPermission( alert:true,badge:true, sound:true);
        const androidSettings=AndroidInitializationSettings("@mipmap/ic_launcher");
        const iosSettings=DarwinInitializationSettings();
        const initSettings=InitializationSettings( 
            android:androidSettings,
            iOS:iosSettings,
        );
        await _localPlugin.initialize(initSettings);
        FirebaseMessaging.onMessage.listen((message){
            _yerelBildirimGoster(message);
            onMesajGeldi(message);
        });
        FirebaseMessaging.onBackgroundMessage(fcmBackgroundHandler);
    }
    Future<void> konuyaAboneOl(String konu) async{
        await _fcm.subscribeToTopic(konu);
    }
    Future<void> konudanAyril(String konu) async{
        await _fcm.unsubscribeFromTopic(konu);
    }
    Future<void> _yerelBildirimGoster(RemoteMessage message) async{
        const androidDetails=AndroidNotificationDetails( 
            'softito_fcm_channel_id',
            "Softito Bildirimleri",
            channelDescription: "FCM Push bildirimi",
            importance:Importance.max,
            priority:Priority.high,
        );
        const details=NotificationDetails( 
            android:androidDetails,
            iOS:DarwinNotificationDetails(),
        );
        await _localPlugin.show(
            message.hashCode,
            message.notification?.title ?? "Yeni Bildirim",
            message.notification?.body ?? '',
            details,
        );
    }
}