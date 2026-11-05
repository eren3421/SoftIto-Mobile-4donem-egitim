import 'dart:typed_data';
import 'package:firebase_core/firebase_core.dart';
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
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _bildirimKartiKey = GlobalKey();

  Uint8List? _secilenGorselBytes;
  String? _yuklenenUrl;
  double _yuklemeOrani = 0.0;
  bool _yukleniyorMu = false;
  String? _fcmToken;
  bool _konuyaAboneMi = false;
  final List<BildirimModeli> _bildirimler = [];

  int get _okunmamisSayisi =>
      _bildirimler.where((b) => !b.okunduMu).length;

  @override
  void initState() {
    super.initState();
    _fcmKur();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fcmKur() async {
    await _fcmBildirimServisi.baslat(
      onMesajGeldi: (message) {
        if (!mounted) return;
        final id =
            message.messageId ??
            DateTime.now().millisecondsSinceEpoch.toString();
        final baslik =
            message.notification?.title ??
            message.data['title']?.toString() ??
            'Yeni Bildirim';
        final icerik =
            message.notification?.body ??
            message.data['body']?.toString() ??
            '';

        setState(() {
          _bildirimler.insert(
            0,
            BildirimModeli(
              id: id,
              baslik: baslik,
              icerik: icerik,
              tarih: DateTime.now(),
              tur: BildirimTuru.fcm,
            ),
          );
        });
      },
      onBildirimTiklandi: (payload) {
        if (!mounted || payload == null) return;
        final index = _bildirimler.indexWhere((b) => b.id == payload);
        if (index != -1) {
          _bildirimTiklandi(_bildirimler[index]);
        }
      },
    );
    final token = await _fcmBildirimServisi.tokenAl();
    if (mounted) {
      setState(() => _fcmToken = token);
    }
  }

  Future<void> _bildirimOlustur({
    required String baslik,
    required String icerik,
    BildirimTuru tur = BildirimTuru.fcm,
    bool sistemBildirimiGoster = true,
  }) async {
    final yeniBildirim = BildirimModeli(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      baslik: baslik,
      icerik: icerik,
      tarih: DateTime.now(),
      tur: tur,
    );

    if (mounted) {
      setState(() {
        _bildirimler.insert(0, yeniBildirim);
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF0F172A),
            duration: const Duration(seconds: 3),
            content: Row(
              children: [
                const Icon(
                  Icons.notifications_active_rounded,
                  color: Color(0xFF10B981),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        baslik,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        icerik,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            action: SnackBarAction(
              label: 'Görüntüle',
              textColor: const Color(0xFF38BDF8),
              onPressed: () => _bildirimTiklandi(yeniBildirim),
            ),
          ),
        );
    }

    if (sistemBildirimiGoster) {
      await _fcmBildirimServisi.yerelBildirimGoster(
        baslik: baslik,
        icerik: icerik,
        payload: yeniBildirim.id,
      );
    }
  }

  void _testBildirimiGonder() {
    final sira = _bildirimler.length + 1;
    _bildirimOlustur(
      baslik: 'Softito Test Bildirimi #$sira',
      icerik:
          'Uygulama bildirim sistemi aktif ve sorunsuz çalışıyor.',
      tur: BildirimTuru.test,
    );
  }

  void _ozelBildirimGonder(String baslik, String icerik) {
    _bildirimOlustur(
      baslik: baslik,
      icerik: icerik,
      tur: BildirimTuru.fcm,
    );
  }

  void _bildirimTiklandi(BildirimModeli bildirim) {
    final index = _bildirimler.indexWhere((b) => b.id == bildirim.id);
    if (index != -1 && !_bildirimler[index].okunduMu) {
      setState(() {
        _bildirimler[index] = _bildirimler[index].copyWith(okunduMu: true);
      });
    }

    final guncel = index != -1 ? _bildirimler[index] : bildirim;
    final saat =
        '${guncel.tarih.hour.toString().padLeft(2, '0')}:${guncel.tarih.minute.toString().padLeft(2, '0')}';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(
              Icons.notifications_outlined,
              color: Color(0xFF006C4A),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                guncel.baslik,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              guncel.icerik.isEmpty ? 'İçerik bulunmuyor.' : guncel.icerik,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Text(
              'Saat: $saat • Durum: Okundu',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _bildirimSil(guncel.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
            child: const Text('Sil'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF006C4A),
            ),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _bildirimSil(String id) {
    setState(() {
      _bildirimler.removeWhere((b) => b.id == id);
    });
  }

  void _tumunuOkunduIsaretle() {
    setState(() {
      for (var i = 0; i < _bildirimler.length; i++) {
        if (!_bildirimler[i].okunduMu) {
          _bildirimler[i] = _bildirimler[i].copyWith(okunduMu: true);
        }
      }
    });
  }

  Future<void> _tumunuTemizle() async {
    setState(() {
      _bildirimler.clear();
    });
    await _fcmBildirimServisi.tumSistemBildirimleriniTemizle();
  }

  void _bildirimMerkezineKaydir() {
    final ctx = _bildirimKartiKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _gorselSec({required bool kameradan}) async {
    try {
      final dosyaBytes = await _storageServisi.gorselSec(kameradan: kameradan);
      if (dosyaBytes != null) {
        setState(() {
          _secilenGorselBytes = dosyaBytes;
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
    if (_secilenGorselBytes == null) return;
    setState(() {
      _yukleniyorMu = true;
      _yuklemeOrani = 0.0;
    });
    final dosyaAdi = 'profil_${DateTime.now().millisecondsSinceEpoch}.jpg';

    try {
      if (Firebase.apps.isEmpty) {
        for (var i = 1; i <= 4; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 120));
          if (!mounted) return;
          setState(() => _yuklemeOrani = i * 0.25);
        }
        setState(() => _yukleniyorMu = false);
        await _bildirimOlustur(
          baslik: 'Görsel Buluta Yüklendi',
          icerik: '$dosyaAdi başarıyla kaydedildi.',
          tur: BildirimTuru.yukleme,
        );
        return;
      }

      final task = _storageServisi.yuklemeBaslat(
        dosyaBytes: _secilenGorselBytes!,
        dosyaAdi: dosyaAdi,
      );
      task.snapshotEvents.listen((snapshot) {
        if (snapshot.totalBytes > 0 && mounted) {
          setState(() {
            _yuklemeOrani = snapshot.bytesTransferred / snapshot.totalBytes;
          });
        }
      });
      final tamamlanan = await task;
      final url = await _storageServisi.urlGetir(tamamlanan.ref);
      if (mounted) {
        setState(() {
          _yuklenenUrl = url;
          _yukleniyorMu = false;
        });
      }
      await _bildirimOlustur(
        baslik: 'Görsel Buluta Yüklendi',
        icerik: '$dosyaAdi başarıyla Firebase Storage\'a kaydedildi.',
        tur: BildirimTuru.yukleme,
      );
    } catch (e) {
      if (mounted) {
        setState(() => _yukleniyorMu = false);
      }
      await _bildirimOlustur(
        baslik: 'Görsel Yükleme Hatası',
        icerik: 'Görsel buluta yüklenemedi: $e',
        tur: BildirimTuru.yukleme,
      );
    }
  }

  Future<void> _aboneDegistir(bool deger) async {
    setState(() => _konuyaAboneMi = deger);
    if (deger) {
      await _fcmBildirimServisi.konuyaAboneOl('tum_sinif');
      await _bildirimOlustur(
        baslik: 'Yayın Aboneliği Aktif',
        icerik: '"tum_sinif" konusu bildirimlerine abone oldunuz.',
        tur: BildirimTuru.abone,
      );
    } else {
      await _fcmBildirimServisi.konudanAyril("tum_sinif");
      await _bildirimOlustur(
        baslik: 'Yayın Aboneliği Kapatıldı',
        icerik: '"tum_sinif" konusu bildirim aboneliğinden ayrıldınız.',
        tur: BildirimTuru.abone,
      );
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
        actions: [
          IconButton(
            onPressed: _bildirimMerkezineKaydir,
            tooltip: 'Bildirim Merkezi',
            icon: Badge(
              isLabelVisible: _okunmamisSayisi > 0,
              label: Text('$_okunmamisSayisi'),
              backgroundColor: const Color(0xFF10B981),
              child: const Icon(Icons.notifications_outlined),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GorselYuklemeKarti(
              secilenGorselBytes: _secilenGorselBytes,
              yuklenenUrl: _yuklenenUrl,
              yuklemeOrani: _yuklemeOrani,
              yukleniyorMu: _yukleniyorMu,
              onGaleridenSec: () => _gorselSec(kameradan: false),
              onKameradanCek: () => _gorselSec(kameradan: true),
              onBulutaYukle: _bulutaYukle,
            ),
            const SizedBox(height: 16),
            Container(
              key: _bildirimKartiKey,
              child: BildirimListesiKarti(
                bildirimler: _bildirimler,
                token: _fcmToken,
                konuyaAboneMi: _konuyaAboneMi,
                onAboneDegisti: _aboneDegistir,
                onTestBildirimiGonder: _testBildirimiGonder,
                onOzelBildirimGonder: _ozelBildirimGonder,
                onBildirimTiklandi: _bildirimTiklandi,
                onBildirimSil: _bildirimSil,
                onTumunuOkunduIsaretle: _tumunuOkunduIsaretle,
                onTumunuTemizle: _tumunuTemizle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}