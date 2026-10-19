# Reaktif Durum Yönetimi ve Mimari Akış Referansı (State Flow Reference)

Bu kılavuz, **Susadım** projesindeki tüm özellik (feature) modüllerinde uygulanması zorunlu olan **Clean Architecture**, reaktif durum yönetimi (**ValueNotifier**) ve bileşen yaşam döngüsü kurallarını detaylandırır.

---

## 1. Mimari Prensipler ve Altın Kurallar

1. **Çekirdek API Önceliği (Zero Heavy Dependencies):**
   - Projede Bloc, Riverpod, MobX veya Redux gibi harici ağır state kütüphaneleri kullanılmaz.
   - Flutter'ın yerel `ValueNotifier<T>` ve `ValueListenableBuilder<T>` sınıfları ile reaktif, hafif ve yüksek performanslı durum yönetimi sağlanır.
2. **Sayfa Düzeyinde `setState` Yasağı (Red Line):**
   - Ekranın tamamını yeniden çizen (rebuild) ağır `setState()` çağrıları kesinlikle yasaktır.
   - `setState` yalnızca yerel widget animasyonları veya salt lokal UI mikro geçişleri için ve strictly izole edilmiş küçük `StatefulWidget`'larda kabul edilir.
3. **Seçici ve Atomik Çizim (Atomic Rebuilding):**
   - Yalnızca değeri değişen durumları dinleyen `ValueListenableBuilder` alanları yeniden çizilir; ekranın geri kalanı statik ve `const` olarak kalır.
4. **Bellek Sızıntısı Koruması (Dispose Guarantee):**
   - Controller içerisinde açılan tüm `ValueNotifier` nesneleri, ekran kapatıldığında (dispose edildiğinde) controller'ın `dispose()` metodu aracılığıyla mutlaka serbest bırakılmalıdır.
5. **Modüler Build Sınırı (Max 40 Satır Kuralı):**
   - Herhangi bir widget'ın `build()` metodu 40 satırı geçemez. Aşan yapılar bağımsız widget sınıflarına veya özel yardımcı metotlara parçalanmalıdır.
6. **Statik Widget'larda `const` Zorunluluğu:**
   - Değişmeyen tüm widget düğümlerinde `const` tanımlayıcısı zorunludur.

---

## 2. Reaktif Durum Akış Şeması (Data & State Flow)

```text
┌────────────────────────────────────────────────────────────────────────┐
│                        KULLANICI ETKİLEŞİMİ                            │
│                 (Buton Tıklaması / Input / Event)                      │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                     VIEW (KULLANICI ARAYÜZÜ)                           │
│  - Widget üzerinden controller metodu tetiklenir:                      │
│    `widget.controller.addWater(250)` veya `controller.logWorkout(...)` │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                  CONTROLLER (İŞ MANTIĞI & STATE)                       │
│  1. Doğrulama ve iş kuralı işletilir (Validation & Logic)               │
│  2. Yeni veri modeli üretilir (Immutable Model)                        │
│  3. Notifier güncellenir:                                              │
│     `currentWater.value += amount`                                     │
│     `logs.value = [newLog, ...logs.value]`                             │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
                                    ▼ (Reaktif Bildirim / Notification)
┌────────────────────────────────────────────────────────────────────────┐
│                   VALUELISTENABLEBUILDER<T>                            │
│  - Yalnızca ilgili `ValueListenable` dinleyicisi tetiklenir            │
│  - Ekranın tamamı değil, sadece builder bloğu yeniden çizilir          │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                    HEDEF ATOMİK WIDGET (UI)                            │
│  - Örn: `WaterGaugeCard(currentMl: current)`                           │
│  - `AppColors` ve `AppTheme` ile uyumlu son güncel durumu render eder  │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Katman Sorumlulukları ve Kodlama Standartları

Her feature klasörü (`lib/features/<feature_name>/`) 4 temel katmana ayrılır:

### A. Model Katmanı (`models/<feature_name>_model.dart`)
- **Değişmezlik (Immutability):** Sınıf içindeki tüm alanlar `final` olmalıdır.
- **Const Constructor:** Mümkün olan her yerde `const` yapıcı tanımlanmalıdır.
- **copyWith Metodu:** Nesne durumunun güvenli kopyalanması için `copyWith` bulunmalıdır.
- **JSON Serileştirme:** `toJson()` ve `factory fromJson()` metotları eksiksiz olmalıdır.

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

  WaterLog copyWith({String? id, int? amountMl, DateTime? timestamp}) {
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

### B. Controller Katmanı (`controllers/<feature_name>_controller.dart`)
- **UI Bağımsızlığı:** Controller asla `BuildContext`, `Widget` veya Flutter UI paketlerine bağımlı olmamalıdır (`package:flutter/foundation.dart` yeterlidir).
- **Durum Tanımı:** Her reaktif veri `final ValueNotifier<T>` olarak tanımlanır.
- **Türetilmiş Durumlar (Computed Properties):** Getter metotlarıyla hesaplanır (`progressRatio`, `isGoalReached`).
- **Dispose Metodu:** Controller'ın tüm notifier'ları serbest bırakan `dispose()` metodu bulunmalıdır.

```dart
import 'package:flutter/foundation.dart';
import '../models/water_log_model.dart';

