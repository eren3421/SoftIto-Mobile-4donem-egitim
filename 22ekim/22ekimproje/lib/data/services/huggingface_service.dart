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

  /// AI Mentor / Chatbot Mesaj Gönderimi
  Future<String> sendMessage({
    required String userMessage,
    required String habitContext,
    required String notesContext,
    List<Map<String, String>> previousMessages = const [],
  }) async {
    final token = AppConfig.huggingFaceToken.trim();

    if (token.isEmpty) {
      return _generateLocalMentorResponse(
        userMessage: userMessage,
        habitContext: habitContext,
      );
    }

    try {
      final systemPrompt =
          '''Sen MENTOR uygulamasının empatik, motive edici ve disiplinli yapay zeka alışkanlık koçusun. 
Kullanıcının mevcut alışkanlık verileri: $habitContext. 
Kullanıcının aldığı son notlar: $notesContext. 
Kullanıcıya daima Türkçe, yapıcı, mikro adımlara odaklanan ve motivasyonunu artıran samimi yanıtlar ver. Yanıtların çok uzun olmasın, uygulanabilir olsun.''';

      final messages = [
        {'role': 'system', 'content': systemPrompt},
        ...previousMessages,
        {'role': 'user', 'content': userMessage},
      ];

      final response = await _dio.post(
        AppConfig.hfChatEndpoint,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
        data: {
          'model': 'mistralai/Mistral-7B-Instruct-v0.3',
          'messages': messages,
          'max_tokens': 600,
          'temperature': 0.7,
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
      return _generateLocalMentorResponse(
        userMessage: userMessage,
        habitContext: habitContext,
      );
    } catch (e) {
      debugPrint('[HuggingFaceService] API Çağrısı Başarısız (Yedek Yanıt Devrede): $e');
      return _generateLocalMentorResponse(
        userMessage: userMessage,
        habitContext: habitContext,
      );
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

    if (token.isEmpty) {
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

      final response = await _dio.post(
        AppConfig.hfChatEndpoint,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
        data: {
          'model': 'mistralai/Mistral-7B-Instruct-v0.3',
          'messages': [
            {'role': 'system', 'content': 'Sen kıdemli bir davranış bilimci ve MENTOR uzmanısın.'},
            {'role': 'user', 'content': prompt},
          ],
          'max_tokens': 800,
          'temperature': 0.65,
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

  // ===================== RESILIENT LOCAL FALLBACKS =====================

  String _generateLocalMentorResponse({
    required String userMessage,
    required String habitContext,
  }) {
    final lower = userMessage.toLowerCase();

    if (lower.contains('motivasyon') || lower.contains('bırakmak') || lower.contains('zor')) {
      return 'Unutma ki büyük değişimler küçük ve ısrarcı adımlarla gerçekleşir! Zinciri kırmamak için hedefini mikro parçalara böl (örneğin sadece 5 dakika odaklan). $habitContext verilerine göre harika bir potansiyelin var. Bugün yapacağın tek bir dokunuş bile yarınki seni inşa ediyor!';
    } else if (lower.contains('streak') || lower.contains('zincir')) {
      return 'Zincir (Streak) disiplini, beynindeki nöronal yolları pekiştirir. Bir gün aksatsan bile ikinci gün kesinlikle geri dön. İki gün üst üste kaçırmamak altın kuraldır!';
    } else if (lower.contains('tavsiye') || lower.contains('öneri')) {
      return 'Alışkanlıklarını mevcut rutinlerine bağla (Örn: "Sabah kahvemi içerken kitabımı açacağım"). Bu tetikleyici bağlama yöntemi, irade gücüne olan bağımlılığı %60 oranında azaltır. Notlar bölümüne her gün hissettiklerini yazmayı ihmal etme!';
    } else {
      return 'Harika bir soru! MENTOR olarak gelişimini yakından takip ediyorum. Alışkanlıklarındaki mevcut durum ($habitContext) gösteriyor ki istikrarlı adımlarla hedefine yaklaşıyorsun. Sana tavsiyem, günün en sakin saatinde belirlediğin hedefe odaklanman ve başarıyı kutlaman!';
    }
  }

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
