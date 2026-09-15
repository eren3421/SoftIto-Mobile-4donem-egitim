class Urun {
  String id;
  String ad;
  double fiyat;
  int stok;
  String tip;

  Urun(this.id, this.ad, this.fiyat, this.stok, this.tip);
}
class DijitalOlmayanUrun extends Urun {
  DijitalOlmayanUrun(String id, String ad, double fiyat, int stok): super(id, ad, fiyat, stok, "DIJITALOLMAYAN");
  double kargoUcretiHesapla() {
    return 29.90;  }
}
abstract class IDatabase{
    void kaydet(String sql);
}
class SqliteVeritabani implements IDatabase {
  @override
  void kaydet(String sql) {
    print("DB calistirildi: " + sql);
  }
}
abstract class IMailService{
    void mailAt(String to, String body);
}
class SMTPService implements IMailService{
    @override
    void mailAt(String to, String body){
  	print("SMTP Mail gonderildi: " + to);
    }
}
abstract class ISmsService{
     void smsYolla(String gsm, String text);
}
class NetgsmSmsService implements ISmsService{
    @override
    void smsYolla(String gsm, String text){
  	print("SMS iletildi: " + gsm);
    }
}
abstract class IKargoServisi {
  void kargoGonder(String orderId, String adres);
}
class MNGKargo implements IKargoServisi{
    @override
    void kargoGonder(String orderId, String adres){
	print("MNG Kargo takip fis basildi: $adres");
    }
}
abstract class IFaturaServisi {
  void faturaKes(String orderId);
}
class PDFFatura implements IFaturaServisi{
    @override
    void faturaKes(String orderId){
	print("Fatura PDF cikarildi: $orderId");
    }
}
abstract class IOdemeYontemi {
  void odemeYap(double tutar);
}

class KrediKartiOdeme implements IOdemeYontemi {
  @override
  void odemeYap(double tutar) => print("$tutar TL Kredi kartından çekildi.");
}

class HavaleOdeme implements IOdemeYontemi {
  @override
  void odemeYap(double tutar) => print("$tutar TL Havale ile ödendi.");
}
abstract class IIndirimKampanyasi {
  double indirimUygula(double tutar);
}
class YuzdeOnIndirim implements IIndirimKampanyasi {
  @override
  double indirimUygula(double tutar) => tutar * 0.90;
}
class Kampanyasiz implements IIndirimKampanyasi {
  @override
  double indirimUygula(double tutar) => tutar;
}
class SiparisYoneticisi {
  IDatabase _db;
  IMailService _mailServisi;
  ISmsService _smsServisi;
  IKargoServisi _kargoServisi;
  IFaturaServisi _faturaServisi;
  SiparisYoneticisi(
    this._db,
    this._mailServisi,
    this._smsServisi,
    this._kargoServisi,
    this._faturaServisi,
  );
  void siparisTamamla({
    required String orderId,
    required List<Urun> sepet,
    required IOdemeYontemi odemeYontemi,
    required IIndirimKampanyasi kampanya,
    required String musteriAdi,
    required String email,
    required String tel,
    required String adres,
  }) {
    double araToplam = 0;
    double kargoToplami = 0;
    bool kargoGerekli = false;

    // 1. Stok Düşme ve Ara Toplam
    for (var urun in sepet) {
      if (urun.stok <= 0) {
        print("Hata: ${urun.ad} tukenmis!");
        return;
      }
      araToplam += urun.fiyat;
      urun.stok--;

      // Kargo hesaplama yeteneği olan ürünleri kontrol et
      if (urun is DijitalOlmayanUrun) {
        kargoGerekli = true;
        kargoToplami += urun.kargoUcretiHesapla();
      }
    }
    double indirimliTutar = kampanya.indirimUygula(araToplam);
    double kdv = indirimliTutar * 0.20;
    double sonTutar = indirimliTutar + kdv + kargoToplami;
    odemeYontemi.odemeYap(sonTutar);
    _db.kaydet("INSERT INTO siparisler VALUES ('$orderId', $sonTutar)");
    _faturaServisi.faturaKes(orderId);
    _mailServisi.mailAt(email, "Sayin $musteriAdi, siparisiniz alindi. Tutar: $sonTutar TL");
    _smsServisi.smsYolla(tel, "Siparisiniz onaylandi: $orderId");
    if (kargoGerekli) {
      _kargoServisi.kargoGonder(orderId, adres);
    }
  }
}
void main() {
  var db = SqliteVeritabani();
  var mailci = SMTPService();
  var smsci = NetgsmSmsService();
  var kargocu = MNGKargo();
  var faturaci = PDFFatura();
  var siparisci = SiparisYoneticisi(db, mailci, smsci, kargocu, faturaci);
  var urun1 = DijitalOlmayanUrun("1", "Kablosuz Mouse", 450.0, 5);
  var urun2 = Urun("2", "Flutter Kursu E-Kitap", 150.0, 100,"Dijital");
  var sepet = <Urun>[urun1, urun2];
  siparisci.siparisTamamla(
    orderId: "SP-9921",
    sepet: sepet,
    odemeYontemi: KrediKartiOdeme(),       
    kampanya: YuzdeOnIndirim(),      
    musteriAdi: "Selahaddin",
    email: "selahaddin@kodvance.com",
    tel: "05551112233",
    adres: "Kadikoy / Istanbul",
  );
}
/*
HATA AÇIKLAMALARI
Ürün sınıfının kargo ücreti hesapla metodu olup Ürün sınıfından türetilen Dijital Ürün sınıfının kargo ücreti hesaplayamayıp üst sınıfın metodunu bozduğu için  LSP yi (Liskov Substution Principle) ihlal ediyor. Sipariş tamamlama fonksiyonunda kargo ücreti hesaplama fonksiyonunda dijital ürünlerin kargo ücretini hesaplayamayacağı için hata verecektir.
Sipariş Yöneticisi sınıfının çok fazla görevi var bir nevi god class pozisyonunda ödeme, veritabanı, doğrulama gibi birbirinden bağımsız işlemlerin hepsine bakıyor. Ayrıca sipariş tamamla fonksiyonu hem stok kontrolü hem de fiyat hesaplıyor bu iki durum SRP yi (Single Responsiblity Principle) inkar ediyor.
ISpiraisIslemleri arayüzü birbirinden bağımsız çok fazla metodu içinde tutuyor ve bir sınıf bu arayüzü implement etmeye kalktığında tüm fonksiyonları yazması gerekecek bu da ISP yi (Interface Segregation Principle) ihlal ediyor.
Ödeme Yöntemleri ve İndirim hesaplamada tüm farklı yöntemler için if else blokları açılmış bu da yeni bir tür yöntem eklendiğinde önceki kodun değişmesine sebep olcak ve OCP yi(Open Closed Principle) ihlal ediyor.
Sipariş kaydetme fonksiyonu Sqlite a mail gönderme SMTP mail servisine ve SMS gönderme Netgsmservice a bağlı olduğu için yani bu metodlar belli teknolojilere sıkı bağımlı olduğu için yarın veri tabanı mail servisi veya sms gönderme teknolojisi değiştiğinde kod patlar buda DIP(Dependency Inversion Principle) ihlal eder.
*/
