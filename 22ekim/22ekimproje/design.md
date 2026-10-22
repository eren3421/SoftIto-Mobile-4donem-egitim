# MENTOR - Tasarım Sistemi ve Ekran Spesifikasyonları (DESIGN.md)

Bu doküman, **MENTOR Alışkanlık Takip Uygulaması**'nın **Koyu Pembe (Dark Pink / Deep Rose)** renk paletini, tipografisini, el çizimi eskizlere (wireframe) birebir sadık ekran yerleşimlerini ve bileşen tasarımlarını tanımlar.

## 1. Renk Paleti (Koyu Pembe / Deep Rose Dark & Light Uyumu)

Uygulama, modern, motive edici ve göz yormayan **Koyu Pembe & Gece Mürdümü (Deep Rose & Obsidian Plum)** teması üzerine kuruludur:

| Rol | Renk Adı | Hex Kodu | Kullanım Yeri |
| :--- | :--- | :--- | :--- |
| **Primary (Ana Renk)** | Deep Rose / Koyu Pembe | `#C2185B` | Ana butonlar (`Giriş Yap`, `Rapor Oluştur`, `Ekle`, `Onayla`), aktif takvim günleri |
| **Primary Variant** | Crimson Berry / Bordo Pembe | `#880E4F` | AppBar, sağ dikey aksiyon menüsü vurgu arka planı, PDF başlık bandı |
| **Accent / Secondary** | Vibrant Pink / Canlı Pembe | `#FF4081` | Aktif zincir (streak) ateşi, seçili ikonlar, grafik çizgileri, onay kutuları |
| **Soft Pink Tint** | Blush Rose / Açık Gül | `#F8BBD0` | İkincil metin vurguları, rozet arka planları, GitHub ızgarası orta yoğunluk |
| **Background (Arka Plan)** | Dark Plum Night | `#12090E` | Ana ekran arka planı |
| **Surface (Kart Yüzeyi)** | Elevated Mulberry | `#1E1118` | Alışkanlık satır kartları, takvim kutusu, sağ aksiyon menüsü, modallar |
| **Surface Variant** | Muted Rose Gray | `#2C1923` | Metin giriş alanları (`TextField`), pasif takvim hücreleri |
| **Text Primary** | Snow Pink White | `#FCE4EC` | Ana başlıklar (`MENTOR`, `YAPILACAKLAR`, `ALIŞKANLIK DETAY`) ve birincil metinler |
| **Text Secondary** | Dusty Mauve | `#CE93D8` / `#BCAAA4` | Alt açıklamalar, tarih etiketleri, ipucu metinleri |
| **Success / Streak** | Emerald Mint | `#00E676` | Tamamlanan alışkanlık onayı, yüksek başarı yüzdesi |
| **Danger / Delete** | Coral Red | `#FF5252` | `Sil` butonu, `Hesabı Sil` uyarısı, hata mesajları |

## 2. Tipografi ve İkonografi
- **Font Ailesi:** `Plus Jakarta Sans` veya `Poppins` (`google_fonts` üzerinden).
- **Başlık Hiyerarşisi:**
  - **Uygulama Logosu (`MENTOR`):** `28sp`, `FontWeight.w800`, harf aralığı `2.0`, `#FF4081` degrade vurgulu.
  - **Sayfa Başlıkları (`YAPILACAKLAR`, `ALIŞKANLIK DETAY`, `Şifre Yenile`):** `22sp`, `FontWeight.w700`, `#FCE4EC`.
  - **Alışkanlık Satır Başlığı:** `16sp`, `FontWeight.w600`.
  - **Gövde ve Not Metinleri:** `14sp`, `FontWeight.w400`, satır yüksekliği `1.5`.
  - **Buton Etiketleri:** `14sp`, `FontWeight.w700`, büyük/küçük harf duyarlı.

## 3. El Çizimi Eskizlere (Wireframe) Sadık Ekran Tasarımları

### 3.1. Kimlik Doğrulama Ekranları (Eskiz 2)
Tüm kimlik doğrulama ekranlarında merkezde dikey hizalanmış, yuvarlatılmış köşeli (`borderRadius: 20px`), `#1E1118` yüzey rengine ve `#C2185B` ince kenarlığa sahip form kartı bulunur:

1. **MENTOR - Giriş Yap Ekranı:**
   - Üstte `MENTOR` başlığı ve altında `Giriş Yap` alt başlığı.
   - Oval kenarlı (`StadiumBorder`) `Kullanıcı adı` giriş alanı.
   - Oval kenarlı `Şifre` giriş alanı.
   - Dikdörtgen dolgulu `#C2185B` renginde `[Giriş Yap]` butonu.
   - Altında alt alta tıklanabilir metin bağlantıları: `Kayıt ol` (Kayıt Ol ekranına gider) ve `Şifre değiştir` (Şifre Yenile E-posta ekranına gider).
2. **MENTOR - Kayıt Ol Ekranı:**
   - Üstte `MENTOR` başlığı ve altında `Kayıt Ol` alt başlığı.
   - Oval kenarlı 3 giriş alanı: `Kullanıcı adı`, `E-posta`, `Şifre`.
   - Altında `[Kayıt Ol]` butonu (tıklandığında e-postaya doğrulama kodu gönderir ve doğrulama modalını açar).
3. **Şifre Yenile - E-postanı Gir Ekranı (Adım 1):**
   - Başlık: `Şifre Yenile` ve alt açıklama: `E-postanı Gir`.
   - Oval kenarlı `E-posta` giriş alanı.
   - Altında `[Doğrula]` butonu (Mail servisiyle doğrulama kodu gönderir, kod onaylandığında 2. adıma geçer).
4. **Şifre Yenile Ekranı (Adım 2):**
   - Başlık: `Şifre Yenile`.
   - Oval kenarlı yeni `Şifre` giriş alanı.
   - Altında `[Onayla]` butonu (Şifreyi günceller ve Giriş Yap ekranına yönlendirir).

### 3.2. Yapılacaklar / Genel Alışkanlıklar Ana Ekranı (Eskiz 1 - Üst)
Ekran **iki sütunlu (Split Layout)** bir yapıya sahiptir:
- **Sol / Ana Gövde (%82 Genişlik):**
  - **Üst Başlık:** `YAPILACAKLAR`
  - **Alışkanlık Listesi:** Alt alta sıralanan satırlar. Her satırda:
    - Sol başta tek dokunuşla tamamlama onay kutusu (`Checkbox` / `InkWell` daire, tamamlandığında `#FF4081` dolgulu)
    - `Alışkanlık Adı` ve yanında aktif zincir rozeti (`🔥 5 gün`)
    - Sağda `Görüntüle` butonu (Alışkanlık Detay ekranını açar) ve `Sil` butonu (`#FF5252` vurguyla siler).
  - **Alt Aksiyon Çubuğu:** Sol altta `[Rapor Oluştur]` butonu, hemen sağında `[Ekle]` butonu.
- **Sağ Dikey İkon Menüsü (%18 Genişlik, `#1E1118` dikey şerit):**
  Yukarıdan aşağıya 5 adet özel ikon butonu:
  1. 🔔 **Bildirimler İkonu:** Hatırlatma saatlerini ve bildirim izinlerini yönetir.
  2.  pentagonal/not **Not İkonu (`Not Ekle / Notları Görüntüle - Tüm Notlar`):** Hem genel notları hem de tüm alışkanlıkların özel notlarını gösteren ve yeni not ekleyen paneli açar.
  3. 💬 **Konuşma Balonu İkonu (`Mentor / Chatbot`):** Hugging Face API bağlantılı genel AI Mentor sohbet penceresini açar.
  4. 📄 **Belge İkonu (`Gizlilik Politikası / S.S.S. / İletişim`):** Sağ üstünde `[X]` kapatma butonu olan bilgi modalını (`Gizlilik Politikası`, `S.S.S.`, `Hesap Silme`, `İletişim`) ve genel PDF rapor arşivini açar.
  5. ℹ️ **Bilgi / Hesap İkonu (`Hesabı Sil / Çıkış Yap`):** `Hesabı Sil` ve `Çıkış Yap` seçeneklerini içeren hızlı işlem menüsünü açar.

### 3.3. Ana Ekran Alt Pencereleri (Eskiz 1 - Orta)
1. **Alışkanlık Ekle Penceresi (`[Ekle]` butonuna basınca):**
   - Başlık/Giriş: `Alışkanlık 1` (Alışkanlık adı metin kutusu ve opsiyonel hatırlatma saati seçici).
   - Alt butonlar: Sol altta `[İptal]`, sağ altta `[Onayla]`.
