import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_mate_app/app/constants.dart';

/// 다크 테마 (아쿠아·하늘색 계열)
/// Primary: 아쿠아/시안, Secondary: 스카이 블루, Accent: 틸
class AppColors {
  static const Color primary = Color(0xFF06B6D4);       // Cyan / Aqua
  static const Color primaryLight = Color(0xFF22D3EE);
  static const Color primaryDark = Color(0xFF0891B2);
  static const Color secondary = Color(0xFF0EA5E9);     // Sky Blue
  static const Color secondaryLight = Color(0xFF38BDF8);
  static const Color accent = Color(0xFF14B8A6);        // Teal
  static const Color background = Color(0xFF0A0A12);  // 224 71% 4%
  static const Color card = Color(0xFF0D0D18);         // 224 71% 6%
  static const Color surface = Color(0xFF12121F);
  static const Color error = Color(0xFFEF4444);
  static const Color onPrimary = Color(0xFFFAFAFA);
  static const Color onSecondary = Color(0xFF0A0A12);
  static const Color onBackground = Color(0xFFFAFAFA);
  static const Color onSurface = Color(0xFFFAFAFA);
  static const Color onError = Color(0xFFFAFAFA);
  static const Color textPrimary = Color(0xFFFAFAFA);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color muted = Color(0xFF27272A);
  static const Color border = Color(0xFF27272A);
  static const Color lightGrey = Color(0xFF3F3F46);
  static const Color darkGrey = Color(0xFF18181B);
  static const Color grey = Color(0xFF71717A);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFEAB308);
  static const Color info = Color(0xFF3B82F6);
}

/// 다크 네온 테마 (글래스 카드, 그라데이션 배경 느낌)
class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      cardColor: AppColors.card,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background.withOpacity(0.85),
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: BorderSide(color: Colors.white.withOpacity(0.15)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.secondary,
          textStyle: GoogleFonts.plusJakartaSans(fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        labelStyle: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary),
        hintStyle: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary.withOpacity(0.7)),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.outfit(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        displayMedium: GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        displaySmall: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        headlineMedium: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        headlineSmall: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        titleLarge: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        titleMedium: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
        titleSmall: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
        bodyLarge: GoogleFonts.plusJakartaSans(fontSize: 16, color: AppColors.textPrimary),
        bodyMedium: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textPrimary),
        bodySmall: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary),
        labelLarge: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      ),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.onPrimary,
        onSecondary: AppColors.onSecondary,
        onSurface: AppColors.onSurface,
        onError: AppColors.onError,
      ),
    );
  }
}
