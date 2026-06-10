import 'package:flutter/material.dart';

abstract final class AppColors {
  // Backgrounds
  static const background = Color(0xFF09090F);
  static const surface = Color(0xFF0F0F1A);
  static const surfaceElevated = Color(0xFF161624);
  static const surfaceHighlight = Color(0xFF1E1E38);

  // Purple palette
  static const primary = Color(0xFF7C3AED);
  static const primaryLight = Color(0xFFA78BFA);
  static const primaryDark = Color(0xFF5B21B6);

  // Text
  static const textPrimary = Color(0xFFF0EEFF);
  static const textSecondary = Color(0xFF8B8BA8);
  static const textMuted = Color(0xFF4A4A6A);
  static const textOnPrimary = Color(0xFFFFFFFF);

  // Status
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);

  // Structural
  static const divider = Color(0xFF1A1A2E);
  static const border = Color(0xFF1E1E3A);
  static const borderHighlight = Color(0xFF7C3AED);
}

abstract final class AppTheme {
  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        brightness: Brightness.dark,
        primary: AppColors.primary,
        onPrimary: AppColors.textOnPrimary,
        secondary: AppColors.primaryLight,
        onSecondary: AppColors.textOnPrimary,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
        iconTheme: IconThemeData(color: AppColors.textSecondary),
        actionsIconTheme: IconThemeData(color: AppColors.textSecondary),
      ),
      cardTheme: CardTheme(
        color: AppColors.surfaceElevated,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceElevated,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 0,
      ),
      listTileTheme: const ListTileThemeData(
        textColor: AppColors.textPrimary,
        iconColor: AppColors.textSecondary,
        tileColor: Colors.transparent,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: CircleBorder(),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceHighlight,
        contentTextStyle: const TextStyle(color: AppColors.textPrimary),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        modalBackgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        elevation: 0,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: AppColors.textPrimary),
        displayMedium: TextStyle(color: AppColors.textPrimary),
        displaySmall: TextStyle(color: AppColors.textPrimary),
        headlineLarge: TextStyle(color: AppColors.textPrimary),
        headlineMedium: TextStyle(color: AppColors.textPrimary),
        headlineSmall: TextStyle(
            color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(
            color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(
            color: AppColors.textPrimary, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(color: AppColors.textSecondary),
        bodyLarge: TextStyle(color: AppColors.textPrimary),
        bodyMedium: TextStyle(color: AppColors.textPrimary),
        bodySmall: TextStyle(color: AppColors.textSecondary),
        labelLarge: TextStyle(
            color: AppColors.textPrimary, fontWeight: FontWeight.w500),
        labelMedium: TextStyle(color: AppColors.textSecondary),
        labelSmall: TextStyle(color: AppColors.textMuted),
      ),
    );
  }
}
