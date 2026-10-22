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

  /// 6 haneli rastgele OTP kodu üretir
  String generateOtp() {
    final random = Random();
    final otp = (100000 + random.nextInt(900000)).toString();
    AppConfig.latestDebugOtp = otp;
    return otp;
  }

  /// Doğrulama kodunu e-posta adresine gönderir
  Future<bool> sendVerificationEmail({
    required String toEmail,
    required String otpCode,
    String subject = 'MENTOR - E-posta Doğrulama Kodu',
  }) async {
    // Kodu yerel session'a kaydet
    await HiveStorageService.instance.savePendingOtp(toEmail, otpCode);

    debugPrint('====================================================');
    debugPrint('[MAIL SERVICE] Gönderilen E-posta: $toEmail');
    debugPrint('[MAIL SERVICE] Doğrulama Kodu (OTP): $otpCode');
    debugPrint('====================================================');

    // 1. EmailJS REST API Kontrolü (Web & Mobil için en ideal, doğrudan HTTPS ile Gmail'e iletir)
    if (AppConfig.hasEmailJsConfig) {
      final success = await _sendViaEmailJs(
        toEmail: toEmail,
        otpCode: otpCode,
        subject: subject,
      );
      if (success) {
        debugPrint('[MAIL SERVICE] EmailJS ile gerçek e-posta başarıyla iletildi: $toEmail');
        // Gerçek e-posta başarıyla gittiğinde debug kodunu gizle
        AppConfig.latestDebugOtp = null;
        return true;
      } else {
        debugPrint('[MAIL SERVICE] EmailJS başarısız oldu, SMTP veya Debug moduna geçiliyor.');
      }
    }

    // 2. SMTP Mailer Kontrolü (Web harici Masaüstü/Mobil ortamlar için)
    if (!kIsWeb && AppConfig.hasSmtpConfig) {
      try {
        final smtpServer = SmtpServer(
          AppConfig.smtpServer,
          port: AppConfig.smtpPort,
          username: AppConfig.smtpUsername,
          password: AppConfig.smtpPassword,
          ssl: AppConfig.smtpPort == 465,
          allowInsecure: true,
        );

        final message = Message()
          ..from = Address(AppConfig.smtpSenderEmail, AppConfig.appName)
          ..recipients.add(toEmail)
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
        debugPrint('[MAIL SERVICE] SMTP e-postası başarıyla gönderildi: $toEmail');
        AppConfig.latestDebugOtp = null;
        return true;
      } catch (e) {
        debugPrint('[MAIL SERVICE] SMTP gönderim hatası (Debug modu devrede): $e');
      }
    }

    // Gerçek e-posta servisi ayarlanmadıysa veya başarısız olduysa test kodunu açık tut
    debugPrint('[MAIL SERVICE] Gerçek e-posta servisi ayarlanmadığı için Test Kodu devrede.');
    return true;
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
    final pending = HiveStorageService.instance.getPendingOtp(email);
    if (pending == null) {
      // Yedek kontrol: Eğer debug OTP ile birebir eşleşiyorsa izin ver
      if (AppConfig.latestDebugOtp != null &&
          AppConfig.latestDebugOtp == enteredOtp.trim()) {
        return true;
      }
      return false;
    }
    final isMatch = pending.trim() == enteredOtp.trim();
    if (isMatch) {
      HiveStorageService.instance.clearPendingOtp(email);
    }
    return isMatch;
  }
}
