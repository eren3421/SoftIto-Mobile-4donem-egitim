---
name: flutter-feature-scaffold
description: Dijital Günlük (Defterim) Flutter projesinde özellik (feature) bazlı yeni bir modül veya ekran açarken standart klasör yapısını, ValueNotifier tabanlı controller'ı, immutable veri modelini ve parçalı UI katmanlarını oluşturur.
---

# Flutter Feature Scaffold (Modüler Günlük Ekran İskeleti)

Bu yetenek, Dijital Günlük projesinde yeni bir ekran ya da işlev modülü (örneğin `diary`, `mood_tracker`, `calendar_archive`, `search`) açarken `project.md` içindeki Clean UI, gerçek defter teması ve reaktif `ValueNotifier` kurallarına tam uyulmasını garantiye alır.

## Temel Kurallar

1. **Asla Tek Dosyada Toplama:**
   Arayüz (`_view.dart`), alt bileşenler (`_card.dart` / `_widget.dart`), durum kontrolcüsü (`_controller.dart`) ve veri modeli (`_model.dart`) dosyaları mutlaka ayrı klasörlerde ve ayrı dosyalarda açılmalıdır.
2. **State Yönetimi:**
   Harici paket veya sayfa genelinde `setState` kullanılmaz. Reaktif durumlar için `ValueNotifier` ve `ValueListenableBuilder` kullanılmalıdır.
3. **Const ve 40 Satır Kuralı:**
   Mümkün olan tüm statik widget'larda `const` kullanılmalı ve `build` metotları 40 satırı aşmamalıdır.

## Adım Adım Uygulama Akışı

### Adım 1: Klasör Yapısını Oluşturma

Hedeflenen modül adını (örneğin `diary`) kullanarak `lib/features/<feature_name>` altında aşağıdaki klasör ve dosya yapısını kur:

```text
lib/features/<feature_name>/
├── controllers/
│   └── <feature_name>_controller.dart
├── models/
│   └── <feature_name>_model.dart
├── views/
│   └── <feature_name>_view.dart
└── widgets/
    └── <feature_name>_card.dart
```

### Adım 2: Model Dosyasını Oluşturma

`models/<feature_name>_model.dart` dosyasını tüm alanları `final`, kurucusu `const` ve `copyWith`, `fromJson`, `toJson` metotlarını içerecek şekilde `immutable` (değişmez) olarak tanımla:

```dart
class DiaryEntryModel {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final String mood;
  final bool isFavorite;

  const DiaryEntryModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.mood,
    this.isFavorite = false,
  });

  DiaryEntryModel copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    String? mood,
    bool? isFavorite,
  }) {
    return DiaryEntryModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      mood: mood ?? this.mood,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  factory DiaryEntryModel.fromJson(Map<String, dynamic> json) {
    return DiaryEntryModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      mood: json['mood'] as String? ?? 'Huzurlu',
      isFavorite: json['is_favorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'mood': mood,
      'is_favorite': isFavorite,
    };
  }
}
```

### Adım 3: Controller Dosyasını Yazma

`controllers/<feature_name>_controller.dart` içinde yalnızca `flutter/foundation.dart` kullanarak iş mantığını ve `ValueNotifier` tanımlarını oluştur. Bellek sızıntısını önlemek için `dispose()` metodunu mutlaka ekle:

```dart
import 'package:flutter/foundation.dart';
import '../models/diary_model.dart';

class DiaryController {
  final ValueNotifier<List<DiaryEntryModel>> entries =
      ValueNotifier<List<DiaryEntryModel>>(<DiaryEntryModel>[]);

  final ValueNotifier<String> selectedMood = ValueNotifier<String>('Huzurlu');

  void addEntry({
    required String title,
    required String content,
  }) {
    final newEntry = DiaryEntryModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      createdAt: DateTime.now(),
      mood: selectedMood.value,
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
    entries.value =
        entries.value.where((entry) => entry.id != id).toList();
  }

  void dispose() {
    entries.dispose();
    selectedMood.dispose();
  }
}
```

