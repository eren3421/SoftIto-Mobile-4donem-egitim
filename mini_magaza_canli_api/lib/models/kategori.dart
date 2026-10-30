// Ürün kategorilerini tip güvenli (type-safe) şekilde yöneten numaralandırma (enum)
enum Kategori {
  // Tüm kategorileri temsil eden varsayılan filtre seçeneği
  hepsi,
  // Elektronik ürünler kategorisi (FakeStore: electronics)
  elektronik,
  // Takı ve mücevher kategorisi (FakeStore: jewelery)
  taki,
  // Erkek giyim kategorisi (FakeStore: men's clothing)
  erkekGiyim,
  // Kadın giyim kategorisi (FakeStore: women's clothing)
  kadinGiyim,
// Kategori enum tanımının kapanış parantezi
}

// Kategori enum'ına ek işlevsellik ve yardımcı metotlar katan extension
extension KategoriExtension on Kategori {
  // Kullanıcı arayüzünde (UI) çip veya başlıklarda görünecek Türkçe isim
  String get gorunenAd {
    // Enum değerine göre ekranda gösterilecek metni belirleyen switch yapısı
    switch (this) {
      // hepsi seçeneği için Türkçe başlık
      case Kategori.hepsi:
        // 'Tümü' metnini döndürür
        return 'Tümü';
      // elektronik seçeneği için Türkçe başlık
      case Kategori.elektronik:
        // 'Elektronik' metnini döndürür
        return 'Elektronik';
      // taki seçeneği için Türkçe başlık
      case Kategori.taki:
        // 'Takı & Mücevher' metnini döndürür
        return 'Takı & Mücevher';
      // erkekGiyim seçeneği için Türkçe başlık
      case Kategori.erkekGiyim:
        // 'Erkek Giyim' metnini döndürür
        return 'Erkek Giyim';
      // kadinGiyim seçeneği için Türkçe başlık
      case Kategori.kadinGiyim:
        // 'Kadın Giyim' metnini döndürür
        return 'Kadın Giyim';
    // Switch bloğu kapanışı
    }
  // gorunenAd getter kapanış parantezi
  }

  // FakeStore REST API'sinden gelen İngilizce ham metni enum türüne dönüştüren fabrika metodu
  static Kategori apiMetnindenUret(String apiMetni) {
    // Gelen ham metni küçük harfe çevirerek eşleştirme yapan switch yapısı
    switch (apiMetni.toLowerCase().trim()) {
      // FakeStore API 'electronics' kategorisi
      case 'electronics':
        // elektronik enum değerini döndürür
        return Kategori.elektronik;
      // FakeStore API 'jewelery' kategorisi
      case 'jewelery':
        // taki enum değerini döndürür
        return Kategori.taki;
      // FakeStore API 'men\'s clothing' kategorisi
      case "men's clothing":
        // erkekGiyim enum değerini döndürür
        return Kategori.erkekGiyim;
      // FakeStore API 'women\'s clothing' kategorisi
      case "women's clothing":
        // kadinGiyim enum değerini döndürür
        return Kategori.kadinGiyim;
      // Beklenmeyen veya bilinmeyen bir kategori geldiğinde devreye giren varsayılan durum
      default:
        // Güvenli varsayılan olarak elektronik atanır
        return Kategori.elektronik;
    // Switch bloğu kapanışı
    }
  // apiMetnindenUret metodu kapanış parantezi
  }
// Extension tanımının kapanış parantezi
}
