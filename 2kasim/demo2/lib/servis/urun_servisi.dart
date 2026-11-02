import 'dart:convert';
import 'package:http/http.dart' as http;
import 'iurunservis.dart';
import '../model/urun.dart';
class CanliApiUrunServisi implements IUrunServisi {
  @override
  Future<List<UrunModel>> urunleriGetir() async {
    // TODO: implement urunleriGetir
    try{
        final yanit=await http.get(Uri.parse("_base_url")).timeout(
            const Duration(seconds:10),
            onTimeout:(){
                throw Exception ('Ağ zamanaşımı');
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