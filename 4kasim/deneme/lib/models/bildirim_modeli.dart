enum BildirimTuru { fcm, yukleme, abone, test }

class BildirimModeli {
  final String id;
  final String baslik;
  final String icerik;
  final DateTime tarih;
  final bool okunduMu;
  final BildirimTuru tur;

  const BildirimModeli({
    required this.id,
    required this.baslik,
    required this.icerik,
    required this.tarih,
    this.okunduMu = false,
    this.tur = BildirimTuru.fcm,
  });

  BildirimModeli copyWith({
    String? id,
    String? baslik,
    String? icerik,
    DateTime? tarih,
    bool? okunduMu,
    BildirimTuru? tur,
  }) {
    return BildirimModeli(
      id: id ?? this.id,
      baslik: baslik ?? this.baslik,
      icerik: icerik ?? this.icerik,
      tarih: tarih ?? this.tarih,
      okunduMu: okunduMu ?? this.okunduMu,
      tur: tur ?? this.tur,
    );
  }
}