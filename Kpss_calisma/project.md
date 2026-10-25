# KPSS Çalışma Koçu (KPSS Study Coach) - PROJECT.md

## 1. Proje Özeti ve Amacı
KPSS (Genel Yetenek - Genel Kültür) adaylarının ders/konu ilerlemelerini takip edebildikleri, günlük çözdükleri soru sayılarını (Doğru/Yanlış/Boş) kaydedip haftalık/aylık performans grafiklerini inceleyebildikleri, Pomodoro/Serbest sayaç ile çalışma sürelerini tutabildikleri **tamamen çevrimdışı (offline-first)** çalışan bir Flutter mobil uygulamasıdır.

## 2. Teknoloji Yığını (Tech Stack)
- **Framework:** Flutter (Dart 3.x, Material 3)
- **State Management:** Riverpod (`flutter_riverpod`) veya Provider (Modüler ve reaktif yapı)
- **Yerel Veritabanı (Offline Storage):** `hive` & `hive_flutter` (NoSQL, hızlı okuma/yazma)
- **Sabit Veriler (Static Data):** `assets/kpss_topics.json` (GY-GK ders ve alt konu ağacı)
- **Grafik ve Görselleştirme:** `fl_chart` (Çubuk, çizgi ve pasta grafikleri)
- **Tarih/Saat İşlemleri:** `intl`

## 3. Temel Özellikler (MVP Kapsamı)
1. **Müfredat ve Konu Takibi:**
   - Dersler: Türkçe, Matematik, Tarih, Coğrafya, Vatandaşlık.
   - Her alt konu için 3 durum: `Çalışılmadı (0)`, `Tekrar Edilecek (1)`, `Bitirdim (2)`.
   - Ders bazlı ilerleme yüzdesi (Progress Bar).
2. **Günlük Soru Takibi:**
   - Ders seçimi, Doğru (D), Yanlış (Y), Boş (B) sayısı ve tarih girişi.
   - KPSS net hesaplama kuralı: `Net = Doğru - (Yanlış / 4)`.
   - Günlük toplam soru hedefi belirleme ve ana sayfada dairesel/çizgisel hedef çubuğu.
3. **Çalışma Sayacı (Pomodoro & Kronometre):**
   - 25 dk çalışma / 5 dk mola (Pomodoro) veya Serbest Kronometre (`Timer.periodic` & `Stopwatch`).
   - Oturum bittiğinde "Hangi derse çalıştın?" diyaloğu ile süreyi ilgili derse kaydetme.
4. **İstatistik & Analiz:**
   - Ders bazlı toplam çözülen soru, doğru/yanlış oranı ve başarı yüzdesi (`(Doğru / Toplam Çözülen) * 100`).
   - `fl_chart` ile son 7 günün soru çözüm dağılımı (BarChart) ve ders dağılımı (PieChart).
5. **Deneme Sınavı Takibi (Ek Özellik):**
   - Deneme adı/yayını, tarih, GY ve GK doğru/yanlış sayıları ve toplam net kaydı.

## 4. Veri Modelleri ve Hive Kutuları (Boxes)
- `settings_box`: Günlük soru hedefi (`dailyGoal`), tema tercihi (`isDark`), ilk açılış kontrolü.
- `topic_status_box`: Key: `topic_id` (String), Value: `status_index` (int: 0, 1, 2).
- `question_logs_box`: `QuestionLog` nesneleri (`id`, `courseId`, `correct`, `wrong`, `empty`, `date`).
- `study_sessions_box`: `StudySession` nesneleri (`id`, `courseId`, `durationInMinutes`, `date`, `type`).
- `mock_exams_box`: `MockExam` nesneleri (`id`, `title`, `date`, `gyCorrect`, `gyWrong`, `gkCorrect`, `gkWrong`).

## 5. Klasör Yapısı (Feature-First Architecture)
- `lib/core/constants/` -> Renkler, sabit metinler, ders listesi
- `lib/core/theme/` -> Material 3 Light/Dark tema ayarları
- `lib/core/utils/` -> Net hesaplayıcı, tarih formatlayıcılar
- `lib/core/services/` -> Hive başlatma ve JSON okuma servisleri
- `lib/models/` -> Veri modelleri (Topic, QuestionLog, StudySession, MockExam)
- `lib/providers/` -> State management sınıfları
- `lib/features/dashboard/` -> Ana Sayfa (Özet kartları, hedef çubuğu, hızlı erişim)
- `lib/features/curriculum/` -> Konu Takip Ekranı (Ders sekmeleri ve durum seçiciler)
- `lib/features/question_tracker/` -> Soru Ekleme Formu / BottomSheet
- `lib/features/timer/` -> Pomodoro ve Kronometre Ekranı
- `lib/features/statistics/` -> fl_chart Grafikleri ve Analiz Ekranı
- `lib/features/mock_exams/` -> Deneme Sınavı Net Takip Ekranı

## 6. Ekranlar ve Navigasyon
- **BottomNavigationBar (4 Ana Sekme):**
  1. `Ana Sayfa` (Dashboard)
  2. `Konular` (Curriculum)
  3. `Sayaç` (Timer)
  4. `İstatistik` (Statistics)
- **FloatingActionButton (FAB):** Hızlı Soru Ekleme (Modal Bottom Sheet açar) veya Deneme Ekleme.
