import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/services/subscription_service.dart';
import '../../../home/home_providers.dart';
import '../../../../shared/widgets/custom_dialog.dart';
import '../../../subscription/widgets/pro_upgrade_sheet.dart';
import '../settings_list_items.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/animated_premium_badge.dart';
import '../../../../shared/widgets/animated_premium_star_badge.dart';

class BackgroundSetting extends ConsumerWidget {
  const BackgroundSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final bgColorStyle = ref.watch(
      settingsProvider.select((s) => s.bgColorStyle),
    );
    final accentColorValue = ref.watch(
      settingsProvider.select((s) => s.accentColorValue),
    );
    final activeColor = SettingsListItems.getSettingColor(context, SettingType.background, ref.watch(rotaryColorProvider));
    final subscription = ref.watch(subscriptionServiceProvider);
    final isPro = subscription.isPro;

    // Aktif tema renginin gradyan olup olmadığını kontrol et
    final bgGradient = AppColors.getGradientColors(Color(accentColorValue));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: activeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.style_outlined, size: 22, color: activeColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.styleLabel,
                      style: TextStyle(
                        color: AppColors.getTextPrimary(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (!isPro) ...[
                      const SizedBox(height: 2),
                      const AnimatedPremiumBadge(),
                    ],
                    const SizedBox(height: 2),
                    Text(
                      l10n.styleDesc,
                      style: TextStyle(
                        color: AppColors.getTextSecondary(context).withValues(alpha: 0.5),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
                isPremium: false,
                isPro: isPro,
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
                isPremium: true,
                isPro: isPro,
                onTap: () {
                  if (!isPro) {
                    HapticFeedback.heavyImpact();
                    _showPremiumRequiredDialog(context, l10n);
                    return;
                  }
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

  void _showPremiumRequiredDialog(BuildContext context, AppLocalizations l10n) {
    showCustomDialog(
      context: context,
      accentColor: const Color(0xFFFFB300), // Altın rengi
      title: l10n.premiumRequired,
      content: l10n.premiumStyleDesc,
      actions: [
        PrecisionDialogAction(
          label: l10n.later,
          onTap: () => Navigator.pop(context),
          isPrimary: false,
        ),
        PrecisionDialogAction(
          label: l10n.upgradeToPro,
          onTap: () {
            Navigator.pop(context);
            ProUpgradeSheet.show(context);
          },
          isPrimary: true,
        ),
      ],
    );
  }
}

class BackgroundPreviewCard extends StatelessWidget {
  final int styleIndex;
  final bool isSelected;
  final int accentColorValue;
  final List<Color>? bgGradient;
  final VoidCallback onTap;
  final bool isPremium;
  final bool isPro;

  const BackgroundPreviewCard({
    super.key,
    required this.styleIndex,
    required this.isSelected,
    required this.accentColorValue,
    this.bgGradient,
    required this.onTap,
    this.isPremium = false,
    this.isPro = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final l10n = AppLocalizations.of(context)!;
    final String label;
    final String description;
    if (styleIndex == 1) {
      label = l10n.styleColor;
      description = l10n.styleColorDesc;
    } else {
      label = l10n.styleSimple;
      description = l10n.styleSimpleDesc;
    }

    final activeColor = accentColorValue == 0
        ? primaryColor
        : Color(accentColorValue);

    final mockColorScheme = ColorScheme.fromSeed(
      seedColor: activeColor,
      brightness: isDark ? Brightness.dark : Brightness.light,
    );

    Decoration previewDecoration;
    Color mockCardBg;
    Color mockCardBorder;
    List<BoxShadow>? mockCardShadow;
    Color mockAccentBarColor = activeColor;

    if (styleIndex == 2) {
      // ═══ SADE ═══
      final solidBg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
      previewDecoration = BoxDecoration(
        color: solidBg,
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
    } else {
      // ═══ RENKLİ ═══ (M3 Uyumlu)
      final bgTinted = isDark ? mockColorScheme.surfaceContainerLowest : mockColorScheme.surfaceDim;
      previewDecoration = BoxDecoration(
        color: bgTinted,
        borderRadius: BorderRadius.circular(16),
      );

      mockCardBg = isDark ? mockColorScheme.surfaceContainer : mockColorScheme.surfaceContainerLow;
      mockCardBorder = mockColorScheme.outlineVariant;
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
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            // Önizleme Kutusu (Sadece bu kutu scale olacak)
            AnimatedScale(
              duration: const Duration(milliseconds: 300),
              scale: isSelected ? 1.02 : 0.98,
              curve: Curves.easeOutBack,
              child: AnimatedContainer(
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

                      // Premium Kilit / Yıldız Simgesi
                      if (isPremium && !isPro)
                        const Positioned(
                          top: 6,
                          right: 6,
                          child: AnimatedPremiumStarBadge(
                            size: 10,
                            padding: 2.5,
                          ),
                        ),
                    ],
                  ),
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
    );
  }
}
