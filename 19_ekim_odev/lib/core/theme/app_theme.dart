import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Defter sayfalarına özel görsel özellikleri taşıyan tema uzantısı.
@immutable
class NotebookTheme extends ThemeExtension<NotebookTheme> {
  final Color notebookLineColor;
  final Color notebookMarginColor;
  final Color paperSurfaceColor;
  final Color inkColor;

  const NotebookTheme({
    required this.notebookLineColor,
    required this.notebookMarginColor,
    required this.paperSurfaceColor,
    required this.inkColor,
  });

  @override
  NotebookTheme copyWith({
    Color? notebookLineColor,
    Color? notebookMarginColor,
    Color? paperSurfaceColor,
    Color? inkColor,
  }) {
    return NotebookTheme(
      notebookLineColor: notebookLineColor ?? this.notebookLineColor,
      notebookMarginColor: notebookMarginColor ?? this.notebookMarginColor,
      paperSurfaceColor: paperSurfaceColor ?? this.paperSurfaceColor,
      inkColor: inkColor ?? this.inkColor,
    );
  }

  @override
  NotebookTheme lerp(ThemeExtension<NotebookTheme>? other, double t) {
    if (other is! NotebookTheme) {
      return this;
    }
    return NotebookTheme(
      notebookLineColor:
          Color.lerp(notebookLineColor, other.notebookLineColor, t) ??
              notebookLineColor,
      notebookMarginColor:
          Color.lerp(notebookMarginColor, other.notebookMarginColor, t) ??
              notebookMarginColor,
      paperSurfaceColor:
          Color.lerp(paperSurfaceColor, other.paperSurfaceColor, t) ??
              paperSurfaceColor,
      inkColor: Color.lerp(inkColor, other.inkColor, t) ?? inkColor,
    );
  }
}

/// Uygulama genelinde kullanılan Material 3 temaları (Aydınlık ve Koyu Defter Temaları).
abstract final class AppTheme {
  // Aydınlık Defter Teması
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightPaperBackground,
    colorScheme: const ColorScheme.light(
      primary: AppColors.lightLeatherBrown,
      onPrimary: Colors.white,
      secondary: AppColors.lightBookmarkGold,
      onSecondary: Colors.black,
      surface: AppColors.lightPaperSurface,
      onSurface: AppColors.lightInkPrimary,
      error: AppColors.error,
      outline: AppColors.lightNotebookLine,
      outlineVariant: AppColors.lightDivider,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightPaperBackground,
      foregroundColor: AppColors.lightInkPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.lightInkPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.lightPaperSurface,
      elevation: 1,
      shadowColor: AppColors.lightInkPrimary.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.lightDivider, width: 1),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.lightLeatherBrown,
      foregroundColor: Colors.white,
      elevation: 3,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.lightPaperBackground,
      selectedColor: AppColors.lightBookmarkGold.withValues(alpha: 0.25),
      labelStyle: const TextStyle(
        color: AppColors.lightInkPrimary,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      side: const BorderSide(color: AppColors.lightDivider),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.lightDivider,
      thickness: 1,
      space: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightPaperSurface,
      hintStyle: const TextStyle(
        color: AppColors.lightInkSecondary,
        fontSize: 14,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightNotebookLine),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightNotebookLine),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.lightLeatherBrown,
          width: 1.5,
        ),
      ),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        color: AppColors.lightInkPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        color: AppColors.lightInkPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: TextStyle(
        color: AppColors.lightInkPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: AppColors.lightInkPrimary,
        fontSize: 16,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        color: AppColors.lightInkPrimary,
        fontSize: 14,
        height: 1.45,
      ),
      bodySmall: TextStyle(
        color: AppColors.lightInkSecondary,
        fontSize: 12,
      ),
      labelMedium: TextStyle(
        color: AppColors.lightInkSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),
    extensions: const <ThemeExtension<dynamic>>[
      NotebookTheme(
        notebookLineColor: AppColors.lightNotebookLine,
        notebookMarginColor: AppColors.lightNotebookMargin,
        paperSurfaceColor: AppColors.lightPaperSurface,
        inkColor: AppColors.lightInkPrimary,
      ),
    ],
  );

  // Koyu Gece / Deri Cilt Teması
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkLeatherBackground,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkWarmAmber,
      onPrimary: AppColors.darkLeatherBackground,
      secondary: AppColors.darkLeatherAccent,
      onSecondary: Colors.white,
      surface: AppColors.darkPaperSurface,
      onSurface: AppColors.darkParchmentText,
      error: AppColors.error,
      outline: AppColors.darkNotebookLine,
      outlineVariant: AppColors.darkDivider,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkLeatherBackground,
      foregroundColor: AppColors.darkParchmentText,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.darkParchmentText,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkPaperSurface,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.darkDivider, width: 1),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.darkWarmAmber,
      foregroundColor: AppColors.darkLeatherBackground,
      elevation: 3,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.darkLeatherBackground,
      selectedColor: AppColors.darkWarmAmber.withValues(alpha: 0.25),
      labelStyle: const TextStyle(
        color: AppColors.darkParchmentText,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      side: const BorderSide(color: AppColors.darkDivider),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.darkDivider,
      thickness: 1,
      space: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkPaperSurface,
      hintStyle: const TextStyle(
        color: AppColors.darkParchmentSecondary,
        fontSize: 14,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkNotebookLine),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkNotebookLine),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.darkWarmAmber,
          width: 1.5,
        ),
      ),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        color: AppColors.darkParchmentText,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        color: AppColors.darkParchmentText,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: TextStyle(
        color: AppColors.darkParchmentText,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: AppColors.darkParchmentText,
        fontSize: 16,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        color: AppColors.darkParchmentText,
        fontSize: 14,
        height: 1.45,
      ),
      bodySmall: TextStyle(
        color: AppColors.darkParchmentSecondary,
        fontSize: 12,
      ),
      labelMedium: TextStyle(
        color: AppColors.darkParchmentSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),
    extensions: const <ThemeExtension<dynamic>>[
      NotebookTheme(
        notebookLineColor: AppColors.darkNotebookLine,
        notebookMarginColor: AppColors.darkNotebookMargin,
        paperSurfaceColor: AppColors.darkPaperSurface,
        inkColor: AppColors.darkParchmentText,
      ),
    ],
  );
}
