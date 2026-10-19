---
name: flutter-feature-scaffold
description: Flutter projelerinde feature bazlı modüler yapı, Clean UI ve ValueNotifier state yönetimi oluşturur.
---

# Flutter Feature Scaffold (Modüler Ekran İskeleti)

Bu yetenek projede yeni bir ekran ya da işlev açarken Clean UI ve reaktif state kurallarına tam uyulmasını garantiye alır.

## Temel Kurallar
1. **Asla tek dosyada toplama:**
   - UI (`_view.dart`), State Controller (`_controller.dart`), Model (`_model.dart`) ve bileşen (`_card.dart` / widgets) dosyaları ayrı ayrı açılmalıdır.
2. **State Yönetimi:**
   - Basit ve reaktif durumlar için Flutter'ın çekirdek `ValueNotifier` ve `ValueListenableBuilder` API'leri kullanılmalıdır. Ağır üçüncü parti paketler izinsiz eklenmez.
3. **Const ve UI Standartları:**
   - Mümkün olan tüm statik widget'larda `const` zorunludur.
   - Renk ve metin stilleri tema dosyalarından (`app_colors.dart`, `app_theme.dart`) alınmalıdır.
   - 40 satırı geçen `build` metotları alt widget'lara parçalanmalıdır.

## Klasör Yapısı Standartı
```text
lib/features/<feature_name>/
  ├── controllers/<feature_name>_controller.dart
  ├── models/<feature_name>_model.dart
  ├── views/<feature_name>_view.dart
  └── widgets/<feature_name>_widget.dart
```

## Adım Adım Uygulama Akışı

### Adım 1: Controller Dosyasını Yaz
`controllers/<feature_name>_controller.dart` içinde iş mantığını ve `ValueNotifier` durumlarını tanımla:
```dart
import 'package:flutter/foundation.dart';

class WaterTrackerController {
  final ValueNotifier<int> currentWater = ValueNotifier<int>(0);
  final int dailyGoalWater = 2500;

  void addWater(int amount) {
    currentWater.value += amount;
  }

  void resetWater() {
    currentWater.value = 0;
  }

  void dispose() {
    currentWater.dispose();
  }
}
```

### Adım 2: Model Dosyasını Oluşturma
`models/<feature_name>_model.dart` içinde `immutable` sınıf tanımla:
```dart
class WaterLog {
  final String id;
  final int amountMl;
  final DateTime timestamp;

  const WaterLog({
    required this.id,
    required this.amountMl,
    required this.timestamp,
  });

  WaterLog copyWith({
    String? id,
    int? amountMl,
    DateTime? timestamp,
  }) {
    return WaterLog(
      id: id ?? this.id,
      amountMl: amountMl ?? this.amountMl,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'amountMl': amountMl,
    'timestamp': timestamp.toIso8601String(),
  };

  factory WaterLog.fromJson(Map<String, dynamic> json) => WaterLog(
    id: json['id'] as String,
    amountMl: json['amountMl'] as int,
    timestamp: DateTime.parse(json['timestamp'] as String),
  );
}
```

### Adım 3: View Dosyasını Yaz
`views/<feature_name>_view.dart` dosyasında `StatelessWidget` veya hafif `StatefulWidget` (controller yaşam döngüsü için) ile `ValueListenableBuilder` kullan:
```dart
import 'package:flutter/material.dart';
import '../controllers/water_tracker_controller.dart';
import '../widgets/water_progress_card.dart';

class WaterTrackerView extends StatefulWidget {
  const WaterTrackerView({super.key});

  @override
  State<WaterTrackerView> createState() => _WaterTrackerViewState();
}

class _WaterTrackerViewState extends State<WaterTrackerView> {
  late final WaterTrackerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WaterTrackerController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Susadım')),
      body: ValueListenableBuilder<int>(
        valueListenable: _controller.currentWater,
        builder: (context, current, _) {
          return WaterProgressCard(
            currentWater: current,
            goalWater: _controller.dailyGoalWater,
            onAdd: () => _controller.addWater(250),
            onReset: _controller.resetWater,
          );
        },
      ),
    );
  }
}
```

### Adım 4: Widget Dosyasını Oluşturma
`widgets/<feature_name>_widget.dart` içinde odaklanmış, `const` destekli modüler widget'lar yaz.

## Otomasyon ve Yardımcı Araçlar

Yeni bir özellik eklerken elle dosya oluşturmak yerine `scripts/generate_feature.sh` betiği kullanılabilir:
```bash
./.agents/skills/flutter-feature-scaffold/scripts/generate_feature.sh <feature_name>
```
Bu betik Controller, Model, View ve Widget dosyalarını Clean UI ve `ValueNotifier` standartlarına uygun şablonlarla otomatik üretir.

## Ek Kaynaklar ve Referanslar

- [state_flow.md](file:///Users/d1-4/Desktop/19ekim3/.agents/skills/flutter-feature-scaffold/references/state_flow.md): Reaktif durum akışı, bellek yönetimi ve çift tema kuralları detaylı referans dokümanı.
- [sample_screen.dart](file:///Users/d1-4/Desktop/19ekim3/.agents/skills/flutter-feature-scaffold/examples/sample_screen.dart): Proje standartlarına uygun örnek görünüm dosyası.
- [sample_controller.dart](file:///Users/d1-4/Desktop/19ekim3/.agents/skills/flutter-feature-scaffold/examples/sample_controller.dart): Örnek ValueNotifier durum denetleyicisi.
- [sample_model.dart](file:///Users/d1-4/Desktop/19ekim3/.agents/skills/flutter-feature-scaffold/examples/sample_model.dart): Değişmez (immutable) veri modeli.
- [sample_card_widget.dart](file:///Users/d1-4/Desktop/19ekim3/.agents/skills/flutter-feature-scaffold/examples/sample_card_widget.dart): Çift tema uyumlu modüler kart bileşeni.

## Kalite Kontrol
1. `flutter analyze` ile 0 hata/0 uyarı.
2. `flutter test` ile doğrula.

