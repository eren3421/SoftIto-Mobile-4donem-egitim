enum HizmetKategorisi { ciltYenileme, medikalEstetik, lazerEpilasyon, Lipo } /* Hizmet türlerini arka plande 0 1 2 gibi her yeni değerde sayısı 1 artan 
sayısal değerlerle okunabilir şekilde tutmak için HzimetKategorisi adında bu değer kümesini tutan bir enum oluşturduk*/


enum SeansDurumu { bekliyor, odadaIslemde, tamamlandi, iptalEdildi } /* seans türlerini arka plande 0 1 2 gibi her yeni değerde sayısı 1 artan 
sayısal değerlerle okunabilir şekilde tutmak için SeansDurumu adında bu değer kümesini tutan bir enum oluşturduk*/


enum OdemeYontemi { krediKarti, havaleEft, nakit, klinikPaketKredisi } /* ödeme türlerini arka plande 0 1 2 gibi her yeni değerde sayısı 1 artan 
sayısal değerlerle okunabilir şekilde tutmak için OdemeYontemi adında bu değer kümesini tutan bir enum oluşturduk*/

//Danışan (müşteri) Modeli
class Danisan { // Danışan sınıfı danışan türünde nesne oluşturmak için kullanılır
  final String id;// çalışma esnasında sadece bir kez değer alabilmesi için başına final eklenen string veri türünde benzersiz kullanıcı numarası
  final String adSoyad; // çalışma esnasında sadece bir kez değer alabilmesi için başına final eklenen string veri türünde kullanıcı ad soyad
  final String telefon; // çalışma esnasında sadece bir kez değer alabilmesi için başına final eklenen string veri türünde telefon numarası
  final bool vipUyeMi; // çalışma esnasında sadece bir kez değer alabilmesi için başına final eklenen bool veri türünde vip uye olup olmadığına bakan kontrol değişkeni
  final List<String> alerjiler; // boş olabilir ama null olamaz // çalışma esnasında sadece bir kez değer alabilmesi için başına final eklenen string türündeki değişkenlerin listesini tutan alerjiler listesi ama final olması listeye eleman eklenmesine engel olmaz sadece heap tarafındaki referans adresinin değişmesini engeller.
  final String? ozelCiltNotu; // Opsiyonel Null olabilir // çalışma esnasında sadece bir kez değer alabilmesi için basına final eklenen string türünde hastalık notu

  const Danisan({ // Danisan sınıfı için constructor oluşturduk
    required this.id,//required türü alanın zorunlu olduğunu gösterir yukarıdaki id ye değer alır
    required this.adSoyad, //required türü alanın zorunlu olduğunu gösterir yukarıdaki adSoyada ya değer alır
    required this.telefon, // required türü alanın zorunlu olduğunu gösterir yukarıdaki telefona değer alır
    this.vipUyeMi = false,// required türü alanın zorunlu olduğunu gösterir yukarıdaki vipUyeMi ye değer alır
    this.alerjiler = const [],// required türü alanın zorunlu olduğunu gösterir yukarıdaki listeye  değer alır
    this.ozelCiltNotu,// required türü alanın zorunlu olduğunu gösterir yukarıdaki ozelCiltNotu alanına değer alır
  });

  bool get hassasCiltMi => alerjiler.isNotEmpty; // burda hassasCiltmi adında getter oluşturduk alerjiler listesinin boş olup olmadığını kontrol ediyoruz arrow fonsksiyonu ile değer döndürülük fakat get burda fonksiyon olarak değil attribute olarak çağrılır

