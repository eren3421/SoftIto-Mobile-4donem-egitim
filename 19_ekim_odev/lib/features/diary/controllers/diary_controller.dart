import 'package:flutter/foundation.dart';
import '../models/diary_model.dart';

/// Günlük iş mantığını ve durumunu yöneten controller sınıfı.
/// project.md ve SKILL.md kurallarına uygun olarak ValueNotifier ile reaktif durum yönetimi sağlar.
class DiaryController {
  final ValueNotifier<List<DiaryEntryModel>> entries =
      ValueNotifier<List<DiaryEntryModel>>(<DiaryEntryModel>[
    DiaryEntryModel(
      id: 'demo-entry-1',
      title: 'Defterime İlk Satırlar',
      content:
          'Eski bir sahaftan aldığım deri ciltli defterin kokusunu hatırlatan bu dijital sayfaya ilk notumu düşüyorum. Sakin bir sonbahar akşamı, sıcak kahvem ve aklımdan geçen dingin düşünceler...',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      mood: 'Huzurlu',
      isFavorite: true,
    ),
    DiaryEntryModel(
      id: 'demo-entry-2',
      title: 'Gece Fikirleri ve İlham',
      content:
          'Gece ilerledikçe zihnim daha da berraklaşıyor. Yeni projeler, yazılacak hikayeler ve yarın atılacak adımlar üzerine derin düşüncelere daldım.',
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      mood: 'Düşünceli',
      isFavorite: false,
    ),
  ]);

  final ValueNotifier<String> selectedMood = ValueNotifier<String>('Huzurlu');
  final ValueNotifier<DateTime?> selectedFilterDate =
      ValueNotifier<DateTime?>(null);
  final ValueNotifier<bool> onlyFavoritesFilter = ValueNotifier<bool>(false);

  void setMood(String mood) {
    selectedMood.value = mood;
  }

  void setFilterDate(DateTime? date) {
    selectedFilterDate.value = date;
  }

  void toggleFavoritesFilter() {
    onlyFavoritesFilter.value = !onlyFavoritesFilter.value;
  }

  void addEntry({
    required String title,
    required String content,
    String? mood,
  }) {
    final newEntry = DiaryEntryModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
      content: content.trim(),
      createdAt: DateTime.now(),
      mood: mood ?? selectedMood.value,
    );
    entries.value = <DiaryEntryModel>[newEntry, ...entries.value];
  }

  void toggleFavorite(String id) {
    entries.value = entries.value.map((entry) {
      if (entry.id == id) {
        return entry.copyWith(isFavorite: !entry.isFavorite);
      }
      return entry;
    }).toList();
  }

  void deleteEntry(String id) {
    entries.value = entries.value.where((entry) => entry.id != id).toList();
  }

  void dispose() {
    entries.dispose();
    selectedMood.dispose();
    selectedFilterDate.dispose();
    onlyFavoritesFilter.dispose();
  }
}
