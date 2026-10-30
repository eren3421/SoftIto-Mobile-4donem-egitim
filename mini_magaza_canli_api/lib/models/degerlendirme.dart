// Bir ürünün kullanıcı puanını ve değerlendirme sayısını tutan model sınıfı
class Degerlendirme {
  // Ürünün ortalama puanı (Örnek: 4.5, 3.9)
  final double puan;
  // Ürüne oy veren toplam kullanıcı sayısı (Örnek: 120)
  final int oySayisi;

  // Değerlendirme sınıfının değişmez (immutable) yapıcı metodu (constructor)
  const Degerlendirme({
    // Puan alanının zorunlu olduğunu belirten parametre
    required this.puan,
    // Oy sayısı alanının zorunlu olduğunu belirten parametre
    required this.oySayisi,
  // Yapıcı metodun kapanış parantezi
  });

  // REST API'den gelen iç içe (nested) JSON haritasını modele dönüştüren fabrika metodu
  factory Degerlendirme.fromJson(Map<String, dynamic> json) {
    // Yeni bir Degerlendirme nesnesi üretip geriye döndürür
    return Degerlendirme(
      // int veya double gelebilecek puan değerini güvenli biçimde double'a dönüştürür
      puan: (json['rate'] as num?)?.toDouble() ?? 0.0,
      // int gelebilecek oy sayısını güvenle okur, null ise 0 atar
      oySayisi: (json['count'] as num?)?.toInt() ?? 0,
    // Degerlendirme nesnesi oluşturma çağrısının kapanışı
    );
  // Degerlendirme.fromJson fabrika metodunun kapanış parantezi
  }

  // Değerlendirme nesnesini tekrar JSON Map yapısına dönüştüren yardımcı metot
  Map<String, dynamic> toJson() {
    // Dart Map koleksiyonunu döndürür
    return {
      // API'nin beklediği 'rate' anahtarı ve değeri
      'rate': puan,
      // API'nin beklediği 'count' anahtarı ve değeri
      'count': oySayisi,
    // Map tanımının kapanış parantezi
    };
  // toJson metodunun kapanış parantezi
  }
// Degerlendirme sınıfının kapanış parantezi
}
