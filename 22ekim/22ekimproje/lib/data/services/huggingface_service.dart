import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../core/config/app_config.dart';

class HuggingFaceService {
  static final HuggingFaceService instance = HuggingFaceService._internal();
  HuggingFaceService._internal();

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  /// Akıl yürütme (Reasoning) modellerinden (DeepSeek R1 vb.) gelen `<think>` bloklarını temizler
  String _cleanModelOutput(String raw) {
    var cleaned = raw;
    // <think>...</think> bloklarını içerikleriyle birlikte temizle
    cleaned = cleaned.replaceAll(
      RegExp(r'<think>[\s\S]*?<\/think>', caseSensitive: false),
      '',
    );
    // Eğer model token sınırına ulaştığı için kapanış etiketi yoksa kalan kısmı temizle
    if (cleaned.contains('<think>')) {
      cleaned = cleaned.replaceAll(
        RegExp(r'<think>[\s\S]*', caseSensitive: false),
        '',
      );
    }
    return cleaned.trim();
  }

  /// Hugging Face / Groq / OpenRouter Chat Completions API Çağrısı
  Future<String?> _callHfChatCompletion({
    required String model,
    required String token,
    required List<Map<String, String>> messages,
    int maxTokens = 2048,
    double temperature = 0.55,
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
          return _cleanModelOutput(content);
        }
      }
    }
    return null;
  }

  List<String>? _cachedGroqModels;

  /// Groq API üzerinde şu an aktif olan modelleri dinamik olarak çeker
  Future<List<String>> _getGroqModels(String token) async {
    if (_cachedGroqModels != null && _cachedGroqModels!.isNotEmpty) {
      return _cachedGroqModels!;
    }

    try {
      final res = await _dio.get(
        'https://api.groq.com/openai/v1/models',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (res.statusCode == 200 && res.data != null) {
        final data = res.data['data'] as List?;
        if (data != null && data.isNotEmpty) {
          final models = <String>[];
          for (final item in data) {
            final id = item['id'] as String?;
            if (id == null) continue;
            final lower = id.toLowerCase();
            // Ses ve moderasyon modellerini hariç tut
            if (lower.contains('whisper') ||
                lower.contains('orpheus') ||
                lower.contains('guard') ||
                lower.contains('safeguard')) {
              continue;
            }
            models.add(id);
          }

          if (models.isNotEmpty) {
            // Hızlı ve akıcı modelleri öne sırala
            models.sort((a, b) {
              final aScore = a.contains('llama-3.3-70b')
                  ? 5
                  : (a.contains('llama-3.1-8b')
                      ? 4
                      : (a.contains('120b')
                          ? 3
                          : (a.contains('70b') ? 2 : 1)));
              final bScore = b.contains('llama-3.3-70b')
                  ? 5
                  : (b.contains('llama-3.1-8b')
                      ? 4
                      : (b.contains('120b')
                          ? 3
                          : (b.contains('70b') ? 2 : 1)));
              return bScore.compareTo(aScore);
            });

            _cachedGroqModels = models;
            debugPrint('[HuggingFaceService] Groq modelleri optimize edildi: $models');
            return models;
          }
        }
      }
    } catch (e) {
      debugPrint('[HuggingFaceService] Groq model listesi çekilemedi: $e');
    }

    return [
      'llama-3.3-70b-versatile',
      'llama-3.1-8b-instant',
      'openai/gpt-oss-120b',
      'deepseek-r1-distill-llama-70b',
    ];
  }

  /// AI Mentor / Chatbot Mesaj Gönderimi (Optimize Edilmiş Kişiselleştirilmiş İstem)
  Future<String> sendMessage({
    required String userMessage,
    String? username,
    String? focusedHabitTitle,
    String? todayCompletionStatus,
    required String habitContext,
    required String notesContext,
    List<Map<String, String>> previousMessages = const [],
  }) async {
    final token = AppConfig.huggingFaceToken.trim();

    if (!AppConfig.hasValidHfToken) {
      return '⚠️ Canlı Yapay Zeka Modeli Bağlantısı Gerekli!\n\n'
          'Arka planda hazır cevap stoğu yerine doğrudan açık kaynaklı bir yapay zeka modelinin '
          'çalışıp sorularınıza dinamik cevap üretebilmesi için geçerli bir API anahtarı girilmelidir.\n\n'
          '📌 Nasıl Bağlanırsınız?\n'
          '1. console.groq.com/keys adresinden 10 saniyede ücretsiz bir Groq API Key (gsk_...) alın (Önerilen).\n'
          '   (Veya huggingface.co/settings/tokens üzerinden token alın).\n'
          '2. Sağ üstteki 🔑 (Anahtar) simgesine tıklayıp anahtarınızı kaydedin.\n\n'
          'Anahtar kaydedildiğinde tüm sorularınız anlık olarak arkadaki yapay zeka modeline gönderilecek ve canlı yanıtlar üretilecektir.';
    }

    try {
      // 1. Bilimsel ve Davranışsal Sistem İstemini Oluştur
      final systemPrompt = AppConfig.buildMentorSystemPrompt(
        username: username ?? 'Kullanıcı',
        habitsSummary: habitContext,
        recentNotes: notesContext,
        focusedHabitTitle: focusedHabitTitle,
        todayCompletionStatus: todayCompletionStatus,
      );

      // 2. Kayan Pencere (Rolling Context): Son 8 mesajı alarak token sınırını koru
      final optimizedHistory = previousMessages.length > 8
          ? previousMessages.sublist(previousMessages.length - 8)
          : previousMessages;

      final messages = [
        {'role': 'system', 'content': systemPrompt},
        ...optimizedHistory,
        {'role': 'user', 'content': userMessage},
      ];

      // 3. Dinamik Model Listesi
      List<String> modelsToTry;
      if (token.startsWith('gsk_')) {
        modelsToTry = await _getGroqModels(token);
      } else if (token.startsWith('sk-or-')) {
        modelsToTry = [
          'meta-llama/llama-3.3-70b-instruct:free',
          'google/gemini-2.0-flash-exp:free',
          'deepseek/deepseek-r1:free',
          'qwen/qwen-2.5-72b-instruct:free',
        ];
      } else {
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
            maxTokens: 2048,
            temperature: 0.55, // Daha odaklı ve tutarlı koçluk için 0.55
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
          lastErrorDetail =
              'HTTP $statusCode: ${dioErr.response?.data?['error']?['message'] ?? dioErr.response?.data?['error'] ?? dioErr.message}';
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

      return '⚠️ Yapay Zeka Modeline Ulaşılamadı:\n\n'
          'Arka plandaki model uç noktaları denendi ancak yanıt alınamadı.\n'
          'Detay: ${lastErrorDetail ?? 'Servis meşgul veya zaman aşımı.'}\n\n'
          'Lütfen internet bağlantınızı ve sağ üstteki 🔑 token bilginizi kontrol edip tekrar deneyiniz.';
    } catch (e) {
      debugPrint('[HuggingFaceService] Genel Hata: $e');
      return '⚠️ Yapay Zeka Bağlantı Hatası: $e\nLütfen tekrar deneyiniz.';
    }
  }

  /// PDF Raporları İçin Kişiye Özel Derinlemesine Uzman Görüşü Üretimi
  Future<String> generateExpertEvaluation({
    String? username,
    String? habitTitle,
    required int streak,
    required int longestStreak,
    required double weeklyRate,
    required double monthlyRate,
    List<String> notes = const [],
    bool isCompletedToday = false,
    String? dayPatternsSummary,
  }) async {
    final token = AppConfig.huggingFaceToken.trim();
    final effectiveUsername = username ?? 'Kullanıcı';
    final habitName = habitTitle ?? 'Tüm Alışkanlık Portföyü';
    final weeklyPercent = (weeklyRate * 100).toStringAsFixed(1);
    final monthlyPercent = (monthlyRate * 100).toStringAsFixed(1);
    final notesSummary = notes.isEmpty
        ? 'Dönem içinde girilmiş özel yansıma notu bulunmuyor.'
        : notes.take(4).map((n) => '"$n"').join('; ');

    if (!AppConfig.hasValidHfToken) {
      return generateLocalExpertEvaluation(
        username: effectiveUsername,
        habitName: habitName,
        streak: streak,
        longestStreak: longestStreak,
        weeklyPercent: weeklyPercent,
        monthlyPercent: monthlyPercent,
        notesSummary: notesSummary,
        isCompletedToday: isCompletedToday,
        dayPatternsSummary: dayPatternsSummary,
      );
    }

    try {
      final prompt = AppConfig.buildPdfExpertOpinionPrompt(
        username: effectiveUsername,
        reportScopeTitle: habitName,
        streak: streak,
        longestStreak: longestStreak,
        weeklyPercent: weeklyPercent,
        monthlyPercent: monthlyPercent,
        notesSummary: notesSummary,
        isCompletedToday: isCompletedToday,
        dayPatternsSummary: dayPatternsSummary,
      );

      final messages = [
        {
          'role': 'system',
          'content':
              'Sen davranış psikolojisi ve nöroplastisite uzmanı kıdemli bir analistsin. Raporlarını daima derinlemesine, veriye dayalı ve kişiye özel yazarsın.',
        },
        {'role': 'user', 'content': prompt},
      ];

      List<String> modelsToTry;
      if (token.startsWith('gsk_')) {
        modelsToTry = await _getGroqModels(token);
      } else if (token.startsWith('sk-or-')) {
        modelsToTry = [
          'meta-llama/llama-3.3-70b-instruct:free',
          'google/gemini-2.0-flash-exp:free',
        ];
      } else {
        modelsToTry = [
          AppConfig.selectedHfModel,
          ...AppConfig.fallbackHfModels,
        ];
      }

      for (final model in modelsToTry) {
        try {
          final reply = await _callHfChatCompletion(
            model: model,
            token: token,
            messages: messages,
            maxTokens: 1600,
            temperature: 0.50, // Resmi raporlar için maksimum tutarlılık
          );

          if (reply != null && reply.trim().isNotEmpty) {
            return reply;
          }
        } catch (e) {
          debugPrint('[HuggingFaceService] PDF Değerlendirme ($model) Hatası: $e');
        }
      }

      return generateLocalExpertEvaluation(
        username: effectiveUsername,
        habitName: habitName,
        streak: streak,
        longestStreak: longestStreak,
        weeklyPercent: weeklyPercent,
        monthlyPercent: monthlyPercent,
        notesSummary: notesSummary,
        isCompletedToday: isCompletedToday,
        dayPatternsSummary: dayPatternsSummary,
      );
    } catch (e) {
      debugPrint('[HuggingFaceService] Uzman Görüşü API Hatası: $e');
      return generateLocalExpertEvaluation(
        username: effectiveUsername,
        habitName: habitName,
        streak: streak,
        longestStreak: longestStreak,
        weeklyPercent: weeklyPercent,
        monthlyPercent: monthlyPercent,
        notesSummary: notesSummary,
        isCompletedToday: isCompletedToday,
        dayPatternsSummary: dayPatternsSummary,
      );
    }
  }

  // ===================== KİŞİYE ÖZEL YEREL RAPOR DEĞERLENDİRMESİ =====================

  String generateLocalExpertEvaluation({
    required String username,
    required String habitName,
    required int streak,
    required int longestStreak,
    required String weeklyPercent,
    required String monthlyPercent,
    required String notesSummary,
    bool isCompletedToday = false,
    String? dayPatternsSummary,
  }) {
    final double weeklyVal = double.tryParse(weeklyPercent) ?? 0.0;
    final streakEval = streak >= longestStreak && streak > 0
        ? 'Şu anda $streak günlük kesintisiz serinizle kendi tüm zamanlar rekorunuza ulaşmış durumdasınız.'
        : 'Mevcut $streak günlük zinciriniz, geçmişteki $longestStreak günlük en uzun zirve serinize yaklaşmaktadır.';

    final neuralPhase = weeklyVal >= 80.0
        ? 'Veriler, beynin bazal ganglionlarındaki nöral otomatikleşme sürecinin yüksek olgunluk evresine (%$weeklyPercent) ulaştığını göstermektedir. Eylem artık bir irade mücadelesi olmaktan çıkıp kimliğinizin doğal bir parçası haline gelmiştir.'
        : weeklyVal >= 50.0
            ? 'Haftalık %$weeklyPercent başarı oranı, nörolojik adaptasyonun pekişme aşamasında olduğunu kanıtlamaktadır. Rutin yerleşmekte ancak stresli veya yoğun günlerde dikkat dağıtıcı etkilere karşı koruma protokollerine ihtiyaç duymaktadır.'
            : 'Mevcut %$weeklyPercent başarı oranı, alışkanlığın henüz direnç kırma evresinde olduğunu işaret etmektedir. Bu evrede büyük hedefler koymak yerine eylemi küçültmek kritiktir.';

    final todayReflection = isCompletedToday
        ? 'Bugünkü takvim onayının verilmiş olması, günün momentumunu lehinize çevirmiştir.'
        : 'Bugünkü eylemin henüz tamamlanmamış olması, gün bitmeden uygulanacak 2 dakikalık sembolik bir versiyonla telafi edilmelidir.';

    final dayPatternText = (dayPatternsSummary != null && dayPatternsSummary.isNotEmpty)
        ? '\n\nZaman ve Gün Örüntüsü Analizi:\n$dayPatternsSummary Bu örüntü, motivasyonun haftanın belirli evrelerinde dalgalandığını ve en çok aksatılan güne özel bir önleyici koruma kalkanı kurulması gerektiğini açıkça ortaya koymaktadır.'
        : '';

    return '''1. Nörolojik & Davranışsal Durum Analizi:
Sayın $username, "$habitName" odağında kaydedilen verileriniz incelendiğinde; $streakEval $neuralPhase Son 30 günlük genel istikrarınız %$monthlyPercent bandında seyretmektedir. $todayReflection$dayPatternText

2. Güçlü Yönler & Kritik Risk Noktaları:
En belirgin güçlü yönünüz, rutini takip etme bilinciniz ve kişisel kayıt tutma refleksinizdir. Notlarınızda yer alan içgörüler ($notesSummary), süreç farkındalığınızın yüksek olduğunu doğrulamaktadır. Kritik risk faktörü ise beklenmeyen program değişikliklerinde veya motivasyonun düştüğü anlarda zincirin kırılabilmesidir. Zirve seriniz ($longestStreak gün) potansiyelinizin kanıtıdır.

3. Zinciri Korumak İçin 3 Kişiselleştirilmiş Strateji:
• Zayıf Gün / Hafta Sonu Koruma Protokolü: En çok aksatılan gününüzde eylemi tamamen iptal etmek yerine, sadece 2 dakikalık sembolik versiyonunu uygulayın; çünkü en kötü tekrar bile yapılmayanından kat kat değerlidir.
• Alışkanlık İstifleme (Habit Stacking): Bu hedefi gün içinde mutlaka yaptığınız bir başka otomatik eylemin hemen ardına bağlayın (Örn: "Sabah kahvemi aldıktan hemen sonra 10 dakika $habitName ile ilgileneceğim").
• İki Gün Kuralı: Hayat planlarınıza müdahale edebilir, ancak asla üst üste iki gün zincirin boş geçmesine izin vermeyin. Bir gün kaçsa bile ertesi gün ne olursa olsun işaretinizi koyun!''';
  }
}
