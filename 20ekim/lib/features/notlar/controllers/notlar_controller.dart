import 'package:flutter/foundation.dart';
import '../models/not_model.dart';

/// Girişimcinin notlarını, raporlarını ve fikirlerini yöneten kontrolcü.
/// Sadece flutter/foundation.dart kullanır ve ValueNotifier tabanlıdır.
class NotlarController {
  final ValueNotifier<List<NotModel>> notes =
      ValueNotifier<List<NotModel>>(<NotModel>[
    NotModel(
      id: 'not_1',
      title: 'Yatırımcı Sunumu (Pitch Deck) Stratejisi',
      content:
          '1. Problem Tanımı: KOBİ’lerin nakit akışı ve kaynak takibindeki aksaklıklar.\n2. Çözüm: Asistan yapay zeka destekli defter ve portföy kontrolü.\n3. Pazar Büyüklüğü: TAM 1.2 Milyar Dolar.\n4. Gelir Modeli: Aylık abonelik (SaaS) ve işlem komisyonu.',
      category: 'Rapor',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      isFavorite: true,
      isPinned: true,
    ),
    NotModel(
      id: 'not_2',
      title: 'Q4 Ürün Yol Haritası & MVP Lansmanı',
      content:
          '• Bütçe modülü testlerinin tamamlanması.\n• Müşteri geri bildirim paneli entegrasyonu.\n• Mobil bildirim altyapısının test edilmesi.\n• Lansman öncesi 100 beta kullanıcısı ile görüşme.',
      category: 'Yol Haritası',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      isFavorite: false,
      isPinned: true,
    ),
    NotModel(
      id: 'not_3',
      title: 'Kurucu Ortaklar Toplantı Tutanakları',
      content:
          'Hisse dağılım sözleşmesi revize edildi. Bir sonraki sprint için görev dağılımı: Backend mimarisi ve güvenlik standartları öncelikli hale getirildi.',
      category: 'Toplantı',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      isFavorite: true,
      isPinned: false,
    ),
    NotModel(
      id: 'not_4',
      title: 'Yeni Büyüme Fikri: B2B Ortaklık Programı',
      content:
          'Kuluçka merkezleri ve teknokentlerle toplu lisanslama görüşmeleri yapılması planlanıyor.',
      category: 'Fikir',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      isFavorite: false,
      isPinned: false,
    ),
  ]);

  final ValueNotifier<String> selectedCategory =
      ValueNotifier<String>('Tümü');

  final ValueNotifier<String> searchQuery = ValueNotifier<String>('');

  List<NotModel> get filteredNotes {
    final query = searchQuery.value.trim().toLowerCase();
    final cat = selectedCategory.value;

    return notes.value.where((n) {
      final matchesCategory = cat == 'Tümü' || n.category == cat;
      final matchesQuery = query.isEmpty ||
          n.title.toLowerCase().contains(query) ||
          n.content.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList()
      ..sort((a, b) {
        if (a.isPinned != b.isPinned) {
          return a.isPinned ? -1 : 1;
        }
        return b.createdAt.compareTo(a.createdAt);
      });
  }

  void addNote({
    required String title,
    required String content,
    required String category,
    String? projectId,
  }) {
    final newNote = NotModel(
      id: 'not_${DateTime.now().millisecondsSinceEpoch}',
      projectId: projectId,
      title: title,
      content: content,
      category: category,
      createdAt: DateTime.now(),
      isFavorite: false,
      isPinned: false,
    );
    notes.value = <NotModel>[newNote, ...notes.value];
  }

  void toggleFavorite(String id) {
    notes.value = notes.value.map((n) {
      if (n.id == id) {
        return n.copyWith(isFavorite: !n.isFavorite);
      }
      return n;
    }).toList();
  }

  void togglePin(String id) {
    notes.value = notes.value.map((n) {
      if (n.id == id) {
        return n.copyWith(isPinned: !n.isPinned);
      }
      return n;
    }).toList();
  }

  void deleteNote(String id) {
    notes.value = notes.value.where((n) => n.id != id).toList();
  }

  void setCategory(String category) {
    selectedCategory.value = category;
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  void dispose() {
    notes.dispose();
    selectedCategory.dispose();
    searchQuery.dispose();
  }
}
