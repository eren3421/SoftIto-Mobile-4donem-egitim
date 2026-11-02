
import 'dart:convert';
import 'package:http/http.dart';
class UrunModel{
    final int id;
    final String baslik;
    final double fiyat;
    final String kategori;
    final String resimUrl;
    const UrunModel({required this.id,required this.baslik, required this.fiyat, required this.kategori, required this.resimUrl,});
    factory UrunModel.fromJson(Map<String,dynamic> json){
        return UrunModel( 
            id: json ['id'] as int? ?? 0,
            baslik: json ['title'] as String? ?? "İsimsiz ürün",
            fiyat: (json ['price'] as double num?)?.toDouble() ?? 0.0,
            kategori: json ['category'] as String? ?? "Genel",
            resimUrl: json ['image'] as String? ?? "https://via.placeholder.com/150",
        );
    }
    
}
abstract class IUrunServisi{
    Future<List<UrunModel>> urunleriGetir();
}
class CanliApiUrunServisi implements IUrunServisi {
  @override
  Future<List<UrunModel>> urunleriGetir() async {
    // TODO: implement urunleriGetir
    try{
        final yanit=await http.get(Uri.parse("_base_url")).timeout(
            const Duration(seconds:10),
            onTimeout:(){
                throw (Exception 'Ağ zamanaşımı')
            }
        );
        if(yanit.statusCode==200){
            final List <dynamic> hamListe=jsonDecode(yanit.body) as List<dynamic>;
            return hamListe.map((item)=>UrunModel.fromJson(item as Map<String,dynamic>)).toList();
        }else{
            throw Exception('Sunucu hatası: ${yanit.statusCode}');
        }
    }
    catch(e){
        print('Ağ hatası $e');
        rethrow;
    }
  }
  
}