2. **Genel Grafik & İstatistikler (AI Uzman) PDF Penceresi (`[Rapor Oluştur]` butonuna basınca):**
   - Sağ üstte `[X]` kapatma butonu.
   - Üst bölümde `Grafikler`: Haftalık/aylık tamamlama oranları çubuk grafiği ve GitHub tarzı genel katkı ızgarası.
   - Alt bölümde `Uzman Görüşü`: Hugging Face API'den gelen kişiselleştirilmiş değerlendirme metni.
   - Alt aksiyon: `[PDF Oluştur ve Sakla]` butonu (PDF'i oluşturur, cihaza kaydeder ve önizlemeye açar).
3. **Gizlilik ve İletişim Penceresi:**
   - Sağ üstte `[X]` kapatma butonu.
   - Seçenekler: `Gizlilik Politikası`, `S.S.S.`, `Hesap Silme`, `İletişim`.

### 3.4. Alışkanlık Detay Ekranı (Eskiz 1 - Alt)
Ana ekranla aynı **iki sütunlu (Split Layout)** tasarım dilini korur:
- **Sol / Ana Gövde (%82 Genişlik):**
  - **Üst Başlık:** `ALIŞKANLIK DETAY` (Altında seçili alışkanlığın adı ve aktif/en uzun zincir sayaçları).
  - **Merkez Kart (`Takvim - Yapılan Günleri Onayla`):**
    - Kullanıcının günlere dokunarak tamamlama durumunu onaylayabildiği veya geri alabildiği etkileşimli aylık takvim. Tamamlanan günler `#C2185B` daire ve `#FF4081` çerçeve ile vurgulanır.
    - Takvimin hemen altında **GitHub Katkı Grafiği Tarzı Izgara (Heatmap)**: Tamamlama yoğunluğuna göre `#2C1923` (boş) ile `#FF4081` (tamamlandı) arasında renklendirilen haftalık/aylık ızgara.
  - **Alt Aksiyon Çubuğu:** Sol altta `[Raporla]` (Alışkanlığa özel grafikli ve AI uzman görüşlü PDF oluşturur ve saklar), sağ altta `[Geri]` (Ana sayfaya döner).
- **Sağ Dikey İkon Menüsü (%18 Genişlik):**
  Yukarıdan aşağıya 5 adet özel ikon butonu:
  1. 🔔 **Bildirimler İkonu:** Bu alışkanlığa özel günlük hatırlatma saati kurulumu.
  2. 🗒️ **Not İkonu (`Not Ekle`):** Bu alışkanlığa özel not ekleme ve sadece bu alışkanlığın notlarını görüntüleme.
  3. 💬 **Konuşma Balonu İkonu (`Mentor`):** Bu alışkanlığın verilerine odaklanmış Hugging Face AI Mentor sohbeti.
  4. 📄 **Belge İkonu (`PDF Raporları`):** Bu alışkanlık için daha önce oluşturulup yerel depolamada saklanan PDF raporlarının listesi ve görüntüleyicisi.
  5. ℹ️ **Bilgi / Hesap İkonu (`Hesabı Sil / Çıkış`):** Hesap silme ve oturum kapatma aksiyonları.

## 4. PDF Rapor Tasarım Şablonu (A4 Dikey)
Oluşturulan PDF dosyaları da uygulamanın kurumsal Koyu Pembe kimliğini taşır:
- **Üst Bilgi (Header):** `#880E4F` arka planlı bant, beyaz `MENTOR - Alışkanlık & Gelişim Raporu` başlığı, kullanıcı adı ve oluşturulma tarihi.
- **Bölüm 1 - Özet Metrik Kutuları:** Aktif Zincir (Streak), En Uzun Zincir, Haftalık Başarı (%) ve Aylık Başarı (%) kartları.
- **Bölüm 2 - Görsel Grafikler:** Pembe tonlarında (`#C2185B`, `#FF4081`, `#F8BBD0`) haftalık/aylık performans çubuk grafiği ve son 30 gün tamamlama matrisi.
- **Bölüm 3 - AI Uzman Görüşü:** `#FCE4EC` açık pembe arka planlı, sol kenarı `#C2185B` kalın şeritli özel bilgi kutusu içinde Hugging Face AI tarafından üretilen detaylı uzman analizi ve tavsiyeler.
- **Bölüm 4 - Alışkanlık Notları:** Kullanıcının ilgili dönemde aldığı notların tarih sırasıyla listesi.