  //Bilgi özet kartı
  String get bilgiOzeti { // burda bilgiOzeti adında getter oluşturduk
    final String alerjiBilgisi = alerjiler.isEmpty // alerji bilgisinin bos olup olmadığını ternary yapısı ile kontrol ediyoruz boşsa Kayıtlı alerji yok varsa alerjiler listesindeki alerjilerin , ile birleştirilmiş string halini alıyoruz
        ? "Kayıtlı Alerji Yok"
        : "Alerjiler: ${alerjiler.join(', ')}";
    final String notBilgisi = ozelCiltNotu ?? "Özel medikal not girilmemiş"; //burda not bilgisini kontrol ediyoruz ozelCiltNotu varsa onun değerini yoksa zel medikal not girilmemiş değerini alıyor

    final String vipRozeti = vipUyeMi ? "VİP" : "Standart"; //burda üye bilgisini kontrol ediyoruz vip is vipRozeti VİP değerini yoksa standart değerini alır
    return "$vipRozeti $adSoyad ($telefon) | $alerjiBilgisi | Not: $notBilgisi"; //sonrasında hepsini birleştirilimiş tek bir string olarak döner.
  }
}

// Seans (randevu) Modeli

class SeansKaydi { //SeansKaydi sınıfı oluşturduk böylece seans kaydi nesneleri olusturulabilir.
  final String seansKodu; // final string olarak seansKodu değişkeni oluşturduk, her seansın benzersiz kodunu tutar
  final Danisan danisan; // final Danisan tipinde danisan nesnesi oluşturduk, bu seansın hangi danışana ait olduğunu tutar
  final HizmetKategorisi kategori; // final HizmetKategorisi tipinde kategori değişkeni oluşturduk, seansın hangi hizmet kategorisine ait olduğunu tutar
  final String islemAdi; // final string olarak islemAdi değişkeni oluşturduk, yapılacak işlemin adını tutar
  final double birimFiyat; // final double olarak birimFiyat değişkeni oluşturduk, bir seansın ücretini ondalıklı olarak tutar
  final int seansSayisi; // final int olarak seansSayisi değişkeni oluşturduk, alınacak veya yapılan seans sayısını tutar
  final double indirimOrani; // final double olarak indirimOrani değişkeni oluşturduk, yüzde olarak uygulanacak indirimi tutar örneğin 10.0 yüzde 10 indirim demektir
  final String? sorumluUzman; // final String? olarak sorumluUzman değişkeni oluşturduk, seansın sorumlu uzmanını tutar ve ? sayesinde null olabilir
  SeansDurumu durum; // SeansDurumu tipinde durum değişkeni oluşturduk, seansın bekliyor, işlemde, tamamlandı veya iptal edildi durumlarından hangisinde olduğunu tutar
  OdemeYontemi? odemeTipi; // OdemeYontemi? tipinde odemeTipi değişkeni oluşturduk, ödeme yöntemini tutar ve ? sayesinde henüz ödeme yapılmadığında null olabilir

  SeansKaydi({ // SeansKaydi sınıfı için constructor oluşturduk
    required this.seansKodu, // required türü alanın zorunlu olduğunu gösterir ve yukarıdaki seansKodu alanına değer alır
    required this.danisan, // required türü alanın zorunlu olduğunu gösterir ve yukarıdaki danisan alanına değer alır
    required this.kategori, // required türü alanın zorunlu olduğunu gösterir ve yukarıdaki kategori alanına değer alır
    required this.islemAdi, // required türü alanın zorunlu olduğunu gösterir ve yukarıdaki islemAdi alanına değer alır
    required this.birimFiyat, // required türü alanın zorunlu olduğunu gösterir ve yukarıdaki birimFiyat alanına değer alır
    this.seansSayisi = 1, // seansSayisi zorunlu değildir, değer verilmezse varsayılan olarak 1 değerini alır
    this.indirimOrani = 0.0, // indirimOrani zorunlu değildir, değer verilmezse varsayılan olarak yüzde 0 indirim uygulanır
    this.sorumluUzman, // sorumluUzman zorunlu değildir, değer verilmezse null olabilir
    this.durum = SeansDurumu.bekliyor, // durum zorunlu değildir, değer verilmezse seansın başlangıç durumu bekliyor olarak atanır
    this.odemeTipi, // odemeTipi zorunlu değildir, değer verilmezse null olarak kalır çünkü ödeme henüz yapılmamış olabilir
  });