### Adım 4: Modüler Widget Dosyasını Oluşturma

`widgets/<feature_name>_card.dart` dosyasında `StatelessWidget` kullanarak defter sayfası görünümünü temsil eden tekrar kullanılabilir UI bileşenini oluştur:

```dart
import 'package:flutter/material.dart';
import '../models/diary_model.dart';

class DiaryCard extends StatelessWidget {
  final DiaryEntryModel entry;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onDelete;

  const DiaryCard({
    super.key,
    required this.entry,
    required this.onFavoriteToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateText =
        '${entry.createdAt.day}.${entry.createdAt.month}.${entry.createdAt.year}';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(dateText, style: theme.textTheme.labelMedium),
                Chip(label: Text(entry.mood)),
                IconButton(
                  onPressed: onFavoriteToggle,
                  icon: Icon(
                    entry.isFavorite ? Icons.bookmark : Icons.bookmark_border,
                  ),
                ),
              ],
            ),
            const Divider(),
            Text(entry.title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              entry.content,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
```

### Adım 5: View (Ana Ekran) Dosyasını Yazma

`views/<feature_name>_view.dart` dosyasında `ValueListenableBuilder` kullanarak UI katmanını oluştur ve `build` metodunu 40 satırın altında tut:

```dart
import 'package:flutter/material.dart';
import '../controllers/diary_controller.dart';
import '../models/diary_model.dart';
import '../widgets/diary_card.dart';

class DiaryView extends StatelessWidget {
  final DiaryController controller;

  const DiaryView({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Defterim'),
      ),
      body: ValueListenableBuilder<List<DiaryEntryModel>>(
        valueListenable: controller.entries,
        builder: (context, entryList, _) {
          if (entryList.isEmpty) {
            return const Center(
              child: Text('Henüz defterine bir sayfa eklemedin.'),
            );
          }
          return ListView.builder(
            itemCount: entryList.length,
            itemBuilder: (context, index) {
              final item = entryList[index];
              return DiaryCard(
                entry: item,
                onFavoriteToggle: () => controller.toggleFavorite(item.id),
                onDelete: () => controller.deleteEntry(item.id),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.addEntry(
          title: 'Yeni Günlük Sayfası',
          content: 'Bugün defterime ilk satırları yazıyorum...',
        ),
        child: const Icon(Icons.edit_note),
      ),
    );
  }
}
```
Bu örnek Flutter kodları sana nasıl yazman gerektiğini gösteren örnek bir şeme sen bunu diğer architecutre.md dosyasını baz alarak proje için özelleştir.
## Adım 6: Tamamlama ve Kalite Kontrol Listesi

Yeni modül oluşturulduktan sonra aşağıdaki maddelerin tamamlandığından emin ol:

* **Separation of Concerns (Sorumlulukların Ayrımı):** Arayüz dosyalarında iş mantığı, controller dosyasında ise UI/Widget kodu bulunmadığını doğrula.
* **Tema Uyumu:** Tüm renk ve metin stillerinin doğrudan `Theme.of(context)` veya `core/constants/app_colors.dart` üzerinden alındığını kontrol et.
* **Derleme ve Analiz:** `flutter analyze` komutunu çalıştırarak 0 hata ve 0 uyarı alındığını doğrula.

## Sıkça Sorulan Sorular (Kapsam Kuralları)

### Soru: Hangi durumlarda bu yeteneği kullanmalıyım?
**Cevap:** Projede sıfırdan yeni bir ekran veya özellik modülü (örneğin `diary`, `mood_tracker`, `favorites`, `settings`) oluştururken bu yeteneği kullanmalısın.

### Soru: Bu yeteneği hangi durumlarda KULLANMAMALIYIM?
**Cevap:** Mevcut bir ekranın tasarımını güncellerken, ufak bir hata düzeltmesi (bug fix) yaparken veya yalnızca mevcut bir modele yeni bir alan eklerken sıfırdan dosya iskeleti kuran bu yeteneği kullanmamalısın.
