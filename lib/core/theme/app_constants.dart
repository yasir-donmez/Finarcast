import 'package:flutter/material.dart';

class AppColors {
  // --- Dark Colors ---
  static const Color darkBackground = Color(0xFF000000);
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
  static Color getPrimary(BuildContext context) => Theme.of(context).colorScheme.primary;
  static Color getSecondary(BuildContext context) => Theme.of(context).colorScheme.secondary;
  static Color getError(BuildContext context) => Theme.of(context).colorScheme.error;
  static Color getSurface(BuildContext context) => Theme.of(context).colorScheme.surface;
  
  static Color getSuccess(BuildContext context) => const Color(0xFF00E676);
  static Color getWarning(BuildContext context) => const Color(0xFFFFAB40);
  static Color getInfo(BuildContext context) => const Color(0xFF29B6F6);
  static Color getIncome(BuildContext context) => const Color(0xFF00E676);
  static Color getExpense(BuildContext context) => const Color(0xFFFF5252);

  static Color getTextPrimary(BuildContext context) => Theme.of(context).colorScheme.onSurface;
  static Color getTextSecondary(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? darkTextSecondary : lightTextSecondary;
  
  // En sönük metinler (başlıklar vb.) için standart bir renk
  static Color getTextFaint(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return (isDark ? Colors.white : Colors.black).withValues(alpha: 0.35);
  }

  static Color getBackground(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? darkBackground : lightBackground;
  static Color getLightShadow(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? darkLightShadow : lightLightShadow;
  static Color getDarkShadow(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? darkDarkShadow : lightDarkShadow;
  static Color getInnerSurface(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? darkInnerSurface : lightInnerSurface;

  // Aydınlık modda okunabilirliği artıran derin renkler
  static Color getAccentDeep(BuildContext context, Color baseColor) {
    if (Theme.of(context).brightness == Brightness.dark) return baseColor;
    // Aydınlık modda rengi daha koyu ve doygun yapıyoruz
    // Luma kontrolü ile çok açık renkleri daha da koyulaştırıyoruz
    final luma = baseColor.computeLuminance();
    final lerpAmount = luma > 0.6 ? 0.65 : 0.45;
    return Color.lerp(baseColor, Colors.black, lerpAmount) ?? baseColor;
  }

  /// Verilen arka plan rengi üzerinde en iyi okunan metin rengini döner (Siyah veya Beyaz)
  static Color getContrastColor(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

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
  static const List<String> supportedSymbols = ['₺', r'$', '€', '£', '¥', '₩', '元', r'R$', 'Fr', 'G', 'Ag', 'SR', 'KD'];
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
    'Ag': 'SILVER',
    'SR': 'SAR',
    'KD': 'KWD',
  };
  static String getCode(String symbol) => symbolToCode[symbol] ?? symbol;
}
class AppAssets {
  static const String logoNormal = 'assets/images/app_logo_normal.png';
  static const String logoPremium = 'assets/images/app_logo_premium.png';
  static const String bgPattern = 'assets/images/bg_pattern.png';

  static String getLogo(BuildContext context) {
    // Dark mode usually fits the "premium/transparent" look better
    return Theme.of(context).brightness == Brightness.dark ? logoPremium : logoNormal;
  }

  static String getBackgroundImg(BuildContext context) {
    return bgPattern;
  }
}
