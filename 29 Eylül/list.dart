void main() {
  final List<String> aktifMiroservisler = [
    "auth-service:v2.1",
    "gateway-service:v1.9",
    "payment-processor:v3.0",
  ];
  aktifMiroservisler.add("telemetry-collector:v1.0");
  print(
    "Aktif servisler: (${aktifMiroservisler.length} adet): $aktifMiroservisler",
  );

  //sabit uzunluktaki liste(fixed-length)
  final List<String> cekirdekYukDengeleyiciler = List.filled(
    4,
    "Port-Kapalı",
    growable: false,
  );
  cekirdekYukDengeleyiciler[0] = "LB-NODE-01; 192.168.1.11(Online)";
  cekirdekYukDengeleyiciler[1] = "LB-NODE-02; 192.168.1.10(Online)";
  //cekirdekYukDengeleyiciler.add("LB-NODE-05");
 //hata:fixed-length listeye eleman eklemnemez
  print("Çekirdek yük dengeleyici portları: $cekirdekYukDengeleyiciler");


  //Programatik list üretici
  final List<String> kupernetsPodlari=List.generate(3, (index)=>"pod-node-eu-west-${index+1} [Ram:16GB, CPU:4 Cores]",);
  print("Oluşturulan K8s Podları: $kupernetsPodlari");

  //değiştirilemez List
  final List<String> guvenlikDuvarlariPortlari=List.unmodifiable({
    "22/TCP (SSH)",
    "443/TCP (HTTPS)",
    "644/TCP (K8s-API)",
  });
  //guvenlikDuvarlariPortlari[0]="80/TCP"; //Hata cannot modift an unmodifiable list
  print("Güvenlik duvarı korumalı portları: $guvenlikDuvarlariPortlari");


  
}
