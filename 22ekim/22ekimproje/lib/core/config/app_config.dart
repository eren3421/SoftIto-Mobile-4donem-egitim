import 'package:flutter/foundation.dart';
 
/// MENTOR Uygulama Konfigürasyonu (`lib/core/config/app_config.dart`)
/// Hugging Face Inference API, Mail (SMTP & EmailJS), Hive LocalStorage kutu adları
/// ve AI Mentor / PDF Uzman Görüşü sistem istemlerini (system prompts) barındırır.
class AppConfig {
  AppConfig._();

  // ===========================================================================
  // 1. UYGULAMA GENEL BİLGİLERİ
  // ===========================================================================
  static const String appName = 'MENTOR';
  static const String appTagline = 'Alışkanlık Takibi & Kişisel Gelişim';
  static const String appVersion = '1.0.0';
  static const String supportEmail = 'destek@mentor-app.com';

  // ===========================================================================
  // 2. HUGGING FACE API AYARLARI (CHATBOT & PDF UZMAN GÖRÜŞÜ)
  // ===========================================================================
  /// AI API Access Token (Hugging Face `hf_...`, Groq `gsk_...` veya OpenRouter `sk-or-...`).
  static String huggingFaceToken = const String.fromEnvironment(
    'HF_TOKEN',
    defaultValue: 'hf_BURAYA_KENDI_TOKENINI_YAPISTIR',
  );

  /// OpenAI uyumlu yeni nesil Hugging Face Inference Router adresi
  static const String hfRouterChatEndpoint =
      'https://router.huggingface.co/v1/chat/completions';

  /// Groq Cloud API adresi (Tamamen Ücretsiz Canlı LLM)
  static const String groqChatEndpoint =
      'https://api.groq.com/openai/v1/chat/completions';

  /// OpenRouter API adresi (Tamamen Ücretsiz Canlı Modeller)
  static const String openRouterChatEndpoint =
      'https://openrouter.ai/api/v1/chat/completions';

  /// Aktif kullanılan sohbet ve analiz uç noktası (Token türüne göre dinamik seçilir)
  static String get hfChatEndpoint {
    final t = huggingFaceToken.trim();
    if (t.startsWith('gsk_')) return groqChatEndpoint;
    if (t.startsWith('sk-or-')) return openRouterChatEndpoint;
    return hfRouterChatEndpoint;
  }

  /// Hugging Face Router'ında aktif olan resmi modeller
  static const String modelLlama31_8B = 'meta-llama/Llama-3.1-8B-Instruct';
  static const String modelDeepSeekR1 = 'deepseek-ai/DeepSeek-R1';
  static const String modelGptOss120B = 'openai/gpt-oss-120b';
  static const String modelQwen3 = 'Qwen/Qwen3.8-27B';

  /// Varsayılan aktif model
  static String selectedHfModel = modelLlama31_8B;

  /// Yedek model listesi (Sırayla denenir)
  static const List<String> fallbackHfModels = <String>[
    modelLlama31_8B,
    modelDeepSeekR1,
    modelQwen3,
    modelGptOss120B,
  ];

  /// AI yanıt üretim parametreleri
  static const double aiTemperature = 0.7;
  static const int aiMaxTokens = 2048;
  static const Duration apiTimeout = Duration(seconds: 25);

  /// Geçerli bir AI API Token girilip girilmediğini kontrol eder
  static bool get hasValidHfToken {
    final String cleaned = huggingFaceToken.trim();
    return cleaned.isNotEmpty &&
        (cleaned.startsWith('hf_') ||
            cleaned.startsWith('gsk_') ||
            cleaned.startsWith('sk-or-')) &&
        !cleaned.contains('BURAYA_KENDI_TOKENINI');
  }

  /// İsteklerde kullanılacak HTTP Başlıkları (Headers)
  static Map<String, String> get hfRequestHeaders => <String, String>{
        'Authorization': 'Bearer ${huggingFaceToken.trim()}',
        'Content-Type': 'application/json',
      };

  // ===========================================================================
  // 3. E-POSTA DOĞRULAMA SERVİSİ AYARLARI (SMTP & EMAILJS)
  // ===========================================================================
  /// SMTP Sunucu Ayarları (`mailer` paketi ile gerçek e-posta gönderimi için)
  /// Örn: Gmail için `smtp.gmail.com`, Port `587` ve Google "Uygulama Şifresi"
  static String smtpServer = const String.fromEnvironment(
    'SMTP_SERVER',
    defaultValue: 'smtp.gmail.com',
  );
  static int smtpPort = 587;
  static String smtpUsername = const String.fromEnvironment(
    'SMTP_USERNAME',
    defaultValue: '',
  );
  static String smtpPassword = const String.fromEnvironment(
    'SMTP_PASSWORD',
    defaultValue: '',
  );
  static String smtpSenderEmail = 'noreply@mentor-app.com';
  static String smtpSenderName = 'MENTOR Alışkanlık Takibi';