  double get brutTutar => birimFiyat * seansSayisi; // brutTutar adında getter oluşturduk, birim fiyatı seans sayısıyla çarparak indirim uygulanmadan önceki toplam tutarı hesaplar

  double get indirimTutari { // indirimTutari adında getter oluşturduk, seans için uygulanacak toplam indirim miktarını hesaplar
    double toplamOran = indirimOrani; // toplamOran değişkenine önce danışana tanımlanan indirim oranını atıyoruz
    if (danisan.vipUyeMi) { // danışanın VIP üye olup olmadığını kontrol ediyoruz
      toplamOran += 10.0; // danışan VIP ise mevcut indirim oranına ek olarak yüzde 10 indirim ekliyoruz
    }
    return brutTutar * (toplamOran / 100.0); // brüt tutarı toplam indirim oranıyla çarpıp 100'e bölerek indirim miktarını hesaplayıp döndürüyoruz
  }

  double get netTutar => brutTutar - indirimTutari; // netTutar adında getter oluşturduk, brüt tutardan indirim tutarını çıkararak ödenecek son tutarı hesaplar
}


// Yönetim Servisi

class KlinikYoneticisi { // KlinikYoneticisi sınıfını oluşturduk, kliniğin danışanlarını ve seanslarını yönetmek için kullanılır
  final String subeAdi; // final String olarak subeAdi değişkeni oluşturduk, yönetilen kliniğin şube adını tutar
  final List<SeansKaydi> _seanslar = []; // final SeansKaydi listesini oluşturduk, oluşturulan tüm seans kayıtlarını tutar; final olması listenin referansının değişmesini engeller ancak listeye eleman eklenebilir
  final Map<String, Danisan> _danisanRehberi = {}; // final Map oluşturduk, danışanları id değerlerini anahtar kullanarak saklar; final olması Map referansının değişmesini engeller ancak içine eleman eklenebilir

  KlinikYoneticisi({required this.subeAdi}); // KlinikYoneticisi için constructor oluşturduk, şube adını zorunlu olarak alır

  //Danışan kaydetme
  void danisanKaydet(Danisan danisan) { // Danışanı kliniğin danışan rehberine kaydetmek için metot oluşturduk
    _danisanRehberi[danisan.id] = danisan; // danışanın id değerini Map'in anahtarı olarak kullanıp danışan nesnesini rehbere ekliyoruz
    print(
      "Rehbere Eklendi: ${danisan.adSoyad} (${danisan.vipUyeMi ? "VİP" : "Standart"})", // ekrana danışanın ad soyad bilgisini ve VIP uye olup olmadığını yazdırıyoruz.
    );
  }

  void randevuOlustur(SeansKaydi seans) { // Yeni bir seans/randevu oluşturmak için metot oluşturduk
    _seanslar.add(seans); // oluşturulan seans nesnesini seanslar listesine ekliyoruz
    print(
      "Randevu Kaydedildi [${seans.seansKodu}]: ${seans.danisan.adSoyad}->${seans.islemAdi}", // ekrana randevunun seans kodunu, danışanın ad soyad bilgisini ve randevu tipini yazdırıyoruz
    );
  }

