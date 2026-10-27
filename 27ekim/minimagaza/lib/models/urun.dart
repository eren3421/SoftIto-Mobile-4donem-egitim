import 'kategor.dart'; // Dosya adının doğruluğunu kontrol et

class Urun {
  final int id;
  final String baslik;
  final String aciklama;
  final double fiyat;
  final String resimUrl;
  final Kategori kategori;
  final int stokAdeti;
  final bool favoriMi;

  const Urun({
    required this.id,
    required this.baslik,
    required this.aciklama,
    required this.fiyat,
    required this.resimUrl,
    required this.kategori,
    required this.stokAdeti,
    this.favoriMi = false,
  });

  Urun copyWith({
    int? id,
    String? baslik,
    String? aciklama,
    double? fiyat,
    String? resimUrl,
    Kategori? kategori,
    int? stokAdeti,
    bool? favoriMi,
  }) {
    return Urun(
      id: id ?? this.id,
      baslik: baslik ?? this.baslik,
      aciklama: aciklama ?? this.aciklama,
      fiyat: fiyat ?? this.fiyat,
      resimUrl: resimUrl ?? this.resimUrl,
      kategori: kategori ?? this.kategori,
      stokAdeti: stokAdeti ?? this.stokAdeti,
      favoriMi: favoriMi ?? this.favoriMi,
    );
  }

  @override
  String toString() {
    return 'Urun(id: $id, başlık: $baslik, fiyat: $fiyat, favoriMi: $favoriMi)';
  }
}