# KPSS Çalışma Koçu - Durum ve Veri Akışı (State Flow)

## 1. Veri Saklama Mimarisi (Hive Boxes)
Uygulama sıfır backend ile çalışır. Tüm veriler cihazda yerel olarak saklanır.

| Hive Kutusu | Anahtar (Key) | Değer Tipi | Açıklama |
|---|---|---|---|
| `settings_box` | `dailyGoal`, `isDark` | `int`, `bool` | Kullanıcı tercihleri ve günlük soru hedefi |
| `topic_status_box` | `topic_id` (String) | `int` (0, 1, 2) | Konu tamamlama durumu (0: Çalışılmadı, 1: Tekrar, 2: Bitirdim) |
| `question_logs_box` | `id` (UUID) | `Map<String, dynamic>` | Soru çözüm kayıtları (D, Y, B, Tarih, Ders, Not) |
| `study_sessions_box`| `id` (UUID) | `Map<String, dynamic>` | Pomodoro & Kronometre çalışma oturumu süreleri |
| `mock_exams_box` | `id` (UUID) | `Map<String, dynamic>` | Deneme sınavı sonuçları (GY Net, GK Net, Toplam Net) |

## 2. Reaktif Akış (Provider Katmanı)
1. **CurriculumProvider:**
   - Açılışta `assets/kpss_topics.json` okunur.
   - `topic_status_box` verisiyle birleştirilir.
   - Konu durumu değiştirildiğinde `setTopicStatus()` çağrılır, kutuya yazılır ve tüm arayüzdeki progress barlar anlık güncellenir.
2. **QuestionProvider:**
   - Yeni soru eklendiğinde `addQuestionLog()` çağrılır.
   - `KpssCalculator.calculateNet(d, y)` hesaplanır.
   - `dailyGoal` çemberi ve `fl_chart` grafikleri anlık olarak yeniden çizilir.
3. **TimerProvider:**
   - Sekmeler arasında gezinirken sayacın sıfırlanmaması için `IndexedStack` ile durum korunur.
   - Oturum tamamlandığında `SaveSessionDialog` tetiklenerek seçilen ders için `StudySession` kaydı oluşturulur.
