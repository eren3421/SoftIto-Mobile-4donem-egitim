import 'package:flutter/services.dart';

import '../models/kategor.dart';
import '../models/urun.dart';
import 'urun_servisi.dart';
class MockUrunServisi implements IUrunServisi{
  final List<Urun> _urunDeposu=const[
    Urun(id:1,baslik: "Macbook M5 Pro Laptop",aciklama:"Yeni nesil Macbook pro",fiyat:180000,resimUrl:"https://picsum.photos/400/400/?random",kategori:Kategori.elektronik,stokAdeti: 5,),
    Urun(id:2,baslik: "Iphone 18 ",aciklama:"Yeni nesil tekefon",fiyat:150000,resimUrl:"https://picsum.photos/400/400/",kategori:Kategori.elektronik,stokAdeti: 7,),
    Urun(id:3,baslik: "Erkek L Gömlek ",aciklama:"gömlek",fiyat:500,resimUrl:"https://picsum.photos/400/400",kategori:Kategori.aksesuar,stokAdeti: 10,),
    Urun(id:4,baslik: "Yağmurluk ",aciklama:"su geçirmez",fiyat:1500,resimUrl:"https://picsum.photos/400/400",kategori:Kategori.giyim,stokAdeti: 5,),
    Urun(id:5,baslik: "Iphone 18 ",aciklama:"Yeni nesil tekefon",fiyat:150000,resimUrl:"https://picsum.photos/400/400",kategori:Kategori.elektronik,stokAdeti: 34,),
    Urun(id:6,baslik: "Adidas ",aciklama:"spor ayakkabı",fiyat:150,resimUrl:"https://picsum.photos/400/400",kategori:Kategori.ayakkabi,stokAdeti: 19,),
    Urun(id:7,baslik: "Samsung J2 ",aciklama:"Eski nesil android tekefon",fiyat:1500,resimUrl:"https://picsum.photos/400/400",kategori:Kategori.elektronik,stokAdeti: 7,),
    Urun(id:8,baslik: "PSP",aciklama:"El konsolu",fiyat:2500,resimUrl:"https://picsum.photos/400/400",kategori:Kategori.elektronik,stokAdeti: 10,),
    ];
    @override
    Future<List<Urun>> tumUrunleriGetir() async{
      await Future.delayed(const Duration(milliseconds: 1500));
      return List.from(_urunDeposu);
    }
    @override
    Future<List<Urun>> kategoriyeGoreGetir(Kategori kategori) async{
      await Future.delayed(const Duration(milliseconds: 400));
      if(kategori==Kategori.hepsi){
        return List.from(_urunDeposu);
      }
      return _urunDeposu.where((urun)=>urun.kategori==kategori).toList();
    }
    @override
    Future<List<Urun>> adaGoreAra(String araMetni) async{
      await Future.delayed(const Duration(milliseconds:300));
      if(araMetni.trim().isEmpty){
        return List.from(_urunDeposu);
      }
      return _urunDeposu.where((urun){
        final baslikKucuk=urun.baslik.toLowerCase();
        final arananKucuk=araMetni.toLowerCase();
        return baslikKucuk.contains(arananKucuk);
      }).toList();
    }
}