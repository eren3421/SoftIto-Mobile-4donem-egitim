import 'package:firebase_remote_config/firebase_remote_config.dart';
class RemoteConfigServisi{
    final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
    Future<void> baslat(){
        await _firebaseRemoteConfig.setConfigSettings( 
            RemoteConfigSettings( 
                fetchTimeout: const Duration(seconds:10),
                minimumFetchInterval:Duration.zero,
            ),
        );
        await _firebaseRemoteConfig.setDefaults({ 
            'kampanya_aktif':true,
            'kampanya_metni':'Mobil Mezuniyet İndirimi',
            'kampanya_indirim_orani':30,
            'zorunlu_guncelleme':false,
            'en_dusuk_surum':'1.0.0',
        });
        try{
            await _firebaseRemoteConfig.fetchAndActivate();
        }catch(e){}
    }
    bool get kampanyaAktifMi=firebaseRemoteConfig.getBool('kampanya_aktif');
    String get kampanyaMesaji=_firebaseRemoteConfig.getString('kampanya_metni');
    int get indirimOrani=_remoteConfig.getInt('kampanya_indirim_orani');
    bool get zorunluGuncelleme=_firebaseRemoteConfig.getBool('zorunlu_guncelleme');
    String get enDusukSurum=_remoteConfig.getString('en_dusuk_surum');
    
}