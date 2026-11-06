import 'package:firebase_remote_config/firebase_remote_config.dart';
class RemoteConfigServisi{
    final FirebaseRemoteConfig _rc=FirebaseRemoteConfig.instance;
    Future <void> baslat() async{
        await _rc.setConfigSettings(RemoteConfigSettings(
            fetchTimeout:const Duration(seconds:10),
            minimumFetchInterval:Duration.zero,
        ),
            
        );
    }
    await _rc.setDefaults(const{
        'kampanya_aktif':false,
        "kampanya_metni":"1 alana 100 bedava",
        'zorunlu_surum':'1.0.1',
    });
    await _rc.fetchAndActivate();
    bool get kampanyaAktifMi=> _rc.getBool("kampanya_aktif");
    String get kampanyaMetni => _rc.getString("kampanya_metni");
    String get zorunluSurum => _rc.getString("zorunlu_surum");
}