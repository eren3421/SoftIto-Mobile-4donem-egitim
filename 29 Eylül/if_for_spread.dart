// Dart dilinde listeler oluştururken kodumuzu daha kısa ve dinamik 
// yazmamızı sağlayan Spread (...), Null-aware Spread (...?) 
// Collection If ve Collection For özelliklerinin kullanımı:

void main(){
  // Konsola bilgi mesajı yazdırıyoruz
  print("Pipeline konfigürasyonu");

  // Liste içerisinde kullanılacak kontrol değişkenlerimizi (bayrakları) tanımlıyoruz.
  final bool productionMu = true; // Canlı ortamda mıyız? Evet.
  final bool debugLoginAktif = false; // Hata ayıklama logları açık mı? Hayır.
  
  // Eklenecek ekstra listeler tanımlanıyor. 
  // 'List<String>?' diyerek bu listelerin 'null' olabileceğini belirtiyoruz.
  final List<String>? cloudWatchEklentileri = ["datadog-agent:v7", "prometheus-exporter"];
  final List<String>? geciciTestYamalari = null; // Bu liste şu an boş (null).

  // Ana listemizi oluşturuyoruz.
  final List<String> aktifPiplineAdimlari = [
    // Standart (her zaman eklenecek) liste elemanları:
    "git-checkout",
    "security-sast-scan",
    
    // 1. COLLECTION IF KULLANIMI:
    // Sadece 'productionMu' true ise bu string listeye eklenir.
    if(productionMu) "production-kms-check",
    
    // 2. COLLECTION IF-ELSE KULLANIMI:
    // 'debugLoginAktif' false olduğu için 'else' kısmı çalışır ve listeye 
    // "minified-json-logger" eklenir.
    if(debugLoginAktif) "verbose-debug-logger" else "minified-json-logger",
    
    // 3. SPREAD OPERATÖRÜ (...) KULLANIMI:
    // Bu operatör, yandaki listenin içindeki elemanları tek tek dışarı çıkartıp 
    // ana listeye (aktifPiplineAdimlari) ekler. (Liste içinde liste olmasını önler)
    ...["docker-build", "helm-chart-package"],
    
    // 4. NULL-AWARE SPREAD OPERATÖRÜ (...?) KULLANIMI:
    // Normal '...' kullansaydık ve liste null olsaydı kod çökerdi.
    // '...?' liste doluysa elemanları ekler, liste 'null' ise hiçbir şey yapmaz, güvenle geçer.
    ...?cloudWatchEklentileri, // Dolu olduğu için içindeki 2 elemanı ekler.
    ...?geciciTestYamalari,     // Null olduğu için hata vermez, sessizce atlar.
  ];

  // Oluşturduğumuz dinamik listeyi ekrana yazdırmak için klasik for döngüsü kullanıyoruz.
  for(int i = 0; i < aktifPiplineAdimlari.length; i++){
    print("Adım ${i+1}: ${aktifPiplineAdimlari[i]}");
  }

  // Elimizde izin verilen portların bulunduğu bir sayı listesi var.
  final List<int> izinliPortlar = [8080, 8446, 9090];
  
  // Güvenlik kuralları listesini oluşturuyoruz.
  final List<String> firewallGuvenlikKurallari = [
    "INGRESS-DEFAULT-DROP", // Standart eleman
    
    // 5. COLLECTION FOR KULLANIMI:
    // izinliPortlar listesi içindeki her bir eleman için döngü çalışır
    // ve listeye 3 defa "Allow-TCP_PORT-Sport (VPC-INTERNAL)" metnini ekler.
    // Not: Buradaki port değerini metne yansıtmak istersen string interpolation yapabilirsin:
    // for(var port in izinliPortlar) "Allow-TCP_$port (VPC-INTERNAL)", 
    for(var port in izinliPortlar) "Allow-TCP_PORT-Sport (VPC-INTERNAL)", 
    
    "EGRESS_ALL_ALLOW", // Standart eleman
  ];
  
  print("\nDinamik güvenlik kuralları (collection for): ------");
  // forEach metodu ile listedeki her bir kuralı konsola yazdırıyoruz.
  firewallGuvenlikKurallari.forEach((kural) => print(" * $kural"));
}