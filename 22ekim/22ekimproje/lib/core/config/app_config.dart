/// MENTOR Uygulama Konfigürasyonu
/// Hugging Face API, Mail (SMTP / EmailJS) ayarları ve genel yapılandırma sabitleri.
class AppConfig {
  AppConfig._();

  static const String appName = 'MENTOR';
  static const String appTagline = 'Alışkanlık Takibi & Kişisel Gelişim';
  static const String appVersion = '1.0.0';

  // Hugging Face API Ayarları
  // Kullanıcı dilerse kendi HF Token'ını girebilir veya varsayılan token kullanılabilir.
  static String huggingFaceToken = '';
  
  // Önerilen model uç noktaları:
  static const String hfChatEndpoint =
      'https://router.huggingface.co/hf-inference/models/mistralai/Mistral-7B-Instruct-v0.3/v1/chat/completions';
  
  // Mail / SMTP Ayarları (Opsiyonel kullanıcı tanımlı, boşsa simüle edilmiş / debug banner OTP akışı devreye girer)
  static String smtpServer = '';
  static int smtpPort = 587;
  static String smtpUsername = '';
  static String smtpPassword = '';
  static String smtpSenderEmail = 'noreply@mentor-app.com';

  // Son oluşturulan test OTP kodu (Uygulama içi hızlı test ve debug bildirimi için)
  static String? latestDebugOtp;
}
