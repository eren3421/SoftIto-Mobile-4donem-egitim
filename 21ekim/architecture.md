# Bahçıvan — Sistem ve Yazılım Mimarisi (ARCHITECTURE.md)

## 1. Mimari Genel Bakış
Bu doküman, **Bahçecilik ve Sera Yönetimi (Bahçıvan)** uygulamasının Antigravity ortamında hızlı, hatasız ve modüler biçimde geliştirilmesi için gereken klasör yapısını, veri şemalarını, durum yönetimi (state management) akışını ve çekirdek algoritmaları tanımlar.

- **Mimari Desen:** Bileşen Tabanlı Tek Sayfa Uygulaması (Modular SPA — Vanilla JS ES6 Modülleri veya React + Tailwind CSS ile doğrudan uygulanabilir).
- **Veri Kalıcılığı (Persistence):** Tarayıcı tabanlı `StorageService` (`localStorage` üzerinde JSON serileştirme) ve ilk açılışta otomatik yüklenen zengin `SeedData` (Hazır Bitki Türü Rehberi + Zararlı/Hastalık Teşhis Veritabanı).
- **Dil Desteği:** Sağ menüdeki `TR | EN` anahtarına bağlı reaktif `I18nService`.

## 2. Proje Klasör ve Dosya Yapısı

```
bahcivan-app/
├── index.html                      # Ana uygulama kabuğu (App Shell)
├── styles/
│   └── main.css                    # Tailwind CSS / Özel tema değişkenleri ve renkli kart stilleri
├── src/
│   ├── app.js                      # Uygulama başlangıç noktası ve Router başlatıcı
│   ├── state/
│   │   ├── store.js                # Merkezi State + LocalStorage senkronizasyonu
│   │   └── seedData.js             # Hazır Bitki Katalogları, Hastalık Rehberi ve Örnek Sera verisi
│   ├── i18n/
│   │   └── translations.js         # Türkçe (TR) ve İngilizce (EN) metin sözlüğü
│   ├── utils/
│   │   ├── careCalculator.js       # Renkli uyarı kartları (Kırmızı/Sarı/Yeşil) hesaplama motoru
│   │   ├── harvestCounter.js       # Ekimden hasada tahmini gün sayacı ve evre hesaplayıcı
│   │   └── pestMatcher.js          # Belirti (semptom) bazlı hastalık ve zararlı teşhis filtresi
│   ├── components/
│   │   ├── RightActionSidebar.js   # Eskizdeki sağ dikey menü (Not, Yardım, TR/EN, Takvim, Çıkış)
│   │   ├── CareAlertCard.js        # Sulama, Gübreleme, Budama renkli uyarı kartı bileşeni
│   │   ├── HarvestCountdownBar.js  # Ekimden hasada gün sayacı ve büyüme evresi bileşeni
│   │   ├── PlantCareGuideCard.js   # Bitki türüne göre sulama ve güneş ihtiyacı rehber kartı
│   │   ├── PestDiagnosisPanel.js   # Zararlı böcek ve hastalık belirtisi teşhis rehberi bileşeni
│   │   └── Modals.js               # Sera Ekle, Bitki Ekle, Not Ekle, Yardım (3 Kart) ve Silme Onay modalları
│   └── pages/
│       ├── AuthPages.js            # Giriş Yap, Kayıt Oluştur, Şifre Değiştir (E-posta), Yeni Şifre Gir
│       ├── GreenhouseListPage.js   # BAHÇELER ana ekranı (Sera listesi + Sera Ekle)
│       ├── GreenhouseDetailPage.js # Sera Adı ekranı (Bitki listesi + Bitki Ekle + Ana Menü)
│       ├── PlantDetailPage.js      # Eksik olan Bitki Detayları sayfası (4 ana özellik entegre)
│       └── CalendarAndLogsPage.js  # Bakım Takvimi, Hatırlatıcılar ve Hasat/Verim Günlüğü
├── PROJECT.md
├── DESIGN.md
├── ARCHITECTURE.md
└── SKILL.md
```

