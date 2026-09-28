
  //print("Dart SDK aktif olmalı");
  /*int seansSuresiDakika = 45;
  double ucret = 2750.50;
  String doktor = "Ali Turk";
  bool aktifmi = true;
  print("Uzman:$doktor |Süre:$seansSuresiDakika dakika |Ücret:$ucret ₺");
  print("KDV dahil(%20) ${ucret * 1.20} ₺");
  /*var deneme="Eren";
    eren=42;*/
  /*dynamic serbest="Lazer" veri tipi güvenliğini yok eder;
    serbest=42;*/
  const String klinikAdi = "SoftIto Güzellik Merkezi";
  const double kdvOrani = 0.20;
  /*const DateTime suan=DateTime.now(); hata verir*/
  final DateTime randevu = DateTime.now();
  final String takipKodu = "SOFT-" + randevu.microsecondsSinceEpoch.toString();
  print("Klinik ad:$klinikAdi");
  print("oluşturlma tarihi:$randevu kod:$takipKodu");
  String? danisanAlerjiNotu = null;
  String goruntulenecekNot = danisanAlerjiNotu ?? "Bilinen bir alerjisi yok";
  print(goruntulenecekNot);
  // null aware
  print("alerji metin uzunluğu${danisanAlerjiNotu?.length}");
  double topla(double a,double b)=>a+b;*/
  void seansKaydiOlustur({
    required String danisan,
    required String tedavi,
    required double birimFiyat,
    int seansSayisi=1,
    double indirimOrani=0.0,
    String? uzmanHekim,
    
  }){
    final double brutTutar=birimFiyat*(indirimOrani/100);
    final double netTutar=birimFiyat-brutTutar;
     print("""

      =============================

      Softİto Seans Sözleşmesi

      ------------------------

      Danışan         :$danisan
      Tedavi          :$tedavi (x$seansSayisi Seans)
      Uzman Hekim     :${uzmanHekim ?? "Nöbetçi Estetisyen"}
      Brüt Tutar      :$brutTutar ₺
      İndirim         :  -$brutTutar ₺ ($indirimOrani)
      Ödenecek Tutar  :$netTutar ₺


      ==================================
""");
}
void main() {
 seansKaydiOlustur(danisan:"Eren",tedavi:"tedavi",birimFiyat:500.0,seansSayisi:1,indirimOrani:0.0,uzmanHekim:"uzmanHekim");
}
    