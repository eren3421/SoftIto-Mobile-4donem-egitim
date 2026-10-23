const express = require('express');
const cors = require('cors');
const nodemailer = require('nodemailer');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = 3001;
const CONFIG_FILE = path.join(__dirname, 'mail_config.json');

app.use(cors());
app.use(express.json());

// Konfigürasyonu yükle
function loadConfig() {
  if (fs.existsSync(CONFIG_FILE)) {
    try {
      return JSON.parse(fs.readFileSync(CONFIG_FILE, 'utf8'));
    } catch (e) {
      console.error('Config okuma hatası:', e);
    }
  }
  return {
    smtpUser: process.env.SMTP_USER || '',
    smtpPass: process.env.SMTP_PASS || '',
    smtpServer: 'smtp.gmail.com',
    smtpPort: 465
  };
}

// Konfigürasyonu kaydet
function saveConfig(cfg) {
  fs.writeFileSync(CONFIG_FILE, JSON.stringify(cfg, null, 2), 'utf8');
}

// Durum sorgulama
app.get('/api/status', (req, res) => {
  const cfg = loadConfig();
  res.json({
    status: 'running',
    configured: Boolean(cfg.smtpUser && cfg.smtpPass),
    smtpUser: cfg.smtpUser ? cfg.smtpUser.replace(/(.{3})(.*)(@.*)/, '$1***$3') : null
  });
});

// Ayarları güncelleme
app.post('/api/config', (req, res) => {
  const { smtpUser, smtpPass } = req.body;
  if (!smtpUser || !smtpPass) {
    return res.status(400).json({ success: false, error: 'Kullanıcı adı ve şifre zorunludur.' });
  }

  const cleanPass = smtpPass.replace(/\s+/g, ''); // Google App Password aradaki boşlukları temizle
  const cfg = {
    smtpUser: smtpUser.trim(),
    smtpPass: cleanPass,
    smtpServer: 'smtp.gmail.com',
    smtpPort: 465
  };
  saveConfig(cfg);
  console.log(`[MAIL RELAY] E-posta ayarları güncellendi: ${cfg.smtpUser}`);
  res.json({ success: true, message: 'Ayarlar başarıyla kaydedildi.' });
});

// E-posta Gönderme Endpoint'i
app.post('/api/send-email', async (req, res) => {
  try {
    const { to, subject, html, text, otpCode, smtpUser, smtpPass } = req.body;

    if (!to) {
      return res.status(400).json({ success: false, error: 'Alıcı e-posta adresi (to) zorunludur.' });
    }

    const savedCfg = loadConfig();
    const user = smtpUser || savedCfg.smtpUser;
    const pass = (smtpPass || savedCfg.smtpPass || '').replace(/\s+/g, '');

    if (!user || !pass) {
      return res.status(400).json({
        success: false,
        error: 'E-posta gönderici hesabı (Gmail ve Google Uygulama Şifresi) ayarlanmamış.'
      });
    }

    // Nodemailer Gmail taşıyıcısı
    const transporter = nodemailer.createTransport({
      host: 'smtp.gmail.com',
      port: 465,
      secure: true, // SSL
      auth: {
        user: user,
        pass: pass
      }
    });

    const mailOptions = {
      from: `"MENTOR Alışkanlık Takibi" <${user}>`,
      to: to,
      subject: subject || 'MENTOR - Güvenlik ve Doğrulama Kodu',
      text: text || `MENTOR Doğrulama Kodunuz: ${otpCode}. Bu kod 5 dakika geçerlidir.`,
      html: html || `
        <div style="font-family: Arial, sans-serif; background-color: #12090E; padding: 28px; color: #FCE4EC; border-radius: 14px; max-width: 520px; margin: 0 auto;">
          <h2 style="color: #FF4081; margin: 0 0 6px 0; font-size: 24px; letter-spacing: 1px;">MENTOR</h2>
          <p style="font-size: 13px; color: #CE93D8; margin-top: 0;">Alışkanlık Takip ve Kişisel Gelişim Sistemi</p>
          <hr style="border: 0; border-top: 1px solid #C2185B; margin: 18px 0;" />
          <p style="font-size: 15px; line-height: 1.5;">Merhaba,</p>
          <p style="font-size: 14px; color: #F8BBD0; line-height: 1.5;">
            Hesabınızı doğrulamak veya şifrenizi yenilemek için tek seferlik güvenlik kodunuz aşağıdadır:
          </p>
          <div style="background-color: #1E1118; border: 2px dashed #FF4081; padding: 18px; text-align: center; font-size: 32px; font-weight: bold; letter-spacing: 8px; color: #FF4081; margin: 24px 0; border-radius: 10px;">
            ${otpCode}
          </div>
          <p style="font-size: 12px; color: #BCAAA4; line-height: 1.4;">
            ⏳ Bu kod güvenlik nedeniyle <strong>5 dakika</strong> boyunca geçerlidir.<br/>
            Eğer bu işlemi siz başlatmadıysanız bu e-postayı güvenle yok sayabilirsiniz.
          </p>
          <div style="margin-top: 24px; padding-top: 12px; border-top: 1px solid rgba(255,255,255,0.1); font-size: 11px; color: #795548;">
            MENTOR Otomatik E-posta Bildirim Servisi
          </div>
        </div>
      `
    };

    const info = await transporter.sendMail(mailOptions);
    console.log(`[MAIL RELAY] E-posta başarıyla gönderildi -> ${to} (MessageId: ${info.messageId})`);
    res.json({ success: true, messageId: info.messageId });
  } catch (error) {
    console.error('[MAIL RELAY] E-posta gönderim hatası:', error.message);
    res.status(500).json({
      success: false,
      error: error.message || 'E-posta gönderilirken hata oluştu.'
    });
  }
});

app.listen(PORT, () => {
  console.log(`[MAIL RELAY] E-posta köprüsü http://localhost:${PORT} üzerinde çalışıyor.`);
});
