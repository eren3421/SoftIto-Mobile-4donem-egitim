import 'dart:io';
import 'package:flutter/material.dart';
import '../models/bildirim_modeli.dart';
import '../serivecs/fcm_bildirim_servisi.dart';
import '../serivecs/storage_servisi.dart';
import '../widgets/bildirim_listesi.dart';
import '../widgets/gorsel_yukleme_karti.dart';

class StorageveFcmEkrani extends StatefulWidget {
  const StorageveFcmEkrani({super.key});
  @override
  State<StorageveFcmEkrani> createState() => _StorageveFcmEkraniState();
}

class _StorageveFcmEkraniState extends State<StorageveFcmEkrani> {
  final StorageServisi _storageServisi = StorageServisi();
  final FcmBildirimServisi _fcmBildirimServisi = FcmBildirimServisi();
  File? _secilenDosya;
  String? _yuklenenUrl;
  double _yuklemeOrani = 0.0;
  bool _yukleniyorMu = false;
  String? _fcmToken;
  bool _konuyaAboneMi = false;
  final List<BildirimModeli> _bildirimler = [];

  @override
  void initState() {
    super.initState();
    _fcmKur();
  }

  Future<void> _fcmKur() async {
    await _fcmBildirimServisi.baslat(
      onMesajGeldi: (message) {
        setState(() {
          _bildirimler.insert(
            0,
            BildirimModeli(
              id: message.messageId ?? DateTime.now().toIso8601String(),
              baslik: message.notification?.title ?? 'Yeni bildirim',
              icerik: message.notification?.body ?? '',
              tarih: DateTime.now(),
            ),
          );
        });
      },
    );
    final token = await _fcmBildirimServisi.tokenAl();
    setState(() => _fcmToken = token);
  }

  Future<void> _gorselSec({required bool kameradan}) async {
    try {
      final dosya = await _storageServisi.gorselSec(kameradan: kameradan);
      if (dosya != null) {
        setState(() {
          _secilenDosya = dosya;
          _yuklenenUrl = null;
          _yuklemeOrani = 0.0;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Görsel seçilemedi: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  Future<void> _bulutaYukle() async {
    if (_secilenDosya == null) return;
    setState(() => _yukleniyorMu = true);
    try {
      final dosyaAdi = 'profil_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final task = _storageServisi.yuklemeBaslat(
        dosya: _secilenDosya!,
        dosyaAdi: dosyaAdi,
      );
      task.snapshotEvents.listen((snapshot) {
        if (snapshot.totalBytes > 0) {
          setState(() {
            _yuklemeOrani = snapshot.bytesTransferred / snapshot.totalBytes;
          });
        }
      });
      final tamamlanan = await task;
      final url = await _storageServisi.urlGetir(tamamlanan.ref);
      setState(() {
        _yuklenenUrl = url;
        _yukleniyorMu = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Görsel Buluta başarıyla yüklendi"),
            backgroundColor: Color.fromARGB(0, 253, 1, 186),
          ),
        );
      }
    } catch (e) {
      setState(() => _yukleniyorMu = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Yükleme hatası $e'),
            backgroundColor: const Color.fromARGB(0, 17, 208, 0),
          ),
        );
      }
    }
  }

  Future<void> _aboneDegistir(bool deger) async {
    setState(() => _konuyaAboneMi = deger);
    if (deger) {
      await _fcmBildirimServisi.konuyaAboneOl('tum_sinif');
    } else {
      await _fcmBildirimServisi.konudanAyril("tum_sinif");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Softito Storage ve Fcm Çalışması",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            Text(
              "Bulut Yükleme ve Push bildirimleri",
              style: TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: const Color(0xff0F172A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GorselYuklemeKarti(
              secilenDosya: _secilenDosya,
              yuklenenUrl: _yuklenenUrl,
              yuklemeOrani: _yuklemeOrani,
              yukleniyorMu: _yukleniyorMu,
              onGaleridenSec: () => _gorselSec(kameradan: false),
              onKameradanCek: () => _gorselSec(kameradan: true),
              onBulutaYukle: _bulutaYukle,
            ),
            const SizedBox(height: 16),
            BildirimListesiKarti(
              bildirimler: _bildirimler,
              token: _fcmToken,
              konuyaAboneMi: _konuyaAboneMi,
              onAboneDegisti: _aboneDegistir,
            ),
          ],
        ),
      ),
    );
  }
}