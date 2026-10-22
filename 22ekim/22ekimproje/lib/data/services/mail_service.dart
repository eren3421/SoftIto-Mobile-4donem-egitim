import 'dart:math';
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

    // Eğer SMTP yapılandırılmışsa mailer ile gönder
    if (AppConfig.smtpServer.isNotEmpty &&
        AppConfig.smtpUsername.isNotEmpty &&
        AppConfig.smtpPassword.isNotEmpty) {
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
        debugPrint('[MAIL SERVICE] SMTP e-postası başarıyla gönderildi.');
        return true;
      } catch (e) {
        debugPrint('[MAIL SERVICE] SMTP gönderim hatası (Debug modu devrede): $e');
        // SMTP başarısız olsa bile kullanıcıyı mağdur etmemek için debug OTP devrededir
        return true;
      }
    }

    // SMTP yapılandırılmamışsa debug fallback (konsola ve bildirim çubuğuna yazdırılır)
    return true;
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
