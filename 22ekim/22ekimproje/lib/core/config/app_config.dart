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
  /// Hugging Face Access Token (`hf_...` ile başlayan Fine-grained / Read token).
  /// İster doğrudan buraya yazabilir, ister derleme sırasında
  /// `--dart-define=HF_TOKEN=hf_xxx` parametresiyle geçebilir,
  /// istersen de uygulama içi ayarlardan çalışma zamanında güncelleyebilirsin.
  static String huggingFaceToken = const String.fromEnvironment(
    'HF_TOKEN',
    defaultValue: 'hf_BURAYA_KENDI_TOKENINI_YAPISTIR',
  );

  /// OpenAI uyumlu yeni nesil Hugging Face Inference Router adresi (Önerilen)
  static const String hfRouterChatEndpoint =
      'https://router.huggingface.co/v1/chat/completions';

  /// Model bazlı doğrudan HF Inference uç noktası (Yedek / Fallback)
  static String get hfDirectModelEndpoint =>
      'https://router.huggingface.co/hf-inference/models/$selectedHfModel/v1/chat/completions';

  /// Aktif kullanılan sohbet ve analiz uç noktası
  static String get hfChatEndpoint => hfRouterChatEndpoint;

  /// Türkçe başarısı yüksek ve kredi istemeyen ücretsiz Hugging Face serverless modelleri
  static const String modelQwen7B = 'Qwen/Qwen2.5-7B-Instruct';
  static const String modelMistral7B = 'mistralai/Mistral-7B-Instruct-v0.3';
  static const String modelLlama32_3B = 'meta-llama/Llama-3.2-3B-Instruct';
  static const String modelZephyr7B = 'HuggingFaceH4/zephyr-7b-beta';
  static const String modelGemma2B = 'google/gemma-2-2b-it';

  /// Varsayılan aktif model (Kredisiz, ücretsiz serverless çalışan model)
  static String selectedHfModel = modelQwen7B;

  /// Yedek model listesi (Birincil model meşgul/hata verirse sırayla denenir)
  static const List<String> fallbackHfModels = <String>[
    modelQwen7B,
    modelMistral7B,
    modelLlama32_3B,
    modelZephyr7B,
    modelGemma2B,
  ];

  /// AI yanıt üretim parametreleri
  static const double aiTemperature = 0.7;
  static const int aiMaxTokens = 700;
  static const Duration apiTimeout = Duration(seconds: 25);

  /// Geçerli bir Hugging Face Token girilip girilmediğini kontrol eder
  static bool get hasValidHfToken {
    final String cleaned = huggingFaceToken.trim();
    return cleaned.isNotEmpty &&
        cleaned.startsWith('hf_') &&
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
  }) {
    final String scopeText = focusedHabitTitle != null
        ? 'Şu anda sadece "$focusedHabitTitle" alışkanlığına odaklanarak mentorluk yapıyorsun.'
        : 'Kullanıcının tüm alışkanlıklarını ve genel gelişimini değerlendiriyorsun.';

    return '''
Sen MENTOR uygulamasının yapay zeka destekli kişisel gelişim ve alışkanlık koçusun.
Kullanıcı Adı: $username
Görev Kapsamı: $scopeText

Mevcut Alışkanlık ve Zincir (Streak) Verileri:
$habitsSummary

Kullanıcının Son Notları:
$recentNotes

Kurallar:
1. Yanıtlarını her zaman akıcı, samimi, motive edici ve net bir Türkçe ile ver.
2. Kullanıcının zinciri (streak) kırmaması için mikro alışkanlık stratejileri öner.
3. Yanıtlarını 2-3 kısa paragraf veya okunaklı maddeler halinde tut.
''';
  }

  /// PDF Raporları ("Genel" veya "Alışkanlığa Özel") için Uzman Görüşü istemi
  static String buildPdfExpertOpinionPrompt({
    required String username,
    required String reportScopeTitle,
    required String statsBreakdown,
    required String notesSummary,
  }) {
    return '''
Sen davranış bilimleri ve alışkanlık kazanımı konusunda uzman bir analistsin.
Aşağıdaki verileri inceleyerek MENTOR PDF Raporuna basılmak üzere profesyonel bir "Uzman Görüşü" hazırla.

Kullanıcı: $username
Rapor Kapsamı: $reportScopeTitle
İstatistikler ve Tamamlama Oranları:
$statsBreakdown

Kullanıcı Notları Özeti:
$notesSummary

Lütfen yanıtını doğrudan PDF raporunda yer alacak şekilde şu 3 başlık altında Türkçe olarak yaz:
1. Mevcut Performans ve Zincir (Streak) Analizi
2. Öne Çıkan Güçlü Yönler
3. Devamlılık İçin 3 Somut Uzman Tavsiyesi
''';
  }
}