## 3. Veri Modelleri ve Şemalar (Data Schemas)

### 3.1. Bitki Türü İhtiyaç Profili Şeması (`PlantSpeciesProfile`)
Uygulama içinde bitki türüne göre sulama, güneş ve hasat bilgilerini otomatik getiren katalog şeması:

```json
{
  "speciesId": "tomato",
  "name": { "tr": "Domates", "en": "Tomato" },
  "scientificName": "Solanum lycopersicum",
  "category": { "tr": "Sebze / Meyve", "en": "Vegetable / Fruit" },
  "wateringIntervalDays": 3,
  "wateringAmountMl": 450,
  "wateringTip": {
    "tr": "Toprak yüzeyi kurudukça kök bölgesine su verin; yaprakları ıslatmaktan kaçının.",
    "en": "Water at the root zone when topsoil dries; avoid wetting leaves."
  },
  "fertilizingIntervalDays": 14,
  "fertilizingTip": {
    "tr": "Çiçeklenme öncesi azot, meyve tutumunda potasyum ve kalsiyum ağırlıklı gübre verin.",
    "en": "Use nitrogen-rich fertilizer before flowering, potassium and calcium during fruiting."
  },
  "pruningIntervalDays": 21,
  "pruningTip": {
    "tr": "Ana gövde ile yan dal arasındaki koltuk sürgünlerini düzenli temizleyin.",
    "en": "Regularly pinch off suckers between the main stem and side branches."
  },
  "sunlightHours": "6 - 8 Saat / Gün",
  "sunlightType": { "tr": "Doğrudan Güneş Işığı", "en": "Direct Sunlight" },
  "idealTempRange": "20°C - 27°C",
  "idealHumidity": "%60 - %70",
  "expectedHarvestDays": 70
}
```

### 3.2. Sera ve Bitki Kayıt Şeması (`Greenhouse` & `PlantInstance`)

```json
{
  "greenhouses": [
    {
      "id": "gh_01",
      "name": "Kışlık Domates ve Biber Serası",
      "photoUrl": "assets/greenhouse-default.jpg",
      "createdAt": "2026-09-20T10:00:00Z"
    }
  ],
  "plants": [
    {
      "id": "plt_101",
      "greenhouseId": "gh_01",
      "speciesId": "tomato",
      "customName": "Pembe Domates #1",
      "plantedAt": "2026-09-25",
      "lastWateredAt": "2026-10-17",
      "lastFertilizedAt": "2026-10-07",
      "lastPrunedAt": "2026-10-12",
      "customIntervals": null,
      "activeIssueIds": [],
      "createdAt": "2026-09-25T09:00:00Z"
    }
  ],
  "notesAndHarvests": [
    {
      "id": "log_501",
      "greenhouseId": "gh_01",
      "plantId": "plt_101",
      "type": "harvest",
      "title": "İlk Salkım Hasadı",
      "content": "İlk salkımdan 4 adet olgun domates toplandı.",
      "harvestAmountGrams": 620,
      "qualityRating": 5,
      "createdAt": "2026-10-21T14:30:00Z"
    }
  ]
}
```

### 3.3. Zararlı Böcek ve Hastalık Belirtisi Teşhis Şeması (`PestDiseaseCatalog`)

