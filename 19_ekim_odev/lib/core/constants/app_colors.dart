import 'package:flutter/material.dart';

/// Defterim uygulaması için gerçek defter ve parşömen dokulu renk paleti.
/// project.md belgesindeki Aydınlık ve Koyu Mod kurallarına birebir uygundur.
abstract final class AppColors {
  // Aydınlık Mod (Klasik Defter Paleti)
  static const Color lightPaperBackground = Color(0xFFFAF6F0);
  static const Color lightPaperSurface = Color(0xFFFFFDF9);
  static const Color lightInkPrimary = Color(0xFF2C221E);
  static const Color lightInkSecondary = Color(0xFF6B5B52);
  static const Color lightLeatherBrown = Color(0xFF8B5A2B);
  static const Color lightBookmarkGold = Color(0xFFD4AF37);
  static const Color lightNotebookLine = Color(0xFFE2D9CC);
  static const Color lightNotebookMargin = Color(0xFFE8B4AA);
  static const Color lightDivider = Color(0xFFEADBCE);

  // Koyu Mod (Gece Okuma & Deri Kapak Paleti)
  static const Color darkLeatherBackground = Color(0xFF181512);
  static const Color darkPaperSurface = Color(0xFF241F1A);
  static const Color darkParchmentText = Color(0xFFE6DEC8);
  static const Color darkParchmentSecondary = Color(0xFFA89F8B);
  static const Color darkWarmAmber = Color(0xFFE09F3E);
  static const Color darkLeatherAccent = Color(0xFF8B5A2B);
  static const Color darkNotebookLine = Color(0xFF383129);
  static const Color darkNotebookMargin = Color(0xFF5A443B);
  static const Color darkDivider = Color(0xFF332B24);

  // Mood / Duygu Durumu Renkleri
  static const Color moodPeaceful = Color(0xFF588157); // Huzurlu
  static const Color moodHappy = Color(0xFFE09F3E); // Mutlu
  static const Color moodThoughtful = Color(0xFF3D5A80); // Düşünceli
  static const Color moodSad = Color(0xFF7A8288); // Hüzünlü
  static const Color moodExcited = Color(0xFFC85A32); // Heyecanlı

  // Yardımcı Vurgu Renkleri
  static const Color favoriteActive = Color(0xFFD4AF37);
  static const Color error = Color(0xFFBA1A1A);
}
