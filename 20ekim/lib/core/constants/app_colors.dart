import 'package:flutter/material.dart';

/// Uygulama genelinde kullanılan renk paleti sabitleri.
/// Klasik Defter ve Gece Okuma deri paleti değerlerini içerir.
abstract final class AppColors {
  // Aydınlık Mod (Klasik Defter Paleti)
  static const Color lightBackground = Color(0xFFFAF6F0);
  static const Color lightSurface = Color(0xFFF3EDE2);
  static const Color lightSurfaceAlt = Color(0xFFEBE2D3);
  static const Color lightTextPrimary = Color(0xFF2C221E);
  static const Color lightTextSecondary = Color(0xFF6B584E);
  static const Color lightBorder = Color(0xFFE3D6C2);
  static const Color lightDivider = Color(0xFFDFCFB8);

  // Koyu Mod (Gece Okuma & Deri Kapak Paleti)
  static const Color darkBackground = Color(0xFF181512);
  static const Color darkSurface = Color(0xFF241F1A);
  static const Color darkSurfaceAlt = Color(0xFF2E2721);
  static const Color darkTextPrimary = Color(0xFFE6DEC8);
  static const Color darkTextSecondary = Color(0xFFA89F8B);
  static const Color darkBorder = Color(0xFF3D342B);
  static const Color darkDivider = Color(0xFF382F26);

  // Vurgu ve Marka Renkleri
  static const Color primaryLeather = Color(0xFF8B5A2B);
  static const Color primaryLeatherLight = Color(0xFFA6743D);
  static const Color primaryLeatherDark = Color(0xFF5D3B1C);

  static const Color accentGold = Color(0xFFD4AF37);
  static const Color accentAmber = Color(0xFFE09F3E);
  static const Color accentParchment = Color(0xFFE6DEC8);

  // Durum Renkleri (Finans, Uyarı ve Bilgilendirme)
  static const Color incomeGreen = Color(0xFF2E7D32);
  static const Color incomeGreenLight = Color(0xFF4CAF50);
  static const Color expenseRed = Color(0xFFC62828);
  static const Color expenseRedLight = Color(0xFFE53935);
  static const Color meetingBlue = Color(0xFF1E88E5);
  static const Color statusPending = Color(0xFFF57C00);

  // Kağıt ve Şerit Süslemeleri
  static const Color paperLine = Color(0xFFDCD2C0);
  static const Color bookmarkRibbon = Color(0xFFB71C1C);
  static const Color shadowColor = Color(0x1F2C221E);
}