  void seansiTamamla({required String seansKodu, required OdemeYontemi odeme}) { // Seansı tamamlamak ve ödeme yöntemini kaydetmek için metot oluşturduk
    for (var seans in _seanslar) { // kayıtlı tüm seansların üzerinde dolaşıyoruz
      if (seans.seansKodu == seansKodu) { // listedeki seansın kodunun aranan seans koduyla aynı olup olmadığını kontrol ediyoruz
        seans.durum = SeansDurumu.tamamlandi; // eşleşen seansın durumunu tamamlandı olarak değiştiriyoruz
        seans.odemeTipi = odeme; // eşleşen seansın ödeme yöntemini gönderilen ödeme yöntemiyle güncelliyoruz
        print(
          "Seans Tamamlandı: [${seans.seansKodu}]: ${seans.netTutar.toStringAsFixed(2)} tahsil edildi (${odeme.name})", // ekrana seansın kodunu, net tutarını virgülden sonra 2 basamakla string tipinde yazdırıyoruz ve ödeme yönteminin adını yazdırıyoruz
        );
      }
    }
    print("Hata [$seansKodu] kodlu seans bulunamadı"); //seans kodu bulunamazsa hata mesajı atar
    return; // fonksiyonun biteceği yer.
  }

  void seansiIptalEt(String seansKodu, {String? iptalNedeni}) { // Seansı iptal etmek için metot oluşturduk, iptal nedeni verilmesi zorunlu değildir
    for (var seans in _seanslar) { // kayıtlı tüm seansların üzerinde dolaşıyoruz
      if (seans.seansKodu == seansKodu) { // listedeki seansın kodunun aranan kodla eşleşip eşleşmediğini kontrol ediyoruz
        seans.durum = SeansDurumu.iptalEdildi; // eşleşen seansın durumunu iptal edildi olarak değiştiriyoruz
        print(
          "Seans İptal Edildi [${seans.seansKodu}]: ${iptalNedeni ?? "Gerekçe Belirtilmedi"}", /* seansın kodunu ve iptal nedenini ekrana yazdırıyoruz iptal nedeni varsa iptal neden
          yoksa gerekçe belirtilmedi uyarısı yazıcak*/
        );
        return; //fonksiyonu bitirir
      }
    }
  }

  // Finansal Rapor Metotları(fonksiyonel dart)
  double get toplamTahsilEdilenCiro => _seanslar // toplamTahsilEdilenCiro adında getter oluşturduk, tüm seanslardan seans durumu tamamlandi olan seansları where ile çekip fold ile iteratif olarak toplayıp elde edilen toplam net ciroyu hesaplar
      .where((s) => s.durum == SeansDurumu.tamamlandi)
      .fold(0.0, (toplam, s) => toplam + s.netTutar);

  double get beklenenPotansiyelCiro => _seanslar // beklenenPotansiyelCiro adında getter oluşturduk, tüm seanslardan seans durumu bekliyor veya odadaIslemde olan seansları where ile seçip fold ile iteratif olarak toplayıp beklenen toplam net geliri hesaplar
      .where(
        (s) =>
            s.durum == SeansDurumu.bekliyor ||
            s.durum == SeansDurumu.odadaIslemde,
      )
      .fold(0.0, (toplam, s) => toplam + s.netTutar);

  // kategori bazlı seans sayıları

  Map<HizmetKategorisi, int> kategoriBazliSeansDagilimi() { // Hizmet kategorilerine göre kaç seans bulunduğunu hesaplayan metot oluşturduk
    final Map<HizmetKategorisi, int> dagilim = {}; // Her hizmet kategorisini anahtar, o kategorideki seans sayısını değer olarak tutacak boş bir Map oluşturduk
    for (var kat in HizmetKategorisi.values) { // HizmetKategorisi enumunda bulunan tüm kategorilerin üzerinde dolaşıyoruz
      dagilim[kat] = 0; // her kategori için başlangıç seans sayısını 0 olarak belirliyoruz
    }
    for (var s in _seanslar) { // kayıtlı tüm seansların üzerinde dolaşıyoruz
      dagilim[s.kategori] = (dagilim[s.kategori] ?? 0) + 1; // seansın kategorisini bulup o kategorinin mevcut sayısını 1 artırıyoruz, değer yoksa ?? ile 0 kabul ediyoruz
    }
    return dagilim; // dağılım değerini döndürüyoruz 
  }

