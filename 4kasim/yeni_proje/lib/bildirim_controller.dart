import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
class YerelBildirimYoneticisi{
    static final flutterLocalNotificationsPlugin _yerelBildirim = FlutterLocalNotificationsPlugin();
    static Future<void> kurulum() async{
        const androidAyarlari=AndroidInitializationSettings('@mipmap/ic_launcer');
        const iosAyarlari=DarwinInitializationSettings();
        const ayarlar=InitializationSettings(android:androidAyarlari,iOS:iosAyarlari);
        await _yerelBildirim.initalize(settings:ayarlar);
    }
    static Future<void> bildirimGoster(RemoteMessage message)async{
        const androidDetay=AndroidNotificationDetails('softito_kanal_id','Softito Bildirimleri',importance:Importance.max,priority:Priority.high,playSound:true);
    }
    const detaylar=NotificationDetails(android:androidDetay);
    await _yerekBildirim.show( 
        id:message.hashCode,
        title:message.notification?.title ?? 'Yeni Bildirim',
        body:message.notification?.body ?? '',
        notifications:
        dataylar,
    )
}