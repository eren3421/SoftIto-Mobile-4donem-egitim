class SunucuMetrigi {
  final String hostAdi;
  final String bolge;
  final double cpuYuzdesi;
  final double ramGb;
  final int aktifbaglantiSayisi;
  final bool kritikMi;

  const SunucuMetrigi({
    required this.hostAdi,
    required this.bolge,
    required this.cpuYuzdesi,
    required this.ramGb,
    required this.aktifbaglantiSayisi,
    this.kritikMi = false,
  });

  @override
  String toString() =>
      "$hostAdi [$bolge] (CPU: %$cpuYuzdesi, Ram: ${ramGb} GB, Conn: $aktifbaglantiSayisi)";
}

void main() {
  print("Cloud Temelleri");

  final List<SunucuMetrigi> sunucuKumesi = [
    SunucuMetrigi(
      hostAdi: "srv-eu-02",
      bolge: "eu-west",
      cpuYuzdesi: 88.5,
      ramGb: 32.0,
      aktifbaglantiSayisi: 4500,
      kritikMi: true,
    ),
    SunucuMetrigi(
      hostAdi: "srv-us-01",
      bolge: "us-east",
      cpuYuzdesi: 22.0,
      ramGb: 8.0,
      aktifbaglantiSayisi: 450,
      kritikMi: false,
    ),
    SunucuMetrigi(
      hostAdi: "srv-us-02",
      bolge: "us-east",
      cpuYuzdesi: 94.6,
      ramGb: 64.0,
      aktifbaglantiSayisi: 8900,
      kritikMi: true,
    ),
    SunucuMetrigi(
      hostAdi: "srv-ap-01",
      bolge: "ap-south",
      cpuYuzdesi: 62.4,
      ramGb: 16.0,
      aktifbaglantiSayisi: 2000,
      kritikMi: false,
    ),
  ];

  // where() ile filtreleme: CPU kullanımı %80 üzerine olan sunucular
  final asiriYukluSunucular = sunucuKumesi
      .where((s) => s.cpuYuzdesi >= 80.0)
      .toList();
  print("Aşırı yüklü sunucular (${asiriYukluSunucular.length})");
  asiriYukluSunucular.forEach((s) => print("* $s"));

  //map() ile dönüştürme. sunucu adları ve bağlantı sayılarını alarm etiketine çevirme

  final List<String> alarmEtiketleri = sunucuKumesi
      .map(
        (s) =>
            "[Alert-Monitor] ${s.hostAdi.toLowerCase()} ->Aktif Trafik ${s.aktifbaglantiSayisi}",
      )
      .toList();
  print("Alarm Çıktıları (ilk 3 tane)");
  alarmEtiketleri.take(3).forEach((e) => print(" $e"));

  // fold() ile toplam aktif trafik gösterimi
  final int toplamBaglantiSayisi = sunucuKumesi.fold(
    0,
    (toplam, sunucu) => toplam + sunucu.aktifbaglantiSayisi,
  );
  print("Toplam Bağlantı: $toplamBaglantiSayisi");

  // every() ve any()
  final bool tumSunucularCalisiyormu = sunucuKumesi.every(
    (s) => s.ramGb >= 8.0,
  );
  final bool tehlikeliSunucuVarMi = sunucuKumesi.any(
    (s) => s.cpuYuzdesi >= 90.0,
  );

  print(
    "Tüm sunucuların Ram'i en az 8 gb mı? : ${tumSunucularCalisiyormu ? 'Evet' : 'Hayır'}",
  );
  print(
    "Cpu kullanımı %90'ı aşan var mı? : ${tehlikeliSunucuVarMi ? 'Evet' : 'Hayır'}",
  );

  final euWestSunuculari = sunucuKumesi
      .where((s) => s.bolge == "eu-west" && s.kritikMi)
      .toList();
  final double euWestOrtalamaCpu =
      euWestSunuculari
          .map((s) => s.cpuYuzdesi)
          .fold(0.0, (acc, cpu) => acc + cpu) /
      euWestSunuculari.length;
  print(
    "Eu West bölgesi Kritik sunucu ortama Cpu: ${euWestOrtalamaCpu.toStringAsFixed(2)}",
  );
  
}