  Set<String> gorevliUzmanKadrosu() { // Seanslarda görevli olan uzmanların benzersiz isimlerini getiren metot oluşturduk
    return _seanslar.map((s) => s.sorumluUzman).whereType<String>().toSet(); // seanslardan uzman isimlerini alıyoruz, null olanları whereType ile çıkarıyoruz ve toSet ile tekrar eden uzmanları tek değere indiriyoruz
  }

  //Uzmansız kalan seanslar
  List<SeansKaydi> uzmansizSeanslariGetir() { // Henüz uzman atanmamış seansları getiren metot oluşturduk
    return _seanslar.where((s) => s.sorumluUzman == null).toList(); // uzmanı null olan seansları filtreleyip yeni bir liste olarak döndürüyoruz
  }

  void gunSonuRaporuYazdir() { // Gün sonunda seans, finans ve uzman bilgilerini terminale yazdıran metot oluşturduk
    print("Günlük Seans ve İşlem Çizelgesi"); // raporun başlığını yazdırıyoruz
    print("---------------------------------------"); // ara çizgiyi çeker
    print(
      "${'Kod'.padRight((10))} | " // kod kelimesi 3 harftir 10 karakterlik alana yaymak için sağa 7 tane boşluk atar
      "${'Danışan'.padRight(16)} | " // danışan kelimesi 7 harftir 16 karakterlik alana yaymak için sağa 9 tane boşluk atar
      "${'İşlem'.padRight(20)} | " //  işlem kelimesi 5 harftir 20 karakterlik alana yaymak için sağa 15 tane boşluk atar
      "${'Uzman'.padRight(18)} | " // uzman kelimesi 5 harftir 18 karakterlik alana yaymak için sağa 13 tane boşluk atar
      "${'Tutar'.padRight(10)} | " // tutar kelimesi 5 harftir 10 karakterlik alana yaymak için sağa 5 tane boşluk atar
      "${'Durum'} | ", // Durum yazdırır ekrana
    );
    print("---------------------------------------"); // ara çizgiyi çeker
 
    for (var s in _seanslar) { // s değişkeni ile _seanslar listesini dolanır.
      final String uzman = s.sorumluUzman ?? " Nöbetçi Bekliyor"; // uzman değişkeni s değişkeninin sorumluluUzman değişkeni nullsa Nöbetçi Bekliyor değerini yoksa s.sorumluUzman değişkenini alır
      final String durumRozet = switch (s.durum) {
        SeansDurumu.tamamlandi => "Tamamlandı",// seans durumu enum tamamlandi ise string tipindeki durumRozeti "İTamamlandı" değerini alır
        SeansDurumu.odadaIslemde => "İşlemde", // seans durumu enum odadaIslemde ise string tipindeki durumRozeti "İşlemde" değerini alır
        SeansDurumu.bekliyor => "Bekliyor", // seans durumu enum bekliyor ise string tipindeki durumRozeti "Bekliyor" değerini alır
        SeansDurumu.iptalEdildi => "İptal", // seans durumu enum iptaledildi ise string tipindeki durumRozeti "İptal" değerini alır
      };

      print(
        "${s.seansKodu.padRight(10)} | " //seansKodu 10 karakterden küçükse 10 karaktere yaymak için 10-seansKodu.length kadar bosluk atar. yoksa boşluk atmaz
        "${s.danisan.adSoyad.padRight(10)} | " //danisan.adSoyad 10 karakterden küçükse 10 karaktere yaymak için 10-danisan.adSoyad.length kadar bosluk atar. yoksa boşluk atmaz
        "${s.islemAdi.padRight(10)} | "//islemAdi 10 karakterden küçükse 10 karaktere yaymak için 10-islemAdi.length kadar bosluk atar. yoksa boşluk atmaz
        "${uzman.padRight(10)} | "//uzman 10 karakterden küçükse 10 karaktere yaymak için 10-uzman.length kadar bosluk atar. yoksa boşluk atmaz
        "${s.netTutar.toStringAsFixed(2).padRight(10)} | "//netTutar 10 karakterden küçükse 10 karaktere yaymak için 10-netTutar.length kadar bosluk atar. yoksa boşluk atmaz
        "$durumRozet",//durum rozeti değişkeni yazdırır.
      );
    }

    print("---------------------------------------"); // ara çizgiyi çeker
    print("Finansal Özet:"); // Ekrana Finansal Özet yazısı yazdırır
    print(
      " * Gerçekleşen (kasadaki net ciro) : ${toplamTahsilEdilenCiro.toStringAsFixed(2)}", // toplam tahsil edilen ciro virgülden sonra 2 basamak gözükcek şekilde stringe çevirilip yazdırılır.
    );
    print(
      " * Bekleyen Potansiyen Alacak : ${beklenenPotansiyelCiro.toStringAsFixed(2)}", // potansiyel tahsil edilecek ciro virgülden sonra 2 basamak gözükcek şekilde stringe çevirilip yazdırılır.
    );
    print(" * Toplam Seans : ${_seanslar.length} Randevu"); // randevu sayısını _seanslar dizisinin uzunluğunu alıp yazdırır.
    print("---------------------------------------"); // ara çizgiyi çeker
    print("Aktif Uzmanlar"); // aktif uzmanlar yazısı yazdırılır
    final uzmanlar = gorevliUzmanKadrosu(); // burda uzmanları gorveliUzmanKadrosu setine eşitliyor doğrudan değişken türü verilmemesine rağmen inference mekanizması ile gorevliUzmanKadrosu fonksiyonun döndürdüğü veri tipine ayarlıyor
    if (uzmanlar.isEmpty) { // uzmanlar seti boş ise kayıt bulunamadı var ise set teki elemanları aralarına virgül koyarak tek bir string olarak birleştirip ekrana yazdırıyor
      print("Kayıtlı Uzman Bulunamadı"); 
    } else {
      print(" ${uzmanlar.join(', ')}");
    }
    final uzmansizlar = uzmansizSeanslariGetir(); // burda uzmansızlar uzman atanmamış seanslar setine eşitliyor doğrudan değişken türü verilmemesine rağmen inference mekanizması ile uzmansizSeanslariGetir fonksiyonun döndürdüğü veri tipine ayarlıyor
    if (uzmansizlar.isNotEmpty) { // eğer liste boş değilse listenin uzunluğu kadar adet seansa uzman atanmadğın gösterir.
      print(
        "Dikkat: ${uzmansizlar.length} adet seansa henüz uzman atanmamıştır",  // eğer liste boş değilse listenin uzunluğu kadar adet seansa henüz uzman atanmamış der ve akabinde alt tarafa
      );
      for (var u in uzmansizlar) {
        print("->[${u.seansKodu}] ${u.danisan.adSoyad} (${u.islemAdi})"); // burda uzman atanmayan seansların seans kodunu danışan adı ve soyadını ve islem adını ekrana yazdırır.
      }
    }
    print("---------------------------------------"); // ara çizgiyi çeker
  }
}

