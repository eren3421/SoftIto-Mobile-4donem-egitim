import 'package:flutter/material.dart';

import '../models/kategor.dart';
import '../models/urun.dart';
import '../services/urun_servisi.dart';
import '../services/mock_urun_servisi.dart';
import '../widget/urun_karti.dart';

class UrunListesiEkrani extends StatefulWidget {
  const UrunListesiEkrani({super.key});

  @override
  State<UrunListesiEkrani> createState() => _UrunListesiEkraniState();
  //createState depo
}

class _UrunListesiEkraniState extends State<UrunListesiEkrani> {
  final IUrunServisi _servis = MockUrunServisi();

  final TextEditingController _aramaController = TextEditingController();

  bool _yukleniyorMu = true;

  Kategori _seciliKategori = Kategori.hepsi;

  String _aramaKelimesi = "";

  List<Urun> _filtrelenmisUrunler = [];
  List<Urun> _tumUrunler = [];

  @override
  void initState() {
    super.initState();
    _urunleriYukle();
  }

  @override
  void dispose() {
    _aramaController.dispose();
    super.dispose();
  }

  Future<void> _urunleriYukle() async {
    setState(() {
      _yukleniyorMu = true;
    });

    final urunler = await _servis.tumUrunleriGetir();

    if (mounted) {
      setState(() {
        //durum değşkenleri
        _tumUrunler = urunler;
        _filtrelenmisUrunler = urunler;
        _yukleniyorMu = false;
      });
    }
  }

  void _filtreyiUygula() {
    final aranan = _aramaController.text.trim().toLowerCase();

    setState(() {
      _filtrelenmisUrunler = _tumUrunler.where((urun) {
        final kategoriyeUygunMu =
            (_seciliKategori == Kategori.hepsi) ||
            (urun.kategori == _seciliKategori);
        final aramaUygunMu =
            aranan.isEmpty ||
            urun.baslik.toLowerCase().contains(aranan) ||
            urun.aciklama.toLowerCase().contains(aranan);
        return kategoriyeUygunMu && aramaUygunMu;
      }).toList();
    });
  }

  void _favoriyiDegistir(Urun hedefUrun) {
    setState(() {
      final yeniUrun = hedefUrun.copyWith(favoriMi: !hedefUrun.favoriMi);
      final index = _tumUrunler.indexWhere((u) => u.id == hedefUrun.id);
      if (index != -1) {
        _tumUrunler[index] = yeniUrun;
      }
      _filtreyiUygula();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Mini Mağaza",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Badge(
                label: Text(
                  '${_tumUrunler.where((u) => u.favoriMi).length}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                //textin içinde child olamaz
                child: const Icon(Icons.favorite, color: Colors.red),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _aramaController,
              onChanged: (_) => _filtreyiUygula(),
              decoration:InputDecoration(
                hintText:"Ürün veya marka ara...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon:_aramaController.text.isNotEmpty ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed:(){
                    _aramaController.clear();
                    _filtreyiUygula();
                  },
                ) : null,
                filled:true,
                fillColor:Colors.grey.shade100,
                border:OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 17,vertical: 8),
            child:Row(
              children:Kategori.values.map((kategori){
                final seciliMi=_seciliKategori==kategori;
                return Padding(
                  padding:const EdgeInsets.symmetric(horizontal:4.0),
                  child: ChoiceChip(
                    avatar:Text(kategori.ikon),
                    label:Text(kategori.baslik),
                    selected:seciliMi,
                    onSelected:(secildi){
                      if(secildi){
                        setState((){
                          _seciliKategori=kategori;
                          _filtreyiUygula();
                        });
                      }
                    }
                  )
                );
              }).toList(),
            )
          ),
          Expanded(
            child: _yukleniyorMu ? const Center(child: CircularProgressIndicator()):_filtrelenmisUrunler.isEmpty ? Center(
              child:Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  Icon(Icons.search_off_rounded,size:64,color:Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    'Aradığınız kriterlere uygun ürün bulunamadı',
                    style:TextStyle(color: Colors.grey.shade600,fontSize:16,fontWeight:FontWeight.w600),
                  ),
                ]
              )
            )
            :ListView.builder(
              itemCount: _filtrelenmisUrunler.length,
              itemBuilder:(context,index){
                final urun=_filtrelenmisUrunler[index];
                return UrunKarti(
                  urun:urun,
                  onFavoriTiklandi: ()=>_favoriyiDegistir(urun),
                  onDetayTiklandi:()=>{
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:Text('${urun.baslik} tıklandı'),
                        duration: const Duration(milliseconds: 600),
                      ),
                    )
                  },
                );
              }
            )
          )
        ],
      ),
    );
  }
}