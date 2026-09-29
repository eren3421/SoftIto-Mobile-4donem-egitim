// 1. DÜZELTME: Eksik olan Exception sınıfı eklendi
class CihazErisilemezException implements Exception {
  final String mesaj;

  CihazErisilemezException(this.mesaj);

  @override
  String toString() => mesaj;
}

enum CihazTipi { sensor, gateway, edgeServer, router }

class IoTCihaz {
  final String seriNo;
  final String cihazAdi;
  final CihazTipi tip;
  final double cpuYukYuzdesi;
  final int bellekMb;
  final Set acikPortlar;
  final bool sslSertifikasiGecerliMi;
  final bool cihazAcikMi;

  IoTCihaz({
    required this.seriNo,
    required this.cihazAdi,
    required this.tip,
    required this.cpuYukYuzdesi,
    required this.bellekMb,
    this.acikPortlar = const {},
    required this.sslSertifikasiGecerliMi,
    this.cihazAcikMi = true,
  });

  bool get guvenlikAcigiVarmi =>
      (!sslSertifikasiGecerliMi || acikPortlar.contains("23/TELNET"));

  String get izolasyonBolgesi => switch (tip) {
        CihazTipi.sensor => "ZONE-S",
        CihazTipi.gateway => "ZONE-G",
        CihazTipi.edgeServer => "ZONE-E",
        CihazTipi.router => "ZONE-R",
      };
}
(String cihazAdi, CihazTipi tip, bool alarmDurumu)? cihazBilgisiGetir(
    String arananSeriNo, List<IoTCihaz> cihazListesi) {
  int index = cihazListesi.indexWhere((c) => c.seriNo == arananSeriNo);
  if (index == -1) {
    return null;
  }
  IoTCihaz cihaz = cihazListesi[index];
  if (!cihaz.cihazAcikMi) {
    throw CihazErisilemezException(
      "Erişim Hatası: '\(arananSeriNo' seri numaralı '\){cihaz.cihazAdi}' cihazı kapalı durumda olduğu için sorgulanamıyor!",
    );
  }
  bool alarm = cihaz.guvenlikAcigiVarmi || cihaz.cpuYukYuzdesi > 85;
  return (cihaz.cihazAdi, cihaz.tip, alarm);
}

void main() {
  List <IoTCihaz> _cihazlar = [];

  final cihaz1 = IoTCihaz(
    seriNo: "SN-1001",
    cihazAdi: "Akıllı Termostat Sensörü",
    tip: CihazTipi.sensor,
    cpuYukYuzdesi: 12.5,
    bellekMb: 32,
    acikPortlar: {},
    sslSertifikasiGecerliMi: true,
  );
  _cihazlar.add(cihaz1);

  final cihaz2 = IoTCihaz(
    seriNo: "GW-2048",
    cihazAdi: "Ana Fabrika Gateway",
    tip: CihazTipi.gateway,
    cpuYukYuzdesi: 45.0,
    bellekMb: 1024,
    acikPortlar: {"443/HTTPS", "22/SSH"},
    sslSertifikasiGecerliMi: true,
  );
  _cihazlar.add(cihaz2);

  final cihaz3 = IoTCihaz(
    seriNo: "ES-9900",
    cihazAdi: "Veri İşleme Edge Sunucusu",
    tip: CihazTipi.edgeServer,
    cpuYukYuzdesi: 88.5,
    bellekMb: 8192,
    acikPortlar: {"443/HTTPS", "8080/HTTP", "5432/POSTGRESQL"},
    sslSertifikasiGecerliMi: true,
  );
  _cihazlar.add(cihaz3);

  final cihaz4 = IoTCihaz(
    seriNo: "RT-0042",
    cihazAdi: "Eski Depo Router",
    tip: CihazTipi.router,
    cpuYukYuzdesi: 60.2,
    bellekMb: 512,
    acikPortlar: {"23/TELNET", "80/HTTP"},
    sslSertifikasiGecerliMi: false,
    cihazAcikMi: false, 
  );
  _cihazlar.add(cihaz4);

  final cihaz5 = IoTCihaz(
    seriNo: "SN-1002",
    cihazAdi: "Basınç Sensörü",
    tip: CihazTipi.sensor,
    cpuYukYuzdesi: 5.0,
    bellekMb: 16,
    acikPortlar: {"80/HTTP"},
    sslSertifikasiGecerliMi: false,
  );
  _cihazlar.add(cihaz5);

  final cihaz6 = IoTCihaz(
    seriNo: "GW-2049",
    cihazAdi: "Yedek Gateway",
    tip: CihazTipi.gateway,
    cpuYukYuzdesi: 75.3,
    bellekMb: 2048,
    acikPortlar: {"443/HTTPS", "23/TELNET"},
    sslSertifikasiGecerliMi: true,
  );
  _cihazlar.add(cihaz6);

  final _riskliCihazlar = _cihazlar
      .where((c) => c.guvenlikAcigiVarmi == true || c.cpuYukYuzdesi > 85);
  
  print("--- RİSKLİ CİHAZLAR ---");
  for (var c in _riskliCihazlar) {
    print("- ${c.cihazAdi} (Seri No: ${c.seriNo})");
  }

  int toplamBellekKullanimi =_cihazlar.fold(0, (toplam, c) => toplam + c.bellekMb);
  print("\nToplam Bellek Kullanımı: $toplamBellekKullanimi MB\n");
  print("--- CİHAZ SORGULAMA TESTLERİ ---");
  void cihazSorgula(String arananSeriNo) {
    try {
      var sonuc = cihazBilgisiGetir(arananSeriNo, _cihazlar);
      if (sonuc != null) {
        String zone =
            _cihazlar.firstWhere((c) => c.seriNo == arananSeriNo).izolasyonBolgesi;
        print(
            "[BAŞARILI] Cihaz: ${sonuc.$1} | Tip: ${sonuc.$2.name} | Bölge: $zone | Alarm: ${sonuc.$3}");
      } else {
        print("[BULUNAMADI] '$arananSeriNo' seri numaralı cihaz sistemde kayıtlı değil.");
      }
    } on CihazErisilemezException catch (e) {
      print("[ÖZEL HATA YAKALANDI] $e");
    } catch (e) {
      print("[GENEL HATA] Beklenmeyen bir sorun oluştu: $e");
    }
  }
  cihazSorgula("ES-9900");
  cihazSorgula("RT-0042");
  cihazSorgula("KAYITSIZ-99");
}