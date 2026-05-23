import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../../../core/theme/app_constants.dart';
import 'color_theme_setting.dart';

class BackgroundSetting extends ConsumerWidget {
  const BackgroundSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bgColorStyle = ref.watch(
      settingsProvider.select((s) => s.bgColorStyle),
    );
    final accentColorValue = ref.watch(
      settingsProvider.select((s) => s.accentColorValue),
    );

    // Aktif tema renginin gradyan olup olmadığını kontrol et
    List<Color>? bgGradient;
    for (var option in ColorThemeSetting.vibrantColors) {
      if (option.primaryColor.toARGB32() == accentColorValue) {
        bgGradient = option.gradientColors;
        break;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Arayüz Stili",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: AppColors.getTextPrimary(context),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Kartların ve arka planın görünüm stilini seçin",
            style: TextStyle(
              fontSize: 13,
              color: AppColors.getTextSecondary(
                context,
              ).withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // 1. Sade (Düz renkler, tema rengi sadece içerikleri etkiler)
              BackgroundPreviewCard(
                styleIndex: 2, // Sade
                isSelected: bgColorStyle == 2,
                accentColorValue: accentColorValue,
                bgGradient: bgGradient,
                onTap: () {
                  if (bgColorStyle == 2) return;
                  HapticFeedback.lightImpact();
                  ref.read(settingsProvider.notifier).setBgColorStyle(2);
                },
              ),

              // 2. Renkli (Tema rengi kartlara ve arka plana yansır, katı)
              BackgroundPreviewCard(
                styleIndex: 1, // Renkli
                isSelected: bgColorStyle == 1,
                accentColorValue: accentColorValue,
                bgGradient: bgGradient,
                onTap: () {
                  if (bgColorStyle == 1) return;
                  HapticFeedback.lightImpact();
                  ref.read(settingsProvider.notifier).setBgColorStyle(1);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BackgroundPreviewCard extends StatelessWidget {
  final int styleIndex;
  final bool isSelected;
  final int accentColorValue;
  final List<Color>? bgGradient;
  final VoidCallback onTap;

  const BackgroundPreviewCard({
    super.key,
    required this.styleIndex,
    required this.isSelected,
    required this.accentColorValue,
    this.bgGradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final gradient = bgGradient;

    // Yeni stil isimleri ve açıklamaları
    final labels = ["Cam", "Renkli", "Sade"];
    final descriptions = [
      "Saydam kartlar",
      "Uyumlu renkler",
      "Düz tasarım",
    ];
    final label = labels[styleIndex];
    final description = descriptions[styleIndex];

    final activeColor = accentColorValue == 0 || accentColorValue == 0xFF00E5FF
        ? primaryColor
        : Color(accentColorValue);

    // Her stil için arka plan ve kart renklerini hesapla
    final baseColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    Decoration previewDecoration;
    Color mockCardBg;
    Color mockCardBorder;
    List<BoxShadow>? mockCardShadow;
    Color mockAccentBarColor = activeColor;

    if (styleIndex == 2) {
      // ═══ SADE ═══
      // Düz arka plan, düz kart. Tema rengi sadece içeriklere (bar) yansır.
      final solidBg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
      previewDecoration = BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [solidBg, solidBg],
        ),
        borderRadius: BorderRadius.circular(16),
      );
      mockCardBg = isDark ? const Color(0xFF161720) : Colors.white;
      mockCardBorder = isDark ? const Color(0xFF2A2B36) : const Color(0xFFE4E7EB);
      mockCardShadow = !isDark ? [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 4,
          offset: const Offset(0, 1),
        )
      ] : null;
    } else if (styleIndex == 1) {
      // ═══ RENKLİ ═══
      // Arka plan ve kartlar tema rengiyle uyumlu katı renkler.
      final Color tintColor = gradient != null ? gradient.first : activeColor;
      
      final bgTinted = isDark
          ? Color.lerp(AppColors.darkBackground, tintColor, 0.20)!
          : Color.lerp(AppColors.lightBackground, tintColor, 0.10)!;
      
      if (gradient != null) {
        previewDecoration = BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient
                .map((c) => isDark
                    ? Color.lerp(AppColors.darkBackground, c, 0.22)!
                    : Color.lerp(AppColors.lightBackground, c, 0.12)!)
                .toList(),
          ),
          borderRadius: BorderRadius.circular(16),
        );
      } else {
        previewDecoration = BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [bgTinted, bgTinted],
          ),
          borderRadius: BorderRadius.circular(16),
        );
      }
 
      // Kart rengi: arka plandan biraz daha açık/koyu tonda, ama yine uyumlu
      mockCardBg = isDark
          ? Color.lerp(const Color(0xFF161720), tintColor, 0.12)!
          : Color.lerp(Colors.white, tintColor, 0.06)!;
      mockCardBorder = isDark
          ? Color.lerp(const Color(0xFF2A2B36), tintColor, 0.15)!
          : Color.lerp(const Color(0xFFE4E7EB), tintColor, 0.12)!;
      mockCardShadow = null;
    } else {
      // ═══ CAM ═══
      // Renkli arka plan + yarı saydam kartlar
      final Color tintColor = gradient != null ? gradient.first : activeColor;
      
      if (gradient != null) {
        previewDecoration = BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient
                .map((c) => isDark
                    ? Color.lerp(Colors.black, c, 0.40)!
                    : Color.lerp(baseColor, c, 0.16)!)
                .toList(),
          ),
          borderRadius: BorderRadius.circular(16),
        );
      } else {
        final camBg = isDark
            ? Color.lerp(Colors.black, tintColor, 0.35)!
            : Color.lerp(baseColor, tintColor, 0.12)!;
        previewDecoration = BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [camBg, camBg],
          ),
          borderRadius: BorderRadius.circular(16),
        );
      }
 
      mockCardBg = isDark
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.white.withValues(alpha: 0.45);
      mockCardBorder = isDark
          ? Colors.white.withValues(alpha: 0.18)
          : Colors.white.withValues(alpha: 0.6);
      mockCardShadow = null;
    }

    // Seçim border'ı üstten ekleniyor
    final outerDecoration = (previewDecoration as BoxDecoration).copyWith(
      border: Border.all(
        color: isSelected
            ? primaryColor
            : AppColors.getTextSecondary(context).withValues(alpha: 0.1),
        width: isSelected ? 2.5 : 1,
      ),
      boxShadow: [],
    );

    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 300),
        scale: isSelected ? 1.02 : 0.98,
        curve: Curves.easeOutBack,
        child: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Column(
            children: [
              // Önizleme Kutusu
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: 98,
                height: 120,
                decoration: outerDecoration,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    children: [
                      // Mock Kart
                      Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          width: 66,
                          height: 48,
                          decoration: BoxDecoration(
                            color: mockCardBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: mockCardBorder,
                              width: 1,
                            ),
                            boxShadow: mockCardShadow,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                width: 38,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: mockAccentBarColor.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                width: 22,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: (isDark ? Colors.white : Colors.black)
                                      .withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Seçim İşareti
                      Positioned(
                        bottom: 6,
                        right: 6,
                        child: AnimatedScale(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutBack,
                          scale: isSelected ? 1.0 : 0.0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Başlık
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? AppColors.getTextPrimary(context)
                      : AppColors.getTextSecondary(context).withValues(alpha: 0.6),
                ),
                child: Text(label),
              ),
              const SizedBox(height: 2),
              // Alt açıklama
              Text(
                description,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.getTextSecondary(context).withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
