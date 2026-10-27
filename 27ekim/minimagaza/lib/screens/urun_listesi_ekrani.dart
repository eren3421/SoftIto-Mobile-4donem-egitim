import 'package:flutter/material.dart';
import '../models/kategor.dart';
import '../services/urun_servisi.dart';
import '../services/mock_urun_servisi.dart';
import '../models/urun.dart';

class UrunListesiEkrani extends StatefulWidget{
  const UrunListesiEkrani({super.key});
  @override
  State<UrunListesiEkrani> createState()=> _UrunListesiEkraniState();

}
class _UrunListesiEkraniState extends State<UrunListesiEkrani>{
  final IUrunServisi _servis=MockUrunServisi();
  bool _yukleniyorMu=true;
  Kategori _seciciKategori=Kategori.hepsi;
  String _aramaKelimesi="";
  List<Urun> _gosterilenUrunler=[];
  @override
  void initState(){
    super.initState();
    _urunleriYukle();
  }
  Future<void> _urunleriYukle() async{
    setState((){
      _yukleniyorMu=true;
    });
    final urunler=await _servis.kategoriyeGoreGetir(_seciciKategori);
    if(mounted){
      setState(() {
        _gosterilenUrunler=urunler;
        _yukleniyorMu=false;
      });
    }
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar:AppBar(
        title:const Text("Mini Mağaza"),
      ),
      body: _yukleniyorMu ? const Center(child: CircularProgressIndicator())
      :Center(child:Text("${_gosterilenUrunler.length} adet ürün hazır")),
    );
  }
}