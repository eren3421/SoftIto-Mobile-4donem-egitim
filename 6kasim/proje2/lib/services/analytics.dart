import 'package:firebase_analytics/firebase_analytics.dart';
class AnalyticsServisi{
    final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
    Future<void> ekranGoruntulendi(String ekranAdi)async{
        await _analytics.logScreenView(screenName: ekranAdi);
    }
    Future<void> olayGonder({
        required String olayAdi,
        Map<String,Object>? parametreler,
    })async{
        await _analytics.logEvent(name:olayAdi,parameters:parametreler);
    }
    Future<void> kullaniciOzelligiBelirtir({
        required String anahtar,
        required String deger,

    })async{
        await _analytics.setUserProperty(name:anahtar,value:deger);
    }
}