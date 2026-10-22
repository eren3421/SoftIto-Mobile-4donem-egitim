import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../core/config/app_config.dart';

class HuggingFaceService {
  static final HuggingFaceService instance = HuggingFaceService._internal();
  HuggingFaceService._internal();

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 25),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  /// Hugging Face Chat Completions API Çağrısı (OpenAI uyumlu endpoint)
  Future<String?> _callHfChatCompletion({
    required String model,
    required String token,
    required List<Map<String, String>> messages,
    int maxTokens = 600,
    double temperature = 0.7,
  }) async {
    final response = await _dio.post(
      AppConfig.hfChatEndpoint,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
      data: {
        'model': model,
        'messages': messages,
        'max_tokens': maxTokens,
        'temperature': temperature,
      },
    );

    if (response.statusCode == 200 && response.data != null) {
      final choices = response.data['choices'] as List?;
      if (choices != null && choices.isNotEmpty) {
        final content = choices.first['message']?['content'] as String?;
        if (content != null && content.trim().isNotEmpty) {
          return content.trim();
        }
      }
    }
    return null;
  }

  /// AI Mentor / Chatbot Mesaj Gönderimi (Doğrudan Canlı Model Bağlantısı)
  Future<String> sendMessage({
    required String userMessage,
    required String habitContext,
    required String notesContext,
    List<Map<String, String>> previousMessages = const [],
  }) async {
    final token = AppConfig.huggingFaceToken.trim();

    // Token yoksa kullanıcıya açıkça bilgi ver (Hazır cevap stoğu KULLANMA)
    if (!AppConfig.hasValidHfToken) {
      return '⚠️ Canlı Hugging Face Modeli Bağlantısı Gerekli!\n\n'
          'Arka planda hazır cevap stoğu yerine doğrudan açık kaynaklı bir yapay zeka modelinin '
          '(${AppConfig.selectedHfModel}) çalışıp sorularınıza dinamik cevap üretebilmesi için '
          'ücretsiz bir Hugging Face Token (hf_...) tanımlanmalıdır.\n\n'
          '📌 Nasıl Bağlanırsınız?\n'
          '1. huggingface.co/settings/tokens adresinden ücretsiz bir "Read" token oluşturun.\n'
          '2. Sağ üstteki 🔑 (Anahtar) simgesine tıklayıp tokeninizi kaydedin.\n\n'
          'Token kaydedildiğinde tüm sorularınız anlık olarak arkadaki Hugging Face modeline gönderilecek ve canlı yanıtlar üretilecektir.';
    }

    try {
      final systemPrompt =
          '''Sen MENTOR uygulamasının empatik, motive edici ve disiplinli yapay zeka alışkanlık koçusun. 
Kullanıcının mevcut alışkanlık verileri: $habitContext. 
Kullanıcının aldığı son notlar: $notesContext. 
Kullanıcıya daima akıcı ve samimi Türkçe ile, yapıcı, mikro adımlara odaklanan ve motivasyonunu artıran yanıtlar ver. Yanıtların çok uzun olmasın, uygulanabilir ve pratik olsun.''';

      final messages = [
        {'role': 'system', 'content': systemPrompt},
        ...previousMessages,
        {'role': 'user', 'content': userMessage},
      ];

      // Token türüne göre optimize edilmiş model listesi belirle
      List<String> modelsToTry;
      if (token.startsWith('gsk_')) {
        // Groq Cloud: %100 Ücretsiz, Kredisiz Canlı Modeller
        modelsToTry = [
          'llama-3.3-70b-versatile',
          'mixtral-8x7b-32768',
          'qwen-2.5-32b',
          'gemma2-9b-it',
        ];
      } else if (token.startsWith('sk-or-')) {
        // OpenRouter: Tamamen Ücretsiz Canlı Modeller (:free)
        modelsToTry = [
          'meta-llama/llama-3.2-3b-instruct:free',
          'deepseek/deepseek-r1:free',
          'google/gemini-2.0-flash-exp:free',
          'qwen/qwen-2.5-72b-instruct:free',
        ];
      } else {
        // Hugging Face Router'ında aktif doğrulanmış resmi modeller
        modelsToTry = [
          AppConfig.selectedHfModel,
          ...AppConfig.fallbackHfModels.where((m) => m != AppConfig.selectedHfModel),
        ];
      }

      String? lastErrorDetail;
      bool had402CreditError = false;

      for (final model in modelsToTry) {
        try {
          debugPrint('[HuggingFaceService] Model çağrılıyor: $model (${AppConfig.hfChatEndpoint})...');
          final reply = await _callHfChatCompletion(
            model: model,
            token: token,
            messages: messages,
            maxTokens: 600,
            temperature: 0.7,
          );

          if (reply != null && reply.trim().isNotEmpty) {
            debugPrint('[HuggingFaceService] $model başarıyla yanıt üretti.');
            return reply;
          }
        } on DioException catch (dioErr) {
          final statusCode = dioErr.response?.statusCode;
          debugPrint('[HuggingFaceService] $model hatası: $statusCode - ${dioErr.message}');
          if (statusCode == 401) {
            return '⚠️ Yetkilendirme Hatası (401 Unauthorized):\n\n'
                'Girdiğiniz API Token geçersiz veya yetkisiz.\n'
                'Lütfen sağ üstteki 🔑 simgesinden tokeninizi kontrol edip güncelleyiniz.';
          } else if (statusCode == 402) {
            had402CreditError = true;
            debugPrint('[HuggingFaceService] $model ücretli kredi istedi (402). Sonraki model deneniyor...');
            lastErrorDetail = 'HTTP 402: $model için ücretli kredi istendi.';
            continue;
          }
          lastErrorDetail = 'HTTP $statusCode: ${dioErr.response?.data?['error']?['message'] ?? dioErr.response?.data?['error'] ?? dioErr.message}';
        } catch (e) {
          debugPrint('[HuggingFaceService] $model istisna: $e');
          lastErrorDetail = e.toString();
        }
      }

      if (had402CreditError) {
        return '⚠️ Hugging Face Kredi Uyarısı (HTTP 402 - No Remaining Credits):\n\n'
            'Hugging Face, router üzerindeki modeller için ücretli kredi talep etmektedir.\n\n'
            '💡 2 Basit Çözüm Yolu:\n'
            '1. (Önerilen - %100 Ücretsiz): console.groq.com/keys adresinden 10 saniyede ücretsiz bir Groq API Key (gsk_...) alıp 🔑 butonuna yapıştırın. Kredi kartı istemez, Llama 3.3 70B anında canlı çalışır!\n'
            '2. Veya Hugging Face hesabınıza huggingface.co/settings/billing üzerinden 1\$ kredi ekleyin.';
      }

      return '⚠️ Hugging Face Modeline Ulaşılamadı:\n\n'
          'Arka plandaki model uç noktaları denendi ancak yanıt alınamadı.\n'
          'Detay: ${lastErrorDetail ?? 'Servis meşgul veya zaman aşımı.'}\n\n'
          'Lütfen internet bağlantınızı ve sağ üstteki 🔑 token bilginizi kontrol edip tekrar deneyiniz.';
    } catch (e) {
      debugPrint('[HuggingFaceService] Genel Hata: $e');
      return '⚠️ Hugging Face Bağlantı Hatası: $e\nLütfen tekrar deneyiniz.';
    }
  }

  /// PDF Raporları İçin Yapay Zeka Uzman Görüşü Üretimi
  Future<String> generateExpertEvaluation({
    String? habitTitle,
    required int streak,
    required int longestStreak,
    required double weeklyRate,
    required double monthlyRate,
    List<String> notes = const [],
  }) async {
    final token = AppConfig.huggingFaceToken.trim();

    final habitName = habitTitle ?? 'Genel Alışkanlıklar';
    final weeklyPercent = (weeklyRate * 100).toStringAsFixed(1);
    final monthlyPercent = (monthlyRate * 100).toStringAsFixed(1);
    final notesSummary = notes.isEmpty ? 'Kayıtlı not yok.' : notes.take(3).join('; ');

    if (!AppConfig.hasValidHfToken) {
      return _generateLocalExpertEvaluation(
        habitName: habitName,
        streak: streak,
        longestStreak: longestStreak,
        weeklyPercent: weeklyPercent,
        monthlyPercent: monthlyPercent,
      );
    }

    try {
      final prompt =
          '''Sen davranış bilimleri ve alışkanlık kazanımı uzmanısın. 
Aşağıdaki alışkanlık tamamlama verilerini analiz et ve PDF raporuna basılmak üzere Türkçe bir değerlendirme hazırla:
- Alışkanlık: $habitName
- Aktif Zincir (Streak): $streak gün
- En Uzun Zincir: $longestStreak gün
- Haftalık Tamamlama Oranı: %$weeklyPercent
- Aylık Tamamlama Oranı: %$monthlyPercent
- Son Kullanıcı Notları: $notesSummary

Lütfen şu 3 ana başlık altında profesyonel ve teşvik edici bir uzman raporu yaz:
1) Mevcut Durum Analizi
2) Güçlü Yönler & Gelişim Alanları
3) Zinciri Kırmamak İçin 3 Somut Tavsiye''';

      final messages = [
        {'role': 'system', 'content': 'Sen kıdemli bir davranış bilimci ve MENTOR uzmanısın.'},
        {'role': 'user', 'content': prompt},
      ];

      String modelToUse = AppConfig.selectedHfModel;
      if (token.startsWith('gsk_')) {
        modelToUse = 'llama-3.3-70b-versatile';
      } else if (token.startsWith('sk-or-')) {
        modelToUse = 'meta-llama/llama-3.2-3b-instruct:free';
      }

      final reply = await _callHfChatCompletion(
        model: modelToUse,
        token: token,
        messages: messages,
        maxTokens: 800,
        temperature: 0.65,
      );

      if (reply != null && reply.trim().isNotEmpty) {
        return reply;
      }

      return _generateLocalExpertEvaluation(
        habitName: habitName,
        streak: streak,
        longestStreak: longestStreak,
        weeklyPercent: weeklyPercent,
        monthlyPercent: monthlyPercent,
      );
    } catch (e) {
      debugPrint('[HuggingFaceService] Uzman Görüşü API Hatası: $e');
      return _generateLocalExpertEvaluation(
        habitName: habitName,
        streak: streak,
        longestStreak: longestStreak,
        weeklyPercent: weeklyPercent,
        monthlyPercent: monthlyPercent,
      );
    }
  }

  // ===================== PDF RAPORLARI İÇİN YEREL DEĞERLENDİRME =====================

  String _generateLocalExpertEvaluation({
    required String habitName,
    required int streak,
    required int longestStreak,
    required String weeklyPercent,
    required String monthlyPercent,
  }) {
    return '''1) Mevcut Durum Analizi:
"$habitName" hedefinizde son haftalık başarı oranınız %$weeklyPercent ve aylık istikrarınız %$monthlyPercent seviyesindedir. Şu anda $streak günlük kesintisiz bir aktif zincire (streak) sahipsiniz ve geçmişteki en uzun rekorunuz $longestStreak gündür. Veriler, alışkanlığın otomatikleşme evresine doğru ilerlediğini kanıtlamaktadır.

2) Güçlü Yönler & Gelişim Alanları:
Gözlemlenen en belirgin güçlü yönünüz, rutini hatırlama ve günlük takip yapma disiplininizdir. Tamamlama oranınızın %50'nin üzerinde olması nöral pekişmeyi başlatmıştır. Gelişim alanı olarak ise yorgun veya yoğun günlerde oluşabilecek duraksamalara karşı alternatif mikro-eylem protokolleri belirlemek kritik önem taşımaktadır.

3) Zinciri Kırmamak İçin 3 Somut Tavsiye:
• 2 Dakika Kuralı: Zorlandığınız günlerde alışkanlığı iptal etmek yerine sadece 2 dakikalık sembolik versiyonunu uygulayın (örn: 1 sayfa kitap, 1 bardak su).
• Ortam Tasarımı: Alışkanlıkla ilgili tetikleyicileri göz önünde tutun (kitabı masaya, su mataralarını çalışma alanınıza yerleştirin).
• İki Gün Kuralı: Asla üst üste iki gün boş geçmeyin. Bir gün kaçsa bile ertesi gün mutlaka MENTOR takvimine onay işaretinizi koyun!''';
  }
}
