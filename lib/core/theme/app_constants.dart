import 'package:flutter/material.dart';

class AppColors {
  // --- Dark Colors ---
  static const Color darkBackground = Color(0xFF292C31);
  static const Color darkSurface = Color(0xFF2F3237);
  static const Color darkLightShadow = Color(0x1AFFFFFF);
  static const Color darkDarkShadow = Color(0x80000000);
  static const Color darkInnerSurface = Color(0xFF22252A);
  static const Color darkTextPrimary = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFF8A8F99);

  // --- Light Colors (Maksimum Kontrast ve Netlik - Neumorphic tabanlı) ---
  static const Color lightBackground = Color(0xFFD1D9E6); // Klasik Gümüş-Mavi zemin (DDE1E7 -> D1D9E6)
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightLightShadow = Color(0xFFFFFFFF);
  static const Color lightDarkShadow = Color(0xFFA3B1C6); // Keskin ve derin gölge (B8C2D0 -> A3B1C6)
  static const Color lightInnerSurface = Color(0xFFEBEEF2);
  static const Color lightTextPrimary = Color(0xFF1E2124); 
  static const Color lightTextSecondary = Color(0xFF707780); 


  // --- Dynamic Color Helpers ---
  static Color getBackground(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? darkBackground : lightBackground;
  static Color getSurface(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? darkSurface : lightSurface;
  static Color getLightShadow(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? darkLightShadow : lightLightShadow;
  static Color getDarkShadow(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? darkDarkShadow : lightDarkShadow;
  static Color getInnerSurface(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? darkInnerSurface : lightInnerSurface;
  static Color getTextPrimary(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? darkTextPrimary : lightTextPrimary;
  static Color getTextSecondary(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? darkTextSecondary : lightTextSecondary;
  
  // Aydınlık modda okunabilirliği artıran derin renkler
  static Color getAccentDeep(BuildContext context, Color baseColor) {
    if (Theme.of(context).brightness == Brightness.dark) return baseColor;
    // Aydınlık modda rengi daha koyu ve doygun yapıyoruz (Daha iyi kontrast için 0.35 -> 0.45)
    return Color.lerp(baseColor, Colors.black, 0.45) ?? baseColor;
  }

  static Color getPrimary(BuildContext context) => getAccentDeep(context, primary); 
  static Color getSecondary(BuildContext context) => getAccentDeep(context, secondary);
  static Color getError(BuildContext context) => getAccentDeep(context, error);
  static Color getSuccess(BuildContext context) => getAccentDeep(context, success);
  static Color getWarning(BuildContext context) => getAccentDeep(context, warning);
  static Color getInfo(BuildContext context) => getAccentDeep(context, info);
  static Color getIncome(BuildContext context) => getAccentDeep(context, income);
  static Color getExpense(BuildContext context) => getAccentDeep(context, expense);

  // --- Legacy Proxies (Deprecated: Use dynamic getters with context) ---
  // Renamed to prompt refactoring where context is available.
  static const Color legacyDarkBackground = darkBackground;
  static const Color legacyDarkSurface = darkSurface;
  static const Color legacyDarkShadow = darkDarkShadow;
  static const Color legacyTextPrimary = darkTextPrimary;
  static const Color legacyTextSecondary = darkTextSecondary;
  
  // Backwards compatibility for strictly non-context areas (AI service, etc)
  static const Color staticPrimary = primary;
  static const Color staticSecondary = secondary;

  // --- Accents ---
  static const Color primary = Color(0xFF00E5FF);
  static const Color secondary = Color(0xFFB388FF);
  static const Color error = Color(0xFFFF5252);
  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFAB40);
  static const Color info = Color(0xFF29B6F6);
  static const Color income = Color(0xFF00E676); // Same as success
  static const Color expense = Color(0xFFFF5252); // Same as error
}

class AppSizes {
  static const double radiusSmall = 8.0;
  static const double radiusDefault = 16.0;
  static const double radiusLarge = 24.0;
  static const double radiusRound = 100.0;

  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
}
class AppCurrency {
  static const List<String> supportedSymbols = ['₺', r'$', '€', '£', '¥', '₩', '元', r'R$', 'Fr', 'G'];
  static const Map<String, String> symbolToCode = {
    '₺': 'TRY',
    r'$': 'USD',
    '€': 'EUR',
    '£': 'GBP',
    '¥': 'JPY',
    '₩': 'KRW',
    '元': 'CNY',
    r'R$': 'BRL',
    'Fr': 'CHF',
    'G': 'GOLD',
  };
  static String getCode(String symbol) => symbolToCode[symbol] ?? symbol;
}
class AppAssets {
  static const String logoNormal = 'assets/images/app_logo_normal.png';
  static const String logoPremium = 'assets/images/app_logo_premium.png';

  static String getLogo(BuildContext context) {
    // Dark mode usually fits the "premium/transparent" look better
    return Theme.of(context).brightness == Brightness.dark ? logoPremium : logoNormal;
  }
}