class WaterTrackerController {
  final ValueNotifier<int> currentWater = ValueNotifier<int>(0);
  final ValueNotifier<List<WaterLog>> logs = ValueNotifier<List<WaterLog>>([]);
  final int dailyGoalMl = 2500;

  double get progressRatio => (currentWater.value / dailyGoalMl).clamp(0.0, 1.0);
  bool get isGoalCompleted => currentWater.value >= dailyGoalMl;

  void addWater(int amountMl) {
    if (amountMl <= 0) return;
    currentWater.value += amountMl;
    final log = WaterLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amountMl: amountMl,
      timestamp: DateTime.now(),
    );
    // Koleksiyon güncellemesinde yeni referans atanmalıdır:
    logs.value = [log, ...logs.value];
  }

  void resetWater() {
    currentWater.value = 0;
    logs.value = [];
  }

  void dispose() {
    currentWater.dispose();
    logs.dispose();
  }
}
```

### C. View Katmanı (`views/<feature_name>_view.dart`)
- **Lifecycle Yönetimi:** Controller view seviyesinde yönetiliyorsa `StatefulWidget`'ın `initState` ve `dispose` fonksiyonları ile bağlanır. Eğer dışarıdan parametre olarak alınıyorsa `dispose` sorumluluğu üst katmana aittir.
- **Seçici Dinleme:** `ValueListenableBuilder` yalnızca dinamik veriyi kullanan widget'ı sarar; sayfa iskeletini (Scaffold/AppBar) sarmaz.
- **Alt Bölüm Parçalama:** Sayfa yapısı modüler alt metotlara veya alt widget sınıflarına ayrılır.

```dart
import 'package:flutter/material.dart';
import '../controllers/water_tracker_controller.dart';
import '../models/water_log_model.dart';
import '../widgets/water_gauge_card.dart';
import '../widgets/water_history_list.dart';

class WaterTrackerView extends StatefulWidget {
  final WaterTrackerController controller;

  const WaterTrackerView({super.key, required this.controller});

  @override
  State<WaterTrackerView> createState() => _WaterTrackerViewState();
}

