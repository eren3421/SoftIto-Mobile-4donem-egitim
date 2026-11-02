import 'package:flutter/material.dart';
class SepetKontrolu{
  static final SepetKontrolu ornek=SepetKontrolu._dahili();
  SepetKontrolu._dahili();
  final ValueNotifier<int> urunSayisi=ValueNotifier<int>(0);
  void sepetEkle(){
    urunSayisi.value++;
  }
  void sepetiSifirla(){
    urunSayisi.value=0;
  }
}
class VitrinEkrani extends StatelessWidget{
    const VitrinEkrani({super.key});
    @override
    Widget build(BuildContext context){
      return Scaffold( 
        appBar:AppBar(title:const Text('Canlı Vitrin')),
        body:Center( 
          child:ElevatedButton.icon( 
            onPressed:(){
              SepetKontrolu.ornek.sepetEkle();
            },
            icon:const Icon(Icons.add_shopping_cart),
            label:const Text("Sepete ürün ekle (+1)"),
          ),
        ),
      );
    }
  }