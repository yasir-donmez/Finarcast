import 'package:flutter/material.dart';

class AppColors {
  // --- Dark Colors ---
  static const Color darkBackground = Color(0xFF0D0E12); // Lüks Derin Gece/Kömür Siyahı (0xFF000000 -> 0xFF0D0E12)
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

  /// Seçilen birincil (accent) renge karşılık gelen ikincil (secondary) rengi döner (Telegram stili)
  static Color getThemeSecondary(Color primaryColor) {
    final value = primaryColor.toARGB32() & 0xFFFFFFFF;
    switch (value) {
      case 0xFF00BCD4: // Kutup Mavisi (Polar Cyan)
        return const Color(0xFF006064);
      case 0xFF2EC4B6: // Nordik Nane (Nordic Sage)
        return const Color(0xFF0F4C5C);
      case 0xFFE5989B: // Pembe Altın (Rose Gold)
        return const Color(0xFF6D597A);
      case 0xFF8F94FB: // Eflatun Gece (Mystic Lavender)
        return const Color(0xFF4E54C8);
      case 0xFFF4A261: // Sahra Kehribarı (Sahara Amber)
        return const Color(0xFFE76F51);
      case 0xFF00B4D8: // Kraliyet Mavisi (Royal Blue)
        return const Color(0xFF03045E);
      case 0xFFFF4D6D: // Bordo Şarap (Burgundy Wine)
        return const Color(0xFF800F2F);
      case 0xFFADB5BD: // Platin Gri (Platinum Grey)
        return const Color(0xFF212529);
      default:
        // Sistem/Varsayılan veya diğer renkler için dinamik lerp fallback
        return Color.lerp(primaryColor, Colors.white, 0.35)!;
    }
  }
  
  static Color getSuccess(BuildContext context) => getAccentDeep(context, const Color(0xFF00E676));
  static Color getWarning(BuildContext context) => getAccentDeep(context, const Color(0xFFFFAB40));
  static Color getInfo(BuildContext context) => getAccentDeep(context, const Color(0xFF29B6F6));
  static Color getIncome(BuildContext context) => getAccentDeep(context, const Color(0xFF00E676));
  static Color getExpense(BuildContext context) => getAccentDeep(context, const Color(0xFFFF5252));
 
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
 
  // Background gradient colors lookup
  static List<Color>? getGradientColors(Color accentColor) {
    final value = accentColor.toARGB32() & 0xFFFFFFFF; // Make sure it's 32-bit int comparison
    switch (value) {
      case 0xFF00BCD4: // Kutup Mavisi
        return const [Color(0xFF00BCD4), Color(0xFF006064)];
      case 0xFF2EC4B6: // Nordik Nane
        return const [Color(0xFF2EC4B6), Color(0xFF0F4C5C)];
      case 0xFFE5989B: // Pembe Altın
        return const [Color(0xFFE5989B), Color(0xFF6D597A)];
      case 0xFF8F94FB: // Eflatun Gece
        return const [Color(0xFF8F94FB), Color(0xFF4E54C8)];
      case 0xFFF4A261: // Sahra Kehribarı
        return const [Color(0xFFF4A261), Color(0xFFE76F51)];
      case 0xFF00B4D8: // Kraliyet Mavisi
        return const [Color(0xFF00B4D8), Color(0xFF03045E)];
      case 0xFFFF4D6D: // Bordo Şarap
        return const [Color(0xFFFF4D6D), Color(0xFF800F2F)];
      case 0xFFADB5BD: // Platin Gri
        return const [Color(0xFFADB5BD), Color(0xFF212529)];
      default:
        return null;
    }
  }

  /// Arayüz stiline göre dinamik zemin rengini döner
  static Color getThemeBackground(BuildContext context, int bgColorStyle) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    if (bgColorStyle == 2) {
      // ═══ SADE ═══
      return isDark ? darkBackground : lightBackground;
    } else {
      // ═══ RENKLİ ═══ (Varsayılan - M3 Uyumlu)
      return isDark ? colorScheme.surfaceContainerLowest : colorScheme.surfaceDim;
    }
  }

  /// Arayüz stiline göre dinamik kart/yüzey rengini döner
  static Color getThemeSurface(BuildContext context, int bgColorStyle, {bool isInsideSheet = false}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    if (bgColorStyle == 2) {
      // ═══ SADE ═══
      if (isDark) {
        return isInsideSheet ? const Color(0xFF22252A) : const Color(0xFF161720);
      } else {
        return isInsideSheet ? const Color(0xFFEBEEF2) : Colors.white;
      }
    } else {
      // ═══ RENKLİ ═══ (Varsayılan - M3 Uyumlu)
      if (isDark) {
        return isInsideSheet ? colorScheme.surfaceContainerHigh : colorScheme.surfaceContainer;
      } else {
        return isInsideSheet ? colorScheme.surfaceContainer : colorScheme.surfaceContainerLow;
      }
    }
  }

  /// Arayüz stiline göre dinamik sınır/kenarlık rengini döner
  static Color getThemeBorder(BuildContext context, int bgColorStyle) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    if (bgColorStyle == 2) {
      // ═══ SADE ═══
      return isDark ? const Color(0xFF2A2B36) : const Color(0xFFE4E7EB);
    } else {
      // ═══ RENKLİ ═══ (Varsayılan - M3 Uyumlu)
      return colorScheme.outlineVariant;
    }
  }

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
  static const Color primary = Color(0xFF00BCD4);
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
  /// Tüm desteklenen semboller (dönüşüm motoru + işlem girişi)
  static const List<String> supportedSymbols = ['₺', r'$', '€', '£', '¥', '₩', '元', r'R$', 'Fr', 'G', 'Ag', 'SR', 'KD'];

  /// Emtia (commodity) sembolleri — görüntüleme birimi olarak kullanılamaz
  static const List<String> commoditySymbols = ['G', 'Ag'];

  /// Görüntüleme birimleri (Fiat) — Profil ana birimi, Kasa birimi, Dashboard, İstatistikler
  static List<String> get displaySymbols => supportedSymbols.where((s) => !commoditySymbols.contains(s)).toList();

  /// Giriş birimleri (Tümü) — İşlem ekleme ekranı
  static const List<String> inputSymbols = supportedSymbols;

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
    'ALTIN': 'GOLD',
    'Ag': 'SILVER',
    'SR': 'SAR',
    'KD': 'KWD',
  };
  static String getCode(String symbol) => symbolToCode[symbol] ?? symbol;

  /// Bir sembolün emtia (commodity) olup olmadığını kontrol eder
  static bool isCommodity(String symbol) => commoditySymbols.contains(symbol);
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