  /// EmailJS REST API Ayarları (Web/Mobil üzerinde SMTP portu engellendiğinde alternatif)
  static const String emailJsEndpoint =
      'https://api.emailjs.com/api/v1.0/email/send';
  static String emailJsServiceId = const String.fromEnvironment(
    'EMAILJS_SERVICE_ID',
    defaultValue: '',
  );
  static String emailJsTemplateId = const String.fromEnvironment(
    'EMAILJS_TEMPLATE_ID',
    defaultValue: '',
  );
  static String emailJsPublicKey = const String.fromEnvironment(
    'EMAILJS_PUBLIC_KEY',
    defaultValue: '',
  );

  /// SMTP yapılandırmasının hazır olup olmadığını kontrol eder
  static bool get hasSmtpConfig =>
      smtpServer.trim().isNotEmpty &&
      smtpUsername.trim().isNotEmpty &&
      smtpPassword.trim().isNotEmpty;

  /// EmailJS yapılandırmasının hazır olup olmadığını kontrol eder
  static bool get hasEmailJsConfig =>
      emailJsServiceId.trim().isNotEmpty &&
      emailJsTemplateId.trim().isNotEmpty &&
      emailJsPublicKey.trim().isNotEmpty;

  /// Gerçek e-posta gönderim servisinin yapılandırılıp yapılandırılmadığını kontrol eder
  static bool get isRealEmailConfigured =>
      hasEmailJsConfig || (!kIsWeb && hasSmtpConfig);

  /// Doğrulama kodunun (OTP) geçerlilik süresi (Dakika)
  static const int otpExpirationMinutes = 5;

  /// Son oluşturulan test OTP kodu (SMTP/EmailJS boşsa uygulama içi Debug Banner'da gösterilir)
  static String? latestDebugOtp;

  // ===========================================================================
  // 4. YEREL DEPOLAMA (HIVE LOCALSTORAGE & PDF DİZİNİ) SABİTLERİ
  // ===========================================================================
  static const String usersBoxName = 'users_box';
  static const String sessionBoxName = 'session_box';
  static const String habitsBoxName = 'habits_box';
  static const String notesBoxName = 'notes_box';
  static const String reportsBoxName = 'reports_box';
  static const String chatBoxName = 'chat_box';

  /// Üretilen PDF raporlarının cihaz içinde saklanacağı klasör adı
  static const String pdfReportsFolderName = 'mentor_reports';

  // ===========================================================================
  // 5. AI MENTOR & PDF UZMAN GÖRÜŞÜ SİSTEM İSTEMLERİ (SYSTEM PROMPTS)
  // ===========================================================================
  /// Genel Mentor / Chatbot için sistem istemi
  static String buildMentorSystemPrompt({
    required String username,
    required String habitsSummary,
    required String recentNotes,
    String? focusedHabitTitle,
    String? todayCompletionStatus,
  }) {
    final String scopeText = focusedHabitTitle != null
        ? 'Şu anda özellikle "$focusedHabitTitle" alışkanlığına odaklanarak koçluk yapıyorsun.'
        : 'Kullanıcının tüm alışkanlık portföyünü ve genel gelişimini yönetiyorsun.';

    final todayInfo = todayCompletionStatus != null
        ? '\nBugünkü Durum: $todayCompletionStatus'
        : '';

    return '''
Sen MENTOR uygulamasının bilimsel, empatik, ilham verici ve disiplinli yapay zeka alışkanlık koçusun.
Kullanıcı Adı: $username
Görev Kapsamı: $scopeText$todayInfo

Mevcut Alışkanlık ve Zincir (Streak) İstatistikleri:
$habitsSummary

Kullanıcının Alışkanlık Notları ve Yansımaları:
$recentNotes

Davranışsal Koçluk Kuralların ve Prensiplerin:
1. Hitap & Samimiyet: Kullanıcıya daima adıyla ($username) veya motive edici samimi bir üslupla Türkçe hitap et. "Merhaba ben Mentor yapay zeka koçunuzum..." gibi gereksiz resmi giriş kalıpları KULLANMA; doğrudan kullanıcının durumuna ve sorusuna odaklan.
2. Bilimsel Alışkanlık İlkeleri (Atomik & Küçük Alışkanlıklar):
   - 2 Dakika Kuralı: Kullanıcı zorlandığında veya ertelediğinde, eylemi 2 dakikada yapılabilecek mikro adıma indirge.
   - Alışkanlık İstifleme: Rutini var olan güçlü bir eylemin hemen ardına bağla ("Kahveni koyduktan hemen sonra...").
   - İki Gün Kuralı: Asla üst üste 2 gün zincirin kırılmasına izin verme. Bir gün kaçsa bile ertesi gün telafi protokolü uygula.
3. Bugünün Önemi: Eğer kullanıcı bugünkü hedefini henüz yapmadıysa, onu yargılamadan hemen şimdi harekete geçecek şekilde cesaretlendir.
4. Biçimlendirme & Netlik: Yanıtlarını okunaklı markdown paragrafları ve maddeler halinde yaz (aşırı karmaşık ve uzun tablolar yerine akıcı, okunabilir listeler tercih et).
5. Eksiksiz Tamamlama: Başladığın tüm maddeleri, şablonları ve cümleleri asla yarıda bırakma; yanıtını daima tam ve eksiksiz bir sonuca bağla.
6. Eyleme Çağrı (Call to Action): Her yanıtının sonuna mutlaka kalın puntolu, tek bir pratik mikro-görev koy:
   👉 **Şimdi yapabileceğin tek mikro adım:** [Somut eylem]
''';
  }

