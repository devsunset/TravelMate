import 'package:flutter/material.dart';
import 'package:travel_mate_app/app/constants.dart';

/// 앱 공통 색상 정의(primary, accent, 배경, 텍스트, 성공/경고/에러 등).
class AppColors {
  static const Color primary = Color(0xFF6200EE);
  static const Color primaryLight = Color(0xFFBB86FC);
  static const Color primaryDark = Color(0xFF3700B3);
  static const Color accent = Color(0xFF03DAC6);
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFB00020);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFF000000);
  static const Color onBackground = Color(0xFF000000);
  static const Color onSurface = Color(0xFF000000);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color darkGrey = Color(0xFF424242);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);
}

/// 라이트 테마(앱바, 버튼, 입력 필드, 텍스트 스타일).
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primary,
      hintColor: AppColors.accent,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        color: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 4,
        centerTitle: true,
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: AppColors.primary,
        textTheme: ButtonTextTheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accent,
          textStyle: const TextStyle(
            fontSize: 16,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightGrey.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide(color: AppColors.grey.withOpacity(0.5), width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: TextStyle(color: AppColors.textSecondary),
        hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.6)),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 96.0, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        displayMedium: TextStyle(fontSize: 60.0, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        displaySmall: TextStyle(fontSize: 48.0, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        headlineMedium: TextStyle(fontSize: 34.0, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        headlineSmall: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        titleLarge: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        titleMedium: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
        titleSmall: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
        bodyLarge: TextStyle(fontSize: 16.0, color: AppColors.textPrimary),
        bodyMedium: TextStyle(fontSize: 14.0, color: AppColors.textPrimary),
        labelLarge: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        bodySmall: TextStyle(fontSize: 12.0, color: AppColors.textSecondary),
        labelSmall: TextStyle(fontSize: 10.0, color: AppColors.textSecondary),
      ),
    );
  }
}