void main() { // Programın çalışmaya başladığı ana fonksiyonu oluşturduk
  print("Klinik yönetim sistemi başlatılıyor...."); // sistemin başladığını terminale yazdırıyoruz
  final yonetici = KlinikYoneticisi(subeAdi: "Softito Bağcılar Şubesi"); // KlinikYoneticisi nesnesi oluşturup şube adını veriyoruz

  //danışanları oluşturalım
  final d1 = Danisan( //Danisan türünde d1 nesnesi oluşturma
    id: "DAN-101", // danışanın benzersiz id değerini veriyoruz
    adSoyad: "Ahmet Yılmaz", // danışanın ad ve soyad bilgisini veriyoruz
    telefon: "0555 555 55 55", // danışanın telefon numarasını veriyoruz
    vipUyeMi: true, // danışanın VIP üye olduğunu belirtiyoruz
    alerjiler: ["Retinol,Aspirin"], // danışanın alerji bilgisini liste olarak veriyoruz
    ozelCiltNotu: "Cilt bariyeri hassas", // danışanın özel cilt notunu veriyoruz
  );
  final d2 = Danisan(//Danisan türünde d2 nesnesi oluşturma
    id: "DAN-102", // danışanın benzersiz id değerini veriyoruz
    adSoyad: "Ahmet Yılan", // danışanın ad ve soyad bilgisini veriyoruz
    telefon: "0555 555 55 55", // danışanın telefon numarasını veriyoruz
    vipUyeMi: false, // danışanın VIP üye olup olmadığını belirtiyoruz
    alerjiler: [], // danışanın alerji listesini veriyoruz
  );
  final d3 = Danisan(//Danisan türünde d3 nesnesi oluşturma
    id: "DAN-103", // danışanın benzersiz id değerini veriyoruz
    adSoyad: "Mehmet Yılmaz", // danışanın ad ve soyad bilgisini veriyoruz
    telefon: "0555 555 55 55", // danışanın telefon numarasını veriyoruz
    vipUyeMi: true, // danışanın VIP üye olup olmadığını belirtiyoruz
    alerjiler: ["Retinol,Aspirin"], // danışanın alerji listesini veriyoruz
  );
  final d4 = Danisan( //Danisan türünde d4 nesnesi oluşturma
    id: "DAN-104", // danışanın benzersiz id değerini veriyoruz
    adSoyad: "Ahmet Mehmet Yılmaz", // danışanın ad ve soyad bilgisini veriyoruz
    telefon: "0555 555 55 55", // danışanın telefon numarasını veriyoruz
    vipUyeMi: true, // danışanın VIP üye olup olmadığını belirtiyoruz
    alerjiler: [], // danışanın alerji listesini veriyoruz
    ozelCiltNotu: "Cilt bariyeri hassas", // danışanın özel cilt notunu veriyoruz
  );

  yonetici.danisanKaydet(d1); // d1 danışanını yöneticinin rehberine kaydediyoruz
  yonetici.danisanKaydet(d2); // d2 danışanını yöneticinin rehberine kaydediyoruz
  yonetici.danisanKaydet(d3); // d3 danışanını yöneticinin rehberine kaydediyoruz
  yonetici.danisanKaydet(d4); // d4 danışanını yöneticinin rehberine kaydediyoruz

  print("Danışan güvenlik kontrolü"); // danışan güvenlik kontrolü yazdırır
  print(d1.bilgiOzeti);//d1 danışanının bilgi ozetini yazdırır
  print(d2.bilgiOzeti);//d2 danışanının bilgi ozetini yazdırır
  print("----------------------------------");// araya çizgi çeker

  // randevular oluşturuluyor
  final seans1 = SeansKaydi( // Birinci seans kaydını oluşturuyoruz
    seansKodu: "SNS-2026-1", // seansın benzersiz kodunu veriyoruz
    danisan: d1, // seansın hangi danışana ait olduğunu belirtiyoruz
    kategori: HizmetKategorisi.Lipo, // seansın hizmet kategorisini belirtiyoruz
    islemAdi: "Lipo gerisini bilmiyorum", // yapılacak işlemin adını belirtiyoruz
    birimFiyat: 6500.0, // bir seansın birim fiyatını belirtiyoruz
    seansSayisi: 2, // uygulanacak seans sayısını belirtiyoruz
    indirimOrani: 5.0, // uygulanacak indirim oranını yüzde olarak belirtiyoruz
    sorumluUzman: "Sümeyye Arab", // seanstan sorumlu uzmanı belirtiyoruz
  );
  final seans2 = SeansKaydi( // İkinci seans kaydını oluşturuyoruz
    seansKodu: "SNS-2026-2", // seansın benzersiz kodunu veriyoruz
    danisan: d2, // seansın hangi danışana ait olduğunu belirtiyoruz
    kategori: HizmetKategorisi.ciltYenileme, // seansın hizmet kategorisini belirtiyoruz
    islemAdi: "Siverex ile tyüz temizleme", // yapılacak işlemin adını belirtiyoruz
    birimFiyat: 2500.0, // bir seansın birim fiyatını belirtiyoruz
    seansSayisi: 5, // uygulanacak seans sayısını belirtiyoruz
    indirimOrani: 15.0, // uygulanacak indirim oranını yüzde olarak belirtiyoruz
    sorumluUzman: null, // seanstan sorumlu uzmanı belirtiyoruz
  );
  final seans3 = SeansKaydi( // Üçüncü seans kaydını oluşturuyoruz
    seansKodu: "SNS-2026-3", // seansın benzersiz kodunu veriyoruz
    danisan: d3, // seansın hangi danışana ait olduğunu belirtiyoruz
    kategori: HizmetKategorisi.lazerEpilasyon, // seansın hizmet kategorisini belirtiyoruz
    islemAdi: "Tüm Vücut", // yapılacak işlemin adını belirtiyoruz
    birimFiyat: 25000.0, // bir seansın birim fiyatını belirtiyoruz
    seansSayisi: 15, // uygulanacak seans sayısını belirtiyoruz
    indirimOrani: 0.0, // uygulanacak indirim oranını yüzde olarak belirtiyoruz
    sorumluUzman: "Tuba Aydın", // seanstan sorumlu uzmanı belirtiyoruz
  );
  final seans4 = SeansKaydi( // Dördüncü seans kaydını oluşturuyoruz
    seansKodu: "SNS-2026-4", // seansın benzersiz kodunu veriyoruz
    danisan: d4, // seansın hangi danışana ait olduğunu belirtiyoruz
    kategori: HizmetKategorisi.medikalEstetik, // seansın hizmet kategorisini belirtiyoruz
    islemAdi: "Burun Estetiği", // yapılacak işlemin adını belirtiyoruz
    birimFiyat: 1500.0, // bir seansın birim fiyatını belirtiyoruz
    seansSayisi: 3, // uygulanacak seans sayısını belirtiyoruz
    sorumluUzman: "Alaaddin Odabaşı", // seanstan sorumlu uzmanı belirtiyoruz
  );
  yonetici.randevuOlustur(seans1); // birinci randevuyu sisteme kaydediyoruz
  yonetici.randevuOlustur(seans2); // ikinci randevuyu sisteme kaydediyoruz
  yonetici.randevuOlustur(seans3); // üçüncü randevuyu sisteme kaydediyoruz
  yonetici.randevuOlustur(seans4); // dördüncü randevuyu sisteme kaydediyoruz
  print("Seanslar Gönderiliyor");// ekrana seanslar gönderiliyor mesajını yazdırıyoruz

  //seans 1 başarıyla tamamlanıyor (kredi kartı ile ödeme);
  yonetici.seansiTamamla(
    seansKodu: "SNS-2026-1", // seansın benzersiz kodunu veriyoruz
    odeme: OdemeYontemi.krediKarti,// OdenemYontemi enumundan kredikartını odeme attribute una eşitliyoruz
  );
  //seans 2 başarıyla tamamlanıyor (nakit ödeme);
  yonetici.seansiTamamla(seansKodu: "SNS-2026-2", odeme: OdemeYontemi.nakit); // seansın benzersiz kodunu veriyoruz ve denemYontemi enumundan nakiti odeme attribute una eşitliyoruz
  //seans 4 iptal ediliyor
  yonetici.seansiIptalEt( // kullanıcı id sine ve iptal nedenini paramtere olarak yollayıp iptal ediyoruz
    "SNS-2026-04",
    iptalNedeni: "Danışanın şehir dışından tanıdığı geldiği için gelemedi",
  );

  yonetici.gunSonuRaporuYazdir();//gün sonu raporunu yazdırıyoruz
}
