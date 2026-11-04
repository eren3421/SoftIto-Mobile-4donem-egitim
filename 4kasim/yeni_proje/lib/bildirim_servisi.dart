import 'package:firebase_messaging/firebase_messaging.dart';
 @pragma('vm:entry-point') // her şeyden bağımsız olarak arka planda çalışmasını sağlar
 Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async{
    print("Arka planda bildirim geldi ${message.notifications?.title}");
 }
class BildirimServisi{
    final FirebaseMessaging _fcm=FirebaseMessaging.instance;
    Future<void> baslat() async{
        NotificationSettings settings = await _fcm.requestPermission( 
            alert:true,
            badge:true,
            sound:true,
        );
        if(settings.authorizationStatus==AuthorizationStatus.authorized){
            print("Kullanıcı bildirim iznini verdi");
        }
        final token= await _fcm.getToken();
        print("Cihazın FCM tokenı: $token");
    }
}