import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.obsidianGrey,
      primaryColor: AppColors.crimsonPrimary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.crimsonPrimary,
        primaryContainer: AppColors.crimsonSurface,
        secondary: AppColors.crimsonAccent,
        secondaryContainer: AppColors.slateCardGrey,
        surface: AppColors.charcoalGrey,
        error: AppColors.statusRed,
        onPrimary: AppColors.platinumText,
        onSecondary: AppColors.platinumText,
        onSurface: AppColors.platinumText,
        outline: AppColors.steelBorderGrey,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.charcoalGrey,
        foregroundColor: AppColors.platinumText,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 2,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.slateCardGrey,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.radiusLg,
          side: BorderSide(color: AppColors.steelBorderGrey, width: 1),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.charcoalGrey,
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.radiusXl,
          side: BorderSide(color: AppColors.steelBorderGrey, width: 1),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.charcoalGrey,
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.gunmetalGrey,
        hintStyle: const TextStyle(color: AppColors.mutedGreyText, fontSize: 13),
        labelStyle: const TextStyle(color: AppColors.silverText, fontSize: 13),
        prefixIconColor: AppColors.silverText,
        suffixIconColor: AppColors.silverText,
        border: OutlineInputBorder(
          borderRadius: AppSpacing.radiusMd,
          borderSide: const BorderSide(color: AppColors.steelBorderGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.radiusMd,
          borderSide: const BorderSide(color: AppColors.steelBorderGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.radiusMd,
          borderSide: const BorderSide(color: AppColors.crimsonAccent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.radiusMd,
          borderSide: const BorderSide(color: AppColors.statusRed),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.crimsonPrimary,
          foregroundColor: AppColors.platinumText,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: AppSpacing.radiusMd),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.platinumText,
          side: const BorderSide(color: AppColors.steelBorderGrey),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: AppSpacing.radiusMd),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.slateCardGrey,
        selectedColor: AppColors.crimsonAccent,
        side: const BorderSide(color: AppColors.steelBorderGrey),
        labelStyle: const TextStyle(color: AppColors.platinumText, fontSize: 12),
        secondaryLabelStyle: const TextStyle(color: AppColors.platinumText),
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.radiusSm),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.charcoalGrey,
        indicatorColor: AppColors.crimsonPrimary,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: AppColors.platinumText, fontSize: 12, fontWeight: FontWeight.w600);
          }
          return const TextStyle(color: AppColors.silverText, fontSize: 12);
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.steelBorderGrey,
        thickness: 0.8,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightScaffoldBg,
      primaryColor: AppColors.crimsonPrimary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.crimsonPrimary,
        primaryContainer: Color(0xFFFFEBEE),
        secondary: AppColors.crimsonAccent,
        secondaryContainer: AppColors.lightInputBg,
        surface: AppColors.lightSurface,
        error: AppColors.statusRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.lightTextPrimary,
        outline: AppColors.lightBorder,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 2,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.lightCardBg,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.radiusLg,
          side: BorderSide(color: AppColors.lightBorder, width: 1),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.lightSurface,
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.radiusXl,
          side: BorderSide(color: AppColors.lightBorder, width: 1),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.lightSurface,
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightInputBg,
        hintStyle: const TextStyle(color: AppColors.lightTextSecondary, fontSize: 13),
        labelStyle: const TextStyle(color: AppColors.lightTextSecondary, fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: AppSpacing.radiusMd,
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.radiusMd,
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.radiusMd,
          borderSide: const BorderSide(color: AppColors.crimsonAccent, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.crimsonPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: AppSpacing.radiusMd),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightInputBg,
        selectedColor: AppColors.crimsonPrimary,
        side: const BorderSide(color: AppColors.lightBorder),
        labelStyle: const TextStyle(color: AppColors.lightTextPrimary, fontSize: 12),
        secondaryLabelStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.radiusSm),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        indicatorColor: Color(0xFFFFCDD2),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightBorder,
        thickness: 0.8,
      ),
    );
  }
}
