import '../model/urun.dart';
import '../servis/urun_servisi.dart';
import '../servis/iurunservis.dart';
import 'package:flutter/material.dart';
class Ekran extends StatelessWidget{
    final IUrunServisi servis=CanliApiUrunServisi();
    const Ekran({super.key});
    List<UrunModel> _urunler;
    Future<void> urunleriYukle() async{
        _urunler=await servis.urunleriGetir();
    }
    Widget build(BuildContext context){
        return Scaffold(
            appBar:AppBar(title:const Text("Ürün Listesi")),
            body:FutureBuilder<List<UrunModel>>(
                future:urunleriYukle(),
                builder: (context,snapshot){
                    if(snapshot.hasData){
                        return ListView.builder(
                            itemCount:snapshot.data!.length,
                            itemBuilder:(context,index){
                                final urun=snapshot.data![index];
                                return ListTile(
                                    title:Text(urun.baslik),
                                    subtitle:Text(urun.fiyat.toString()),
                                    leading:Image.network(urun.resimUrl),
                                );
                            },
                        );
                    }else if(snapshot.hasError){
                        return Center(child:Text("Hata: ${snapshot.error}"));
                    }
                    return const Center(child:CircularProgressIndicator());
                },
            ),
        );
    }
}