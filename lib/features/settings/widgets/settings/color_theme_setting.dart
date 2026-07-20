import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/services/subscription_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../home/home_providers.dart';
import '../settings_list_items.dart';
import '../../../../shared/widgets/custom_dialog.dart';
import '../../../subscription/widgets/pro_upgrade_sheet.dart';
import '../../../../shared/widgets/animated_premium_badge.dart';
import '../../../../shared/widgets/animated_premium_star_badge.dart';

class ThemeColorOption {
  final Color primaryColor;
  final List<Color> gradientColors;
  final Color secondaryColor;
  final String name;

  const ThemeColorOption({
    required this.primaryColor,
    required this.gradientColors,
    required this.secondaryColor,
    required this.name,
  });
}

class ColorThemeSetting extends ConsumerWidget {
  const ColorThemeSetting({super.key});

  static const List<ThemeColorOption> curatedPalettes = [
    ThemeColorOption(
      primaryColor: Color(0xFF00BCD4),
      gradientColors: [Color(0xFF00BCD4), Color(0xFF006064)],
      secondaryColor: Color(0xFF006064),
      name: "Kutup",
    ),
    ThemeColorOption(
      primaryColor: Color(0xFF2EC4B6),
      gradientColors: [Color(0xFF2EC4B6), Color(0xFF0F4C5C)],
      secondaryColor: Color(0xFF0F4C5C),
      name: "Nane",
    ),
    ThemeColorOption(
      primaryColor: Color(0xFFE5989B),
      gradientColors: [Color(0xFFE5989B), Color(0xFF6D597A)],
      secondaryColor: Color(0xFF6D597A),
      name: "Rose",
    ),
    ThemeColorOption(
      primaryColor: Color(0xFF8F94FB),
      gradientColors: [Color(0xFF8F94FB), Color(0xFF4E54C8)],
      secondaryColor: Color(0xFF4E54C8),
      name: "Lavanta",
    ),
    ThemeColorOption(
      primaryColor: Color(0xFFF4A261),
      gradientColors: [Color(0xFFF4A261), Color(0xFFE76F51)],
      secondaryColor: Color(0xFFE76F51),
      name: "Sahra",
    ),
    ThemeColorOption(
      primaryColor: Color(0xFF00B4D8),
      gradientColors: [Color(0xFF00B4D8), Color(0xFF03045E)],
      secondaryColor: Color(0xFF03045E),
      name: "Safir",
    ),
    ThemeColorOption(
      primaryColor: Color(0xFFFF4D6D),
      gradientColors: [Color(0xFFFF4D6D), Color(0xFF800F2F)],
      secondaryColor: Color(0xFF800F2F),
      name: "Bordo",
    ),
    ThemeColorOption(
      primaryColor: Color(0xFFADB5BD),
      gradientColors: [Color(0xFFADB5BD), Color(0xFF212529)],
      secondaryColor: Color(0xFF212529),
      name: "Platin",
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentColorValue = ref.watch(
      settingsProvider.select((s) => s.accentColorValue),
    );
    final l10n = AppLocalizations.of(context)!;
    final activeColor = SettingsListItems.getSettingColor(context, SettingType.colorTheme, ref.watch(rotaryColorProvider));
    final subscription = ref.watch(subscriptionServiceProvider);
    final isPro = subscription.isPro;

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
                child: Icon(Icons.palette_outlined, size: 22, color: activeColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.colorTheme,
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
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 86,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                // 1. Sistem Seçeneği
                _buildSystemDrop(context, ref, currentColorValue, isPro: isPro),

                _buildDivider(context),

                // 2. Tasarım Paletleri (Kutup Mavisi ücretsiz, diğerleri premium)
                ...curatedPalettes.map(
                  (option) => _buildColorDrop(context, ref, option, currentColorValue, isPro: isPro),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16, left: 4),
      child: Center(
        child: Container(
          width: 2,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.getTextSecondary(context).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  void _showPremiumRequiredDialog(BuildContext context, AppLocalizations l10n) {
    showCustomDialog(
      context: context,
      accentColor: const Color(0xFFFFB300), // Altın rengi
      title: l10n.premiumRequired,
      content: l10n.premiumColorDesc,
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

  Widget _buildSystemDrop(
    BuildContext context,
    WidgetRef ref,
    int currentColorValue, {
    bool isPro = true,
  }) {
    final isSelected = currentColorValue == 0;
    final dynamicColor = ref.watch(dynamicColorProvider);

    return LiquidColorDrop(
      option: ThemeColorOption(
        primaryColor: dynamicColor,
        gradientColors: [dynamicColor, Color.lerp(dynamicColor, Colors.black, 0.35)!],
        secondaryColor: Color.lerp(dynamicColor, Colors.black, 0.35)!,
        name: "Sistem",
      ),
      isSelected: isSelected,
      isSystem: true,
      isPro: isPro,
      isPremium: true,
      onTap: () {
        if (!isPro) {
          HapticFeedback.heavyImpact();
          _showPremiumRequiredDialog(context, AppLocalizations.of(context)!);
          return;
        }
        if (isSelected) return;
        HapticFeedback.heavyImpact();
        // PERFORMANS: Renk butonunun büyüme animasyonunun (300ms) kasmasını önlemek için
        // renk güncellemesini ve MaterialApp rebuild'ini 200ms geciktiriyoruz.
        Future.delayed(const Duration(milliseconds: 200), () {
          ref.read(settingsProvider.notifier).setAccentColor(0);
        });
      },
    );
  }

  Widget _buildColorDrop(
    BuildContext context,
    WidgetRef ref,
    ThemeColorOption option,
    int currentColorValue, {
    bool isPro = true,
  }) {
    final isSelected = currentColorValue == option.primaryColor.toARGB32();
    // Cyan Rengi dışındaki tüm renkler Premium (0xFF00BCD4 = Cyan)
    final isColorPremium = option.primaryColor.toARGB32() != 0xFF00BCD4;

    return LiquidColorDrop(
      option: option,
      isSelected: isSelected,
      isPremium: isColorPremium,
      isPro: isPro,
      onTap: () {
        if (isColorPremium && !isPro) {
          HapticFeedback.heavyImpact();
          _showPremiumRequiredDialog(context, AppLocalizations.of(context)!);
          return;
        }
        if (isSelected) return;
        HapticFeedback.heavyImpact();
        // PERFORMANS: 200ms gecikmeli güncelleme
        Future.delayed(const Duration(milliseconds: 200), () {
          ref
              .read(settingsProvider.notifier)
              .setAccentColor(option.primaryColor.toARGB32());
        });
      },
    );
  }
}

class LiquidColorDrop extends StatefulWidget {
  final ThemeColorOption option;
  final bool isSelected;
  final bool isSystem;
  final bool isPremium;
  final bool isPro;
  final VoidCallback onTap;

  const LiquidColorDrop({
    super.key,
    required this.option,
    required this.isSelected,
    required this.onTap,
    this.isSystem = false,
    this.isPremium = false,
    this.isPro = true,
  });

  @override
  State<LiquidColorDrop> createState() => _LiquidColorDropState();
}

class _LiquidColorDropState extends State<LiquidColorDrop> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Dairenin gradyan dolgusu
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: widget.option.gradientColors,
    );

    // Seçili iken dışta parıltı efekti yerine standart hafif gölge
    final List<BoxShadow> shadows = widget.isSelected
        ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ]
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.04),
              blurRadius: 3,
              offset: const Offset(0, 1),
            )
          ];

    return GestureDetector(
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: SizedBox(
          width: 58,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Renk Dairesi
                  AnimatedScale(
                    duration: const Duration(milliseconds: 300),
                    scale: widget.isSelected ? 1.15 : 0.95,
                    curve: Curves.easeOutBack,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: gradient,
                        border: Border.all(
                          color: AppColors.getTextPrimary(context).withValues(
                            alpha: widget.isSelected ? 0.8 : 0.15,
                          ),
                          width: 2.0,
                        ),
                        boxShadow: shadows,
                      ),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: widget.isSelected
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 14,
                                )
                              : (widget.isSystem
                                  ? const Icon(
                                      Icons.auto_awesome_rounded,
                                      color: Colors.white,
                                      size: 12,
                                    )
                                  : null),
                        ),
                      ),
                    ),
                  ),

                  // Kilitli Premium İşareti (Sağ Üstte Küçük Altın Yıldız)
                  if (widget.isPremium && !widget.isPro)
                    const Positioned(
                      top: -2,
                      right: -2,
                      child: AnimatedPremiumStarBadge(
                        size: 8,
                        padding: 2.5,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              // Palet İsmi
              Text(
                _getPaletteLocalizedName(context, widget.option.name),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: widget.isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: widget.isSelected
                      ? AppColors.getTextPrimary(context)
                      : AppColors.getTextSecondary(context).withValues(alpha: 0.6),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _getPaletteLocalizedName(BuildContext context, String name) {
  final l10n = AppLocalizations.of(context)!;
  switch (name) {
    case "Sistem": return l10n.themeSystem;
    case "Kutup": return l10n.paletteArctic;
    case "Nane": return l10n.paletteMint;
    case "Rose": return l10n.paletteRose;
    case "Lavanta": return l10n.paletteLavender;
    case "Sahra": return l10n.paletteSahara;
    case "Safir": return l10n.paletteSapphire;
    case "Bordo": return l10n.paletteBurgundy;
    case "Platin": return l10n.palettePlatinum;
    default: return name;
  }
}

