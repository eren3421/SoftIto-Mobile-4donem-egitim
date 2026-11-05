import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class StorageServisi {
  FirebaseStorage get _storage => FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  static const MethodChannel _kameraKanali = MethodChannel('softito/camera');

  Future<File?> gorselSec({bool kameradan = false}) async {
    if (kameradan && Platform.isMacOS) {
      final String? dosyaYolu = await _kameraKanali.invokeMethod<String>(
        'takePhoto',
      );
      if (dosyaYolu == null) return null;
      return File(dosyaYolu);
    }

    final XFile? xFile = await _picker.pickImage(
      source: kameradan ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1200,
    );
    if (xFile == null) return null;
    return File(xFile.path);
  }

  UploadTask yuklemeBaslat({
    required File dosya,
    required String dosyaAdi,
    String klasor = 'yuklemeler',
  }) {
    final Reference ref = _storage.ref().child('$klasor/$dosyaAdi');
    final metadata = SettableMetadata(
      contentType: 'image/png',
      customMetadata: {'ekleyen': 'Berat'},
    );
    return ref.putFile(dosya, metadata);
  }

  Future<String> urlGetir(Reference ref) async {
    return await ref.getDownloadURL();
  }

  Future<void> dosyaSil(String dosyaYolu) async {
    final Reference ref = _storage.ref().child(dosyaYolu);
    await ref.delete();
  }
}