```json
{
  "id": "diag_whitefly",
  "name": { "tr": "Beyaz Sinek (Aleyrodidae)", "en": "Whitefly" },
  "category": "pest",
  "severity": "high",
  "symptoms": [
    "yaprak_sararmasi",
    "yaprak_altinda_beyaz_bocekler",
    "yapiskan_yaprak_yuzeyi"
  ],
  "symptomLabels": {
    "tr": ["Yapraklarda sararma", "Yaprak altında küçük beyaz sinekler", "Yapışkan tatlımsı tabaka"],
    "en": ["Yellowing leaves", "Tiny white insects under leaves", "Sticky honeydew residue"]
  },
  "diagnosisSummary": {
    "tr": "Bitki özsuyunu emerek yaprakların sararmasına ve büyümenin durmasına yol açar.",
    "en": "Sucks plant sap causing yellowing leaves and stunted growth."
  },
  "organicTreatment": {
    "tr": "Sarı yapışkan tuzaklar asın. 1 litre suya 1 tatlı kaşığı Neem yağı ve birkaç damla sıvı arap sabunu ekleyip 4 gün arayla yaprak altlarına püskürtün.",
    "en": "Hang yellow sticky traps. Spray undersides of leaves with neem oil and mild soap solution every 4 days."
  }
}
```

## 4. Çekirdek İş Mantığı ve Algoritmalar

### 4.1. Sulama / Gübreleme / Budama Renkli Uyarı Kartı Hesaplayıcısı (`careCalculator.js`)
Her bakım türü (Sulama, Gübreleme, Budama) için son uygulama tarihi ile bugünün tarihi arasındaki gün farkı hesaplanır ve renk kodu döndürülür:

```javascript
export function evaluateCareStatus(lastActionDateStr, intervalDays, todayStr = new Date().toISOString().slice(0, 10)) {
  const MS_PER_DAY = 1000 * 60 * 60 * 24;
  const lastDate = new Date(lastActionDateStr);
  const today = new Date(todayStr);

  const elapsedDays = Math.floor((today - lastDate) / MS_PER_DAY);
  const daysRemaining = intervalDays - elapsedDays;

  if (daysRemaining < 0) {
    return {
      status: 'OVERDUE',
      colorScheme: 'RED', // #EF4444 - Acil / Gecikti
      daysDelta: Math.abs(daysRemaining),
      labelTr: `${Math.abs(daysRemaining)} Gün Gecikti!`,
      labelEn: `${Math.abs(daysRemaining)} Days Overdue!`
    };
  }

  if (daysRemaining <= 1) {
    return {
      status: 'DUE_SOON',
      colorScheme: 'AMBER', // #F59E0B - Bugün veya Yarın
      daysDelta: daysRemaining,
      labelTr: daysRemaining === 0 ? 'Bugün Yapılmalı' : 'Yarın Yapılmalı',
      labelEn: daysRemaining === 0 ? 'Due Today' : 'Due Tomorrow'
    };
  }

  return {
    status: 'HEALTHY',
    colorScheme: 'GREEN', // #10B981 - Güvende
    daysDelta: daysRemaining,
    labelTr: `${daysRemaining} Gün Sonra`,
    labelEn: `In ${daysRemaining} Days`
  };
}
```

### 4.2. Ekimden Hasada Tahmini Gün Sayacı (`harvestCounter.js`)

```javascript
export function calculateHarvestCountdown(plantedAtStr, expectedHarvestDays, todayStr = new Date().toISOString().slice(0, 10)) {
  const MS_PER_DAY = 1000 * 60 * 60 * 24;
  const plantedDate = new Date(plantedAtStr);
  const today = new Date(todayStr);

  const elapsedDays = Math.max(0, Math.floor((today - plantedDate) / MS_PER_DAY));
  const remainingDays = Math.max(0, expectedHarvestDays - elapsedDays);
  const progressPercent = Math.min(100, Math.round((elapsedDays / expectedHarvestDays) * 100));

  let stage = { tr: 'Hasat Zamanı Geldi!', en: 'Ready for Harvest!' };
  if (progressPercent <= 20) {
    stage = { tr: 'Çimlenme ve Fide Evresi', en: 'Germination & Seedling Stage' };
  } else if (progressPercent <= 55) {
    stage = { tr: 'Vejetatif Gelişim Evresi', en: 'Vegetative Growth Stage' };
  } else if (progressPercent <= 85) {
    stage = { tr: 'Çiçeklenme ve Meyve Tutumu', en: 'Flowering & Fruiting Stage' };
  }

  const estimatedHarvestDate = new Date(plantedDate.getTime() + expectedHarvestDays * MS_PER_DAY)
    .toISOString()
    .slice(0, 10);

  return {
    elapsedDays,
    remainingDays,
    progressPercent,
    estimatedHarvestDate,
    stage,
    isReadyForHarvest: remainingDays === 0
  };
}
```

