// Flutter'ın renk sınıfı (Color) için Material kütüphanesini içe aktarıyoruz
import 'package:flutter/material.dart';

// KPSS dersine ait tek bir alt konuyu temsil eden veri modeli
class Topic {
  // Konunun benzersiz kimliği (Örn: 'tr_01')
  final String id;

  // Konunun başlığı / adı (Örn: 'Sözcükte Anlam')
  final String title;

  // Topic kurucu (constructor) fonksiyonu; id ve title zorunludur
  Topic({
    required this.id,
    required this.title,
  });

  // JSON / Map verisinden Topic nesnesi üreten fabrika kurucusu (factory constructor)
  factory Topic.fromMap(Map<String, dynamic> map) {
    return Topic(
      // Haritadan id değerini alır; null gelirse boş metin atar
      id: map['id'] as String? ?? '',
      // Haritadan title değerini alır; null gelirse boş metin atar
      title: map['title'] as String? ?? '',
    );
  }

  // Topic nesnesini JSON / Map formatına dönüştüren metot
  Map<String, dynamic> toMap() {
    return {
      'id': id, // Konu kimliği
      'title': title, // Konu başlığı
    };
  }
}

// KPSS dersini (Türkçe, Matematik vb.) ve alt konularını temsil eden model sınıfı
class Course {
  // Dersin benzersiz kimliği (Örn: 'turkce')
  final String id;

  // Dersin adı (Örn: 'Türkçe')
  final String title;

  // Dersin kategorisi (Örn: 'Genel Yetenek' veya 'Genel Kültür')
  final String category;

  // Ders renginin 16'lık tabandaki tamsayı değeri (Hex color int)
  final int colorHex;

  // Ders için kullanılacak ikonun adı
  final String iconName;

  // KPSS sınavında bu dersten çıkan toplam soru sayısı (Örn: 30)
  final int questionCount;

  // Bu derse ait alt konuların listesi
  final List<Topic> topics;

  // Course kurucu fonksiyonu; tüm alanların verilmesi zorunludur
  Course({
    required this.id,
    required this.title,
    required this.category,
    required this.colorHex,
    required this.iconName,
    required this.questionCount,
    required this.topics,
  });

  // colorHex tamsayısını Flutter Color nesnesine dönüştüren yardımcı getter
  Color get color => Color(colorHex);

  // JSON veya Map nesnesinden Course modeli üreten fabrika kurucusu
  factory Course.fromMap(Map<String, dynamic> map) {
    // Ham 'topics' listesini alır; boş gelirse boş liste döner
    final topicsRaw = map['topics'] as List<dynamic>? ?? [];

    return Course(
      // Ders kimliği
      id: map['id'] as String? ?? '',
      // Ders adı
      title: map['title'] as String? ?? '',
      // Ders kategorisi (varsayılan: 'Genel Yetenek')
      category: map['category'] as String? ?? 'Genel Yetenek',
      // Renk kodunu int olarak ayrıştırır, hata durumunda varsayılan mavi rengi kullanır
      colorHex: int.tryParse(map['color']?.toString() ?? '0xFF2196F3') ?? 0xFF2196F3,
      // İkon adı (varsayılan: 'book')
      iconName: map['icon'] as String? ?? 'book',
      // Soru sayısı (varsayılan: 30)
      questionCount: map['questionCount'] as int? ?? 30,
      // Alt konular listesini Topic nesnelerine dönüştürür
      topics: topicsRaw.map((t) => Topic.fromMap(Map<String, dynamic>.from(t as Map))).toList(),
    );
  }

  // Course nesnesini JSON veya Map formatına dönüştüren metot
  Map<String, dynamic> toMap() {
    return {
      'id': id, // Ders kimliği
      'title': title, // Ders adı
      'category': category, // Kategori
      // Renk kodunu '0xFF...' formatında hex metne dönüştürür
      'color': '0x${colorHex.toRadixString(16).padLeft(8, '0').toUpperCase()}',
      'icon': iconName, // İkon adı
      'questionCount': questionCount, // Soru sayısı
      // Alt konuları da tek tek Map formatına çevirir
      'topics': topics.map((t) => t.toMap()).toList(),
    };
  }
}
