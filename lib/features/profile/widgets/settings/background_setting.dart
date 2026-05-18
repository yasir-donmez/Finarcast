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
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Arayüz Stili",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: AppColors.getTextPrimary(context),
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Arkaplan ve kartların cam (glassmorphism) davranışını seçin",
              style: TextStyle(
                fontSize: 13,
                color: AppColors.getTextSecondary(
                  context,
                ).withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                // 1. Sade (Minimalist)
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

                // 2. Hafif Boyalı (Soft Tint)
                BackgroundPreviewCard(
                  styleIndex: 0, // Hafif Boyalı
                  isSelected: bgColorStyle == 0,
                  accentColorValue: accentColorValue,
                  bgGradient: bgGradient,
                  onTap: () {
                    if (bgColorStyle == 0) return;
                    HapticFeedback.lightImpact();
                    ref.read(settingsProvider.notifier).setBgColorStyle(0);
                  },
                ),

                // 3. Zemini Boya (Painted Background)
                BackgroundPreviewCard(
                  styleIndex: 1, // Zemini Boya
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

    final labels = ["Pürüzsüz Cam", "Doygun Cam", "Sade & Mat"];
    final label = labels[styleIndex];

    // Temel zemin rengi
    final baseColor = isDark ? Colors.black : const Color(0xFFF5F7FA);
    Decoration previewDecoration = BoxDecoration(
      color: baseColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isSelected
            ? primaryColor
            : AppColors.getTextSecondary(context).withValues(alpha: 0.1),
        width: isSelected ? 2.5 : 1,
      ),
      boxShadow: isSelected
          ? [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.3),
                blurRadius: 12,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ]
          : [],
    );

    // Renklendirme tarzı
    if (styleIndex == 1) {
      // Zemini Boya
      if (gradient != null) {
        previewDecoration = (previewDecoration as BoxDecoration).copyWith(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient
                .map((c) => isDark 
                    ? Color.lerp(Colors.black, c, 0.45)! 
                    : Color.lerp(const Color(0xFFF5F7FA), c, 0.18)!)
                .toList(),
          ),
        );
      } else {
        previewDecoration = (previewDecoration as BoxDecoration).copyWith(
          color: isDark 
              ? Color.lerp(Colors.black, Color(accentColorValue), 0.40)
              : Color.lerp(const Color(0xFFF5F7FA), Color(accentColorValue), 0.12),
        );
      }
    } else if (styleIndex == 0) {
      // Hafif Boyalı
      if (gradient != null) {
        previewDecoration = (previewDecoration as BoxDecoration).copyWith(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient
                .map((c) => isDark 
                    ? Color.lerp(Colors.black, c, 0.15)! 
                    : Color.lerp(const Color(0xFFF5F7FA), c, 0.05)!)
                .toList(),
          ),
        );
      } else {
        previewDecoration = (previewDecoration as BoxDecoration).copyWith(
          color: isDark 
              ? Color.lerp(Colors.black, Color(accentColorValue), 0.12)
              : Color.lerp(const Color(0xFFF5F7FA), Color(accentColorValue), 0.04),
        );
      }
    }

    final activeColor = accentColorValue == 0 || accentColorValue == 0xFF00E5FF
        ? primaryColor
        : Color(accentColorValue);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            // Önizleme Kutusu
            Container(
              width: 98,
              height: 120,
              decoration: previewDecoration,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  children: [
                    // Mock Kart / UI Elemanı (Görsel Zenginlik)
                    Center(
                      child: Container(
                        width: 66,
                        height: 48,
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.white : Colors.black)
                              .withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: (isDark ? Colors.white : Colors.black)
                                .withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 38,
                              height: 6,
                              decoration: BoxDecoration(
                                color: activeColor.withValues(alpha: 0.8),
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
                    if (isSelected)
                      Positioned(
                        bottom: 6,
                        right: 6,
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Etiket
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? AppColors.getTextPrimary(context)
                    : AppColors.getTextSecondary(context).withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
