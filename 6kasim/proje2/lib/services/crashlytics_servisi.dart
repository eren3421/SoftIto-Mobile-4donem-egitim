import 'package:firebase_crashlytics.dart';
class CrashlyticsServisi{
    final FirebasCrashlytics _crashlytics=FirebasCrashlytics.instance;
    Future<void> kullaniciTanitimi({ 
        required String uid,
        required String rol,
    }) async( 
        await _crashlytics.setUserIdentifier(uid),
        await _crashlytics.setUserProperty('rol',rol);
        await _crashlytics.setCustomKey('platform','flutter');
    )
    void logEkle(String mesaj){
        _crashlytics.log(mesaj);
    }
    Future<void> sessizHataKaydet(dynamic hata,StackTrace stack)async{
        await _crashlytics.recordError(hata,stack,fatal:false);
    }
    void kastenCokertme(){
        _crashlytics.crash();
    }
}