class _WaterTrackerViewState extends State<WaterTrackerView> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildGaugeSection(),
          const SizedBox(height: 20),
          _buildHistorySection(),
        ],
      ),
    );
  }

  Widget _buildGaugeSection() {
    return ValueListenableBuilder<int>(
      valueListenable: widget.controller.currentWater,
      builder: (context, current, _) {
        return WaterGaugeCard(
          currentMl: current,
          goalMl: widget.controller.dailyGoalMl,
        );
      },
    );
  }

  Widget _buildHistorySection() {
    return ValueListenableBuilder<List<WaterLog>>(
      valueListenable: widget.controller.logs,
      builder: (context, logs, _) {
        return WaterHistoryList(logs: logs);
      },
    );
  }
}
```

### D. Widget Katmanı (`widgets/<feature_name>_widget.dart`)
- **Tema Entegrasyonu:** Renkler doğrudan hardcoded verilmez; `AppColors` sabitleri ve `Theme.of(context)` kullanılır.
- **Maksimum 40 Satır Kuralı:** Karmaşık UI parçaları alt widget'lara veya `_buildHeader()`, `_buildBody()` gibi odaklı fonksiyonlara ayrılır.
- **Geri Çağrımlar (Callbacks):** Widget'lar iş mantığını doğrudan yürütmez; eylemleri `VoidCallback` veya `ValueChanged<T>` aracılığıyla üst bileşene iletir.

---

## 4. İleri Düzey Reaktif Senaryolar

### A. Koleksiyon ve Liste Güncellemeleri
`ValueNotifier<List<T>>` kullanırken, listenin içine doğrudan `.add(item)` veya `.remove(item)` çağrısı yapmak dinleyicileri tetiklemez, çünkü listenin bellek referansı değişmez!
- **Yanlış (Tetiklenmez):**
  ```dart
  logs.value.add(newLog); // Bildirim gitmez!
  ```
- **Doğru (Reaktif ve Güvenli):**
  ```dart
  logs.value = [newLog, ...logs.value]; // Yeni referans, bildirim tetiklenir!
  ```

### B. Çoklu Durum Dinleme (`Listenable.merge`)
Bir bileşen birden fazla `ValueNotifier`'a aynı anda bağımlıysa `Listenable.merge` veya iç içe minimal `ValueListenableBuilder` kullanılabilir:
```dart
ListenableBuilder(
  listenable: Listenable.merge([controller.currentWater, controller.logs]),
  builder: (context, _) {
    return Text('Kayıt: ${controller.logs.value.length}');
  },
)
```

---

## 5. Çift Tema (Dual Theme) ve Tasarım Dili Standartları

Susadım uygulamasında Material 3 ve iki aktif tema bulunur:
- **Koyu Tema (Dark Obsidian & Neon):**
  - Arka Plan: `AppColors.darkBackground` (`#0A0D14`)
  - Kart/Yüzey: `AppColors.darkSurfaceCard` (`#182030`)
  - Vurgular: `AppColors.neonCyanBright` (`#00F0FF`), `AppColors.neonLimeBright` (`#4EFE1E`)
- **Aydınlık Tema (Soft Arctic & Crisp Slate):**
  - Arka Plan: `AppColors.lightBackground` (`#F6F8FC`)
  - Kart/Yüzey: `AppColors.lightSurfaceCard` (`#FFFFFF`)
  - Vurgular: `AppColors.neonCyan` (`#00B4D8`), `AppColors.neonLime` (`#10B981`)

### Tema Duyarlı Renk Seçimi Örneği:
```dart
final isDark = Theme.of(context).brightness == Brightness.dark;
final accentColor = isDark ? AppColors.neonCyanBright : AppColors.neonCyan;
final surfaceColor = isDark ? AppColors.darkSurfaceCard : AppColors.lightSurfaceCard;
```

---

## 6. Kalite Kontrol ve Doğrulama Adımları

Geliştirilen her yeni özellik ve değişiklik aşağıdaki adımlarla doğrulanmalıdır:

1. **Statik Kod Analizi (0 Hata & 0 Uyarı):**
   ```bash
   flutter analyze
   ```
2. **Birim ve Widget Testleri:**
   ```bash
   flutter test
   ```
3. **Bellek ve Yaşam Döngüsü Kontrolü:**
   - Sayfa kapatıldığında controller'ın `dispose()` çağrısının yapıldığı teyit edilmelidir.
