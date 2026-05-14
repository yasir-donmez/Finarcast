import 'package:flutter/material.dart';
import 'app_constants.dart';

class AppTheme {
  /// Premium Glassmorphism - Karanlık Tema
  static ThemeData buildDarkTheme(Color accentColor) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: ColorScheme.dark(
        primary: accentColor,
        onPrimary: Colors.white,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        error: AppColors.error,
      ),
      textTheme: _buildTextTheme(
        Typography.material2021(platform: TargetPlatform.android).white,
        AppColors.darkTextPrimary,
        AppColors.darkTextSecondary,
      ),
      iconTheme: const IconThemeData(color: AppColors.darkTextSecondary, size: 24),
    );
  }

  /// Premium Glassmorphism - Aydınlık Tema
  static ThemeData buildLightTheme(Color accentColor) {
    // Aydınlık modda okunabilirliği artırmak için rengi biraz koyulaştırıyoruz
    final readableAccent = Color.lerp(accentColor, Colors.black, 0.45) ?? accentColor;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: readableAccent,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: ColorScheme.light(
        primary: readableAccent,
        secondary: AppColors.secondary,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextPrimary,
        error: AppColors.error,
      ),
      textTheme: _buildTextTheme(
        Typography.material2021(platform: TargetPlatform.android).black,
        AppColors.lightTextPrimary,
        AppColors.lightTextSecondary,
      ),
      iconTheme: const IconThemeData(color: AppColors.lightTextSecondary, size: 24),
    );
  }

  static TextTheme _buildTextTheme(TextTheme base, Color primaryColor, Color secondaryColor) {
    TextStyle premiumTextStyle({
      double? fontSize,
      FontWeight? fontWeight,
      Color? color,
      double? letterSpacing,
    }) {
      return TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
      );
    }

    return base.copyWith(
      displayLarge: premiumTextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        color: primaryColor,
        letterSpacing: -1.5,
      ),
      displayMedium: premiumTextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: primaryColor,
        letterSpacing: -0.5,
      ),
      bodyLarge: premiumTextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: primaryColor,
      ),
      bodyMedium: premiumTextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: secondaryColor,
      ),
      labelLarge: premiumTextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        letterSpacing: 1.2,
      ),
    );
  }
}