  /// PDF Raporları ("Genel" veya "Alışkanlığa Özel") için Kişiye Özel Uzman Görüşü istemi
  static String buildPdfExpertOpinionPrompt({
    required String username,
    required String reportScopeTitle,
    required int streak,
    required int longestStreak,
    required String weeklyPercent,
    required String monthlyPercent,
    required String notesSummary,
    bool isCompletedToday = false,
    String? dayPatternsSummary,
  }) {
    final streakContext = streak >= longestStreak && streak > 0
        ? 'Kullanıcı şu an $streak günlük aktif serisiyle kendi zirve rekorunu kırmaktadır.'
        : 'Kullanıcının en uzun rekoru $longestStreak gündür, mevcut aktif serisi $streak gündür.';

    final todayStatus = isCompletedToday
        ? 'Bugünkü rutin başarıyla tamamlandı.'
        : 'Bugünkü rutin henüz tamamlanmadı.';

    final patternInfo = dayPatternsSummary != null && dayPatternsSummary.isNotEmpty
        ? '\n- Hafta İçi / Hafta Sonu & Gün Dağılımı: $dayPatternsSummary'
        : '';

    return '''
Sen davranış psikolojisi, nöroplastisite ve alışkanlık mimarisi alanında uzman kıdemli bir analistsin.
$username isimli kullanıcının resmi PDF gelişim raporu için kişiye özel, derinlemesine ve bilimsel bir "Uzman Görüşü" hazırlıyorsun.

Rapor Verileri:
- Kullanıcı: $username
- Analiz Kapsamı: $reportScopeTitle
- Aktif Zincir (Streak): $streak gün
- En Uzun Zincir Rekoru: $longestStreak gün ($streakContext)
- Haftalık Tamamlama Oranı: %$weeklyPercent
- Aylık İstikrar Oranı: %$monthlyPercent
- Güncel Durum: $todayStatus$patternInfo
- Kullanıcının İlgili Dönem Notları: $notesSummary

Yazım Kuralları ve Çıktı Formatı:
Generic, şablon cümlelerden tamamen kaçın; doğrudan yukarıdaki rakamsal verilere (%$weeklyPercent, $streak gün, hafta içi vs hafta sonu ve notlar) atıfta bulunarak analiz yap.
Yanıtını doğrudan PDF belgesinde basılacak biçimde tam olarak şu 3 ana başlık altında kaleme al:

1. Nörolojik & Davranışsal Durum Analizi:
Kullanıcının haftalık (%$weeklyPercent) ve aylık (%$monthlyPercent) verilerini beynin bazal ganglionlarındaki nöral otomatikleşme süreci açısından değerlendir. Özellikle hafta içi vs. hafta sonu başarı oranını ve en çok aksatılan günü incele; eğer hafta sonu düşüşü veya belirli günlerde direnç varsa 'hafta sonu sendromu ve gevşeme psikolojisi' üzerinden analiz yap.

2. Güçlü Yönler & Kritik Risk Noktaları:
Kullanıcının notlarındaki ($notesSummary) duygusal durumu, $longestStreak günlük rekorunu ve en çok aksattığı günü referans alarak güçlü yönlerini ve hangi durumlarda zinciri kırma riski taşıdığını belirt.

3. Zinciri Korumak İçin 3 Kişiselleştirilmiş Strateji:
Doğrudan bu veriye ve özellikle en çok aksatılan gün örüntüsüne özel 3 somut taktik öner (Örn: En zayıf güne özel 2 Dakikalık Telafi Protokolü, Tetikleyici & Ortam Tasarımı, Alışkanlık İstifleme).
''';
  }
}