import 'package:cloud_firestore/cloud_firestore.dart';

class OgrenciModel {
  final String id;
  final String adSoyad;
  final String projeAdi;
  final int notu;
  final DateTime kayitTarihi;
  const OgrenciModel({ 
    required this.id,
    required this.adSoyad,
    required this.projeAdi,
    required this.notu,
    required this.kayitTarihi,
  });
  factory OgrenciModel.fromFireStore(DocumentSnapshot doc){
    final veri=doc.data() as Map<String,dynamic>? ?? {};
    return OgrenciModel(id: doc.id, adSoyad: veri['adSoyad'] as String? ?? "İsimsiz öğrenci", projeAdi: veri['projeAdi'] as String? ?? "Henüz proje yok", notu: (veri['notu'] as num?)?.toInt() ??0, kayitTarihi: (veri['kayitTarihi'] as Timestamp?)?.toDate() ?? DateTime.now());
  }
}
class FireStoreOgrenciServisi{
  final CollectionReference _ogrencilerKoleksiyonu=FirebaseFirestore.instance.collection('ogrenciler');
  Future<void> ogrenciEkle({
    required String adSoyad,
    required String projeAdi,
    required int notu,
  })async{
    try{
      await _ogrencilerKoleksiyonu.add({ 
        'adSoyad':adSoyad,
        'projeAdi':projeAdi,
        'notu':notu,
        'kayitTarihi':FieldValue.serverTimestamp(),
      });
      print("Öğrenci başrıyla kaydedildi");
    }catch(e){
      print("Öğrenci ekleme başarısı $e");
      rethrow;
    }
  }
  Future<void> ogrenciIdKaydet( { 
    required String tcNo,
    required String adSoyad,
    required String projeAdi,
  })async{
    await _ogrencilerKoleksiyonu.doc(tcNo).set( {  // id yi tcNo olarak set eder.
      'adSoyad':adSoyad,
      'projeAdi':projeAdi,
      'guncellemTarihi':FieldValue.serverTimestamp(),
    },SetOptions(merge: true)); // merge true ile update yapılmasını sağlar merge false olursa veritabanındaki tüm bilgileri silip sadece burda girilen verileri açar
  }
  Future<List<OgrenciModel>> tumOgrencileriGetir() async{
    try{
      final QuerySnapshot snapshot=await _ogrencilerKoleksiyonu.orderBy('notu',descending: true).get();
      return snapshot.docs.map((doc)=>OgrenciModel.fromFireStore(doc)).toList();
    }catch(e){
      print("Veri çekmede hata var");
      return [];
    }
  }

  Future<void> ogrenciNotuGuncelle(String documentId, int yeniNot) async{
    await _ogrencilerKoleksiyonu.doc(documentId).update( { 
      'notu':yeniNot,
      'sonDuzenleme':FieldValue.serverTimestamp(),
    });
  }
  Future<void> ogrenciSil(String documentId) async{
    await _ogrencilerKoleksiyonu.doc(documentId).delete();
    print("$documentId referanslı veri tamamen silindi");
  }


}