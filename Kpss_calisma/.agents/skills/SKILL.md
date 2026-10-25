---
name: kpss-flutter-developer
description: KPSS Çalışma Koçu Flutter projesi için çevrimdışı (Hive) mimari, KPSS iş mantığı (net hesaplama), fl_chart grafik standartları ve UI/UX kurallarını içeren geliştirme kılavuzu.
---

# KPSS Çalışma Koçu - Geliştirme Kuralları (SKILL.md)

Bu projede kod üretirken, dosya oluştururken veya hata ayıklarken aşağıdaki kurallara **kesinlikle** uyulmalıdır:

## 1. Mimari ve Veri Saklama Kuralları (Hive & JSON)
- **Sıfır Backend:** Projede hiçbir HTTP isteği veya dış API kullanılmayacaktır. Tüm veriler cihazda yerel olarak tutulur.
- **TypeAdapter Karmaşasından Kaçınma:** Geliştirme hızını artırmak ve `build_runner` hatalarını önlemek için Hive modellerinde `toMap()` ve `fromMap(Map<dynamic, dynamic> map)` metotlarını kullan. Verileri Hive kutularına JSON uyumlu `Map<String, dynamic>` olarak kaydet ve okurken modele dönüştür.
- **Müfredat Okuma:** `assets/kpss_topics.json` dosyası uygulama açılışında `rootBundle.loadString` ile okunmalı, kullanıcının konu durumları (`Bitirdim: 2`, `Tekrar Edilecek: 1`, `Çalışılmadı: 0`) ise `topic_status_box` üzerinden `topic_id` eşleştirmesiyle birleştirilmelidir.

## 2. KPSS İş Mantığı (Business Logic) Kuralları
- **4 Yanlış 1 Doğruyu Götürür:** Tüm soru ve deneme hesaplamalarında net formülü standarttır: `double calculateNet(int correct, int wrong) => correct - (wrong / 4.0);`
- **Başarı Yüzdesi Hesabı:** Boş bırakılan sorular toplam soru sayısına dahildir, ancak başarı yüzdesi hesaplanırken `(Doğru Sayısı / (Doğru + Yanlış + Boş)) * 100` formülü kullanılır. Sıfıra bölünme (`DivisionByZero`) hatasını her zaman kontrol et (`total == 0 ? 0.0 : ...`).
- **Tarih Filtreleme:** Günlük soru hedefleri ve haftalık grafikler hesaplanırken `DateTime` karşılaştırmalarında saat/dakika farklarını yok saymak için tarihleri normalize et: `DateTime(date.year, date.month, date.day)`.

## 3. Sayaç (Pomodoro & Kronometre) Kuralları
- **Durum Koruma:** Kullanıcı sayaç çalışırken sekmeler arasında geçiş yaptığında (`BottomNavigationBar`) sayacın sıfırlanmaması için sayaç durumu **global bir Provider/Notifier** içinde veya `IndexedStack` kullanılarak korunmalıdır.
- **Süre Kaydı:** Sayaç tamamlandığında veya kullanıcı "Bitir ve Kaydet" butonuna bastığında, otomatik olarak ders seçimi yaptıran bir `AlertDialog` açılmalı ve seçilen derse çalışma süresi (`StudySession`) kaydedilmelidir.

## 4. Grafik (`fl_chart`) ve UI Kuralları
- **Boş Veri Durumu (Empty State):** Kullanıcı henüz hiç soru çözmemişse veya veri yoksa `fl_chart` widget'ları çökmemelidir. Veri listesi boşsa grafik yerine şık bir "Henüz veri girişi yapılmadı. İlk soru kaydını ekle!" bilgi kartı gösterilmelidir.
- **Responsive ve Temiz UI:**
  - Material 3 (`useMaterial3: true`) tasarım dilini kullan.
  - Her ders için sabit bir renk kodu ata (Türkçe: Mavi `0xFF2196F3`, Matematik: Mor `0xFF9C27B0`, Tarih: Turuncu `0xFFFF9800`, Coğrafya: Yeşil `0xFF4CAF50`, Vatandaşlık: Kırmızı `0xFFF44336`) ve hem konu listesinde hem de grafiklerde bu renk tutarlılığını koru.
  - Sayı giriş alanlarında (`Doğru`, `Yanlış`, `Boş`) sadece rakam girilebilmesi için `keyboardType: TextInputType.number` ve `FilteringTextInputFormatter.digitsOnly` kullan.

## 5. Kod Yazım Standartları
- Tek bir dosyada 300 satırdan fazla kod biriktirme; büyük ekranları mantıksal alt widget'lara (`widgets/` klasörü altında) böl.
- Tüm kullanıcı arayüzü metinleri **Türkçe**, değişken, fonksiyon ve sınıf isimlendirmeleri **İngilizce** (`camelCase` / `PascalCase`) olmalıdır.
- Yeni bir özellik eklerken önce `models/`, sonra `services/` veya `providers/`, en son `features/` (UI) katmanını kodla.
