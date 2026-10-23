import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

import '../../core/config/app_config.dart';
import '../local/hive_storage_service.dart';

class MailService {
  static final MailService instance = MailService._internal();
  MailService._internal();

  static const String localRelayUrl = 'http://localhost:3001/api/send-email';
  static const String localConfigUrl = 'http://localhost:3001/api/config';

  /// 6 haneli rastgele OTP kodu üretir (Debug kodunu sıfırlar)
  String generateOtp() {
    final random = Random();
    final otp = (100000 + random.nextInt(900000)).toString();
    AppConfig.latestDebugOtp = null; // Demo kodu ekranda göstermemek için null yap
    return otp;
  }

  /// E-posta konfigürasyonunu Hive ve yerel relay servisine kaydeder
  Future<bool> saveSmtpCredentials({
    required String email,
    required String appPassword,
  }) async {
    final cleanEmail = email.trim();
    final cleanPass = appPassword.replaceAll(' ', '').trim();

    // 1. Hive'a kaydet
    await HiveStorageService.instance.saveMailConfig({
      'smtpUser': cleanEmail,
      'smtpPass': cleanPass,
    });

    AppConfig.smtpUsername = cleanEmail;
    AppConfig.smtpPassword = cleanPass;

    // 2. Node.js yerel köprüsüne bildir
    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 4),
        receiveTimeout: const Duration(seconds: 4),
      ));
      await dio.post(localConfigUrl, data: {
        'smtpUser': cleanEmail,
        'smtpPass': cleanPass,
      });
      debugPrint('[MAIL SERVICE] Yerel relay e-posta ayarları kaydedildi.');
      return true;
    } catch (e) {
      debugPrint('[MAIL SERVICE] Relay config post uyarısı: $e');
      return true;
    }
  }

  /// Kayıtlı e-posta gönderici adresini döndürür
  String? getSavedSmtpUser() {
    final cfg = HiveStorageService.instance.getMailConfig();
    if (cfg != null && cfg['smtpUser'] != null) {
      return cfg['smtpUser'].toString();
    }
    if (AppConfig.smtpUsername.isNotEmpty) {
      return AppConfig.smtpUsername;
    }
    return null;
  }

  bool isConfigured() {
    final user = getSavedSmtpUser();
    final cfg = HiveStorageService.instance.getMailConfig();
    final pass = cfg?['smtpPass']?.toString() ?? AppConfig.smtpPassword;
    return user != null && user.isNotEmpty && pass.isNotEmpty;
  }

  /// Doğrulama kodunu gerçek e-posta servisi üzerinden iletir
  Future<bool> sendVerificationEmail({
    required String toEmail,
    required String otpCode,
    String subject = 'MENTOR - E-posta Doğrulama Kodu',
  }) async {
    final cleanTo = toEmail.trim();

    // Kodu doğrulanmak üzere yerel oturuma kaydet
    await HiveStorageService.instance.savePendingOtp(cleanTo, otpCode);

    debugPrint('====================================================');
    debugPrint('[MAIL SERVICE] Gerçek E-posta İletim İsteği: $cleanTo');
    debugPrint('====================================================');

    final cfg = HiveStorageService.instance.getMailConfig();
    final smtpUser = cfg?['smtpUser']?.toString() ?? AppConfig.smtpUsername;
    final smtpPass = cfg?['smtpPass']?.toString() ?? AppConfig.smtpPassword;

    // 1. ÖNCELİK: Yerel Node.js Mail Relay (http://localhost:3001)
    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ));

      final response = await dio.post(
        localRelayUrl,
        data: {
          'to': cleanTo,
          'otpCode': otpCode,
          'subject': subject,
          'smtpUser': smtpUser.isNotEmpty ? smtpUser : null,
          'smtpPass': smtpPass.isNotEmpty ? smtpPass : null,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        debugPrint('[MAIL SERVICE] Gerçek e-posta yerel köprü ile gönderildi: $cleanTo');
        return true;
      }
    } catch (e) {
      debugPrint('[MAIL SERVICE] Yerel relay denendi, hata/uyarı: $e');
    }

    // 2. ÖNCELİK: EmailJS REST API
    if (AppConfig.hasEmailJsConfig) {
      final success = await _sendViaEmailJs(
        toEmail: cleanTo,
        otpCode: otpCode,
        subject: subject,
      );
      if (success) {
        debugPrint('[MAIL SERVICE] EmailJS ile gerçek e-posta iletildi: $cleanTo');
        return true;
      }
    }

    // 3. ÖNCELİK: Doğrudan Native SMTP (Mobil / Masaüstü ortamlar için)
    if (!kIsWeb && smtpUser.isNotEmpty && smtpPass.isNotEmpty) {
      try {
        final smtpServer = SmtpServer(
          AppConfig.smtpServer,
          port: AppConfig.smtpPort,
          username: smtpUser,
          password: smtpPass,
          ssl: AppConfig.smtpPort == 465,
          allowInsecure: true,
        );

        final message = Message()
          ..from = Address(smtpUser, AppConfig.appName)
          ..recipients.add(cleanTo)
          ..subject = subject
          ..html = '''
            <div style="font-family: Arial, sans-serif; background-color: #12090E; padding: 24px; color: #FCE4EC; border-radius: 12px;">
              <h2 style="color: #FF4081; margin-bottom: 8px;">MENTOR</h2>
              <p style="font-size: 14px; color: #CE93D8;">Alışkanlık Takip ve Kişisel Gelişim Uygulaması</p>
              <hr style="border: 0; border-top: 1px solid #C2185B; margin: 16px 0;" />
              <p style="font-size: 16px;">Merhaba,</p>
              <p>Hesabınızı doğrulamak veya şifrenizi yenilemek için gerekli 6 haneli güvenlik kodunuz:</p>
              <div style="background-color: #1E1118; border: 2px dashed #FF4081; padding: 16px; text-align: center; font-size: 28px; font-weight: bold; letter-spacing: 6px; color: #FF4081; margin: 20px 0; border-radius: 8px;">
                $otpCode
              </div>
              <p style="font-size: 12px; color: #BCAAA4;">Bu kod 5 dakika boyunca geçerlidir. Eğer bu işlemi siz yapmadıysanız bu e-postayı dikkate almayınız.</p>
            </div>
          ''';

        await send(message, smtpServer);
        debugPrint('[MAIL SERVICE] SMTP e-postası başarıyla gönderildi: $cleanTo');
        return true;
      } catch (e) {
        debugPrint('[MAIL SERVICE] Native SMTP hatası: $e');
      }
    }

    // Gerçek e-posta gönderilemediyse kullanıcıya açık ve net hata bildir
    throw Exception(
      'Gerçek e-posta gönderilemedi! Lütfen e-posta servis ayarlarınızı (Gmail & Google Uygulama Şifresi) kontrol ediniz.',
    );
  }

  /// EmailJS HTTPS REST API üzerinden gerçek e-posta gönderimi
  Future<bool> _sendViaEmailJs({
    required String toEmail,
    required String otpCode,
    required String subject,
  }) async {
    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ));

      final response = await dio.post(
        AppConfig.emailJsEndpoint,
        data: {
          'service_id': AppConfig.emailJsServiceId.trim(),
          'template_id': AppConfig.emailJsTemplateId.trim(),
          'user_id': AppConfig.emailJsPublicKey.trim(),
          'template_params': {
            'to_email': toEmail,
            'email': toEmail,
            'to_name': toEmail.split('@').first,
            'otp_code': otpCode,
            'passcode': otpCode,
            'subject': subject,
            'message': 'MENTOR doğrulama kodunuz: $otpCode (5 dakika geçerlidir)',
          },
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[MAIL SERVICE] EmailJS API Hatası: $e');
      return false;
    }
  }

  /// Kullanıcının girdiği OTP kodunu doğrular
  bool verifyOtp(String email, String enteredOtp) {
    final pending = HiveStorageService.instance.getPendingOtp(email.trim());
    if (pending == null) {
      return false;
    }
    final isMatch = pending.trim() == enteredOtp.trim();
    if (isMatch) {
      HiveStorageService.instance.clearPendingOtp(email.trim());
    }
    return isMatch;
  }
}
