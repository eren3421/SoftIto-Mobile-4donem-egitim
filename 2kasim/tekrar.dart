// sınıflar dışındand extend edilmez switch içinde tüm alt sınıflat tüketilmeli
sealed class OdemeDurumu{}
class OdemeBasarili extends OdemeDurumu{
    final ({String referansKodu, double tutar}) veri;
    OdemeBasarili(this.veri);
}
class OdemeBasarisiz extends OdemeDurumu{
    String hataNedeni;
    OdemeBasarisiz(this.hataNedeni);
}
abstract class IBankaServisi{
    Future<OdemeDurumu>  odeme({required double miktar});
}
mixin GuvenlikDenetimiMixin{
    bool tokenGecerliMi(String token){
        return token.isNotEmpty && token.length>=32;
    }
}
mixin AuditLoginMixin{
    void islemKaydet(String mesaj){
        final zaman=DateTime.now().toIso8601String();
        print('Login: $zaman $mesaj');
    }
}
class GarantiBankasiServisi with GuvenlikDenetimiMixin, AuditLoginMixin implements IBankaServisi{
    final String apiAnahtari;
    GarantiBankasiServisi({required this.apiAnahtari});
    @override
    Future<OdemeDurumu> odeme({required double miktar}) async{
        if(!tokenGecerliMi(apiAnahtari)){
            islemKaydet("Ödeme reddedildi. Geçersiz anahtar");
            return OdemeBasarisiz("Yetkilendirme Hatası");
        }
        await Future.delayed(const Duration(milliseconds:1000));
        islemKaydet("Miktar tutarındaki ödeme garanti bankası tarafından onaylandı");
        return OdemeBasarili((referansKodu:'GRNT-${DateTime.now().millisecondsSinceEpoch}',tutar:miktar));
    }
}
void odemeSonucunuEkranaBas(OdemeDurumu durum){
    final mesaj=switch(durum){
        OdemeBasarili b=> 'Ödeme başarılı Ref: ${b.veri.referansKodu}, Tutar: ${b.veri.tutar}',
        OdemeBasarisiz h=> 'Ödeme Başarısız Gerekçe: ${h.hataNedeni}',
    };
    print(mesaj);
}
void main() async{
    double tutar=3000;
    GarantiBankasiServisi garantiBankasiServisi=new GarantiBankasiServisi(apiAnahtari: "sdffdsfdsfsfdsfsdfdsfsdsfdfdssdf");
    final sonuc= await garantiBankasiServisi.odeme(miktar: tutar);
    odemeSonucunuEkranaBas(sonuc);

}