import 'package:flutter/material.dart';
import 'vitrin.dart';
class ProfilEkrani extends StatelessWidget{
    const ProfilEkrani({super.key});
    @override
    Widget build (BuildContext context){
      return Scaffold(
        appBar:AppBar(title:const Text('Kullanıcı profili')),
        body:Center(
          child:TextButton(
            onPressed:()=>SepetKontrolu.ornek.sepetiSifirla(),
            child:const Text('Sepeti sıfırla'),
          ),
        ),
      );
    }
  }