### 4.3. Semptom Bazlı Zararlı ve Hastalık Teşhis Algoritması (`pestMatcher.js`)

```javascript
export function matchPestOrDisease(selectedSymptoms, catalog) {
  if (!selectedSymptoms || selectedSymptoms.length === 0) {
    return catalog;
  }
  return catalog
    .map(item => {
      const matchedCount = item.symptoms.filter(s => selectedSymptoms.includes(s)).length;
      const matchScore = Math.round((matchedCount / selectedSymptoms.length) * 100);
      return { ...item, matchedCount, matchScore };
    })
    .filter(item => item.matchedCount > 0)
    .sort((a, b) => b.matchedCount - a.matchedCount);
}
```

## 5. Sayfa Yönlendirme (Routing) ve Durum Geçiş Tablosu

| Kaynak Ekran | Kullanıcı Aksiyonu | Hedef Ekran / Modal | Mimari Davranış |
| :--- | :--- | :--- | :--- |
| `Login` | `Giriş Yap` (Başarılı) | `GreenhouseListPage` (`BAHÇELER`) | Kullanıcı oturumu açılır ve seralar listelenir |
| `Login` | `Giriş Yap` (Hatalı) | `Login` (Uyarı Göster) | Form altında kırmızı hata mesajı gösterilir |
| `Login` | `Kayıt Oluştur` linki | `Register` (`Kayıt Oluştur`) | Yeni kullanıcı kayıt formu açılır |
| `Login` | `Şifremi Unuttum` linki | `ForgotPassword` (`ŞİFRE DEĞİŞTİR`) | E-posta kontrol ekranı açılır |
| `ForgotPassword` | E-posta doğrulama | `ResetPassword` (`Yeni Şifre Gir`) | `Yenile` butonu şifreyi günceller ve `BAHÇELER`'e yönlendirir |
| `GreenhouseListPage` | `[Sera Ekle]` butonu | `AddGreenhouseModal` | `Sera Adı` ve isteğe bağlı fotoğraf eklenir; `Onayla` listeye kaydeder |
| `GreenhouseListPage` | `[Sil]` butonu | `DeleteConfirmModal` | Yardım Kartı 2 kuralı gereği kalıcı silme uyarısı verir; onayda sera + içindeki tüm bitkiler silinir |
| `GreenhouseListPage` | `[Detay]` butonu | `GreenhouseDetailPage` (`Sera Adı`) | Seçili seranın içindeki bitkileri listeler |
| `GreenhouseDetailPage` | `[Ana Menü]` butonu | `GreenhouseListPage` (`BAHÇELER`) | Sera listesine geri döner |
| `GreenhouseDetailPage` | `[Bitki Ekle]` butonu | `AddPlantModal` | Bitki türü seçilir, ekim tarihi girilir ve seraya eklenir |
| `GreenhouseDetailPage` | Bitki satırı `[Detay]` | `PlantDetailPage` (`Bitki Detayları`) | Hasat sayacı, renkli uyarı kartları, sulama/güneş rehberi ve hastalık teşhis ekranını açar |
| Sağ Aksiyon Paneli | `[Not Ekle]` / `[Takvim]` / `[?]` / `[TR\|EN]` / `[Çıkış]` | İlgili Modal veya Görünüm | Bulunulan bağlama (Sera veya Bitki) göre hızlı aksiyon çalıştırır |
