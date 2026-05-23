import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../l10n/app_localizations.dart';

class ThemeColorOption {
  final Color primaryColor;
  final List<Color>? gradientColors;
  final Color? secondaryColor; // Basit renkler için manuel ikincil renk tanımı

  const ThemeColorOption(this.primaryColor, {this.gradientColors, this.secondaryColor});
}

class ColorThemeSetting extends ConsumerWidget {
  const ColorThemeSetting({super.key});

  static const List<ThemeColorOption> _simpleColors = [
    ThemeColorOption(Color(0xFF2979FF), secondaryColor: Color(0xFF1565C0)), // Ocean Blue -> Koyu Mavi
    ThemeColorOption(Color(0xFF00C853), secondaryColor: Color(0xFF003300)), // Emerald Green -> Koyu Yeşil
    ThemeColorOption(Color(0xFFD50000), secondaryColor: Color(0xFFFF5252)), // Crimson Red -> Açık Kırmızı
    ThemeColorOption(Color(0xFFFF8F00), secondaryColor: Color(0xFFFFE082)), // Amber/Orange -> Açık Kehribar
    ThemeColorOption(Color(0xFF8E24AA), secondaryColor: Color(0xFFE1BEE7)), // Deep Purple -> Açık Lila
    ThemeColorOption(Color(0xFFE91E63), secondaryColor: Color(0xFFF8BBD0)), // Pink -> Açık Pembe
    ThemeColorOption(Color(0xFF00BCD4), secondaryColor: Color(0xFFB2EBF2)), // Cyan -> Açık Turkuaz
    ThemeColorOption(Color(0xFF607D8B), secondaryColor: Color(0xFFCFD8DC)), // Blue Grey -> Açık Gri
  ];

  static const List<ThemeColorOption> vibrantColors = [
    // Sunset (Sıcak Turuncu -> Modern Pembe)
    ThemeColorOption(Color(0xFFF50057), gradientColors: [Color(0xFFF093FB), Color(0xFFF5576C)]), 
    // Aurora (Derin Mor -> Canlı İndigo)
    ThemeColorOption(Color(0xFF8A2387), gradientColors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)]), 
    // Deep Ocean (Koyu Mavi -> Kristal Turkuaz)
    ThemeColorOption(Color(0xFF2193B0), gradientColors: [Color(0xFF1CB5E0), Color(0xFF000851)]), 
    // Emerald (Derin Yeşil -> Deniz Yeşili)
    ThemeColorOption(Color(0xFF11998E), gradientColors: [Color(0xFF00B09B), Color(0xFF96C93D)]), 
    // Royal (Asil Mor -> Altın Dokunuş)
    ThemeColorOption(Color(0xFF6A11CB), gradientColors: [Color(0xFF6A11CB), Color(0xFF2575FC)]), 
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentColorValue = ref.watch(
      settingsProvider.select((s) => s.accentColorValue),
    );
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.colorTheme,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: AppColors.getTextPrimary(context),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 64,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                // 1. Sistem Seçeneği
                _buildSystemDrop(context, ref, currentColorValue),

                _buildDivider(context),

                // 2. Basit Renkler
                ..._simpleColors.map(
                  (option) => _buildColorDrop(ref, option, currentColorValue),
                ),

                _buildDivider(context),

                // 3. Canlı (Gradyan) Renkler
                ...vibrantColors.map(
                  (option) => _buildColorDrop(ref, option, currentColorValue),
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

  Widget _buildSystemDrop(
    BuildContext context,
    WidgetRef ref,
    int currentColorValue,
  ) {
    final isSelected = currentColorValue == 0;
    final dynamicColor = ref.watch(dynamicColorProvider);

    return LiquidColorDrop(
      option: ThemeColorOption(dynamicColor, secondaryColor: Color.lerp(dynamicColor, Colors.black, 0.3)),
      isSelected: isSelected,
      isSystem: true,
      onTap: () {
        if (isSelected) return;
        HapticFeedback.heavyImpact();
        ref.read(settingsProvider.notifier).setAccentColor(0);
      },
    );
  }

  Widget _buildColorDrop(
    WidgetRef ref,
    ThemeColorOption option,
    int currentColorValue,
  ) {
    final isSelected = currentColorValue == option.primaryColor.toARGB32();

    return LiquidColorDrop(
      option: option,
      isSelected: isSelected,
      onTap: () {
        if (isSelected) return;
        HapticFeedback.heavyImpact();
        ref
            .read(settingsProvider.notifier)
            .setAccentColor(option.primaryColor.toARGB32());
      },
    );
  }
}

class LiquidColorDrop extends StatefulWidget {
  final ThemeColorOption option;
  final bool isSelected;
  final bool isSystem;
  final VoidCallback onTap;

  const LiquidColorDrop({
    super.key,
    required this.option,
    required this.isSelected,
    required this.onTap,
    this.isSystem = false,
  });

  @override
  State<LiquidColorDrop> createState() => _LiquidColorDropState();
}

class _LiquidColorDropState extends State<LiquidColorDrop> {
  @override
  Widget build(BuildContext context) {
    // Renkleri belirle (Telegram stili dış daire ve iç daire)
    final bool hasGradient =
        widget.option.gradientColors != null &&
        widget.option.gradientColors!.isNotEmpty;

    final Color outerColor = hasGradient 
        ? widget.option.gradientColors!.first 
        : widget.option.primaryColor;

    final Color innerColor = hasGradient 
        ? widget.option.gradientColors!.last 
        : (widget.option.secondaryColor ?? Color.lerp(widget.option.primaryColor, Colors.white, 0.35)!);

    return GestureDetector(
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: SizedBox(
          width: 52,
          height: 64,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Dış Daire (Telegram stili ana renk)
              AnimatedScale(
                duration: const Duration(milliseconds: 300),
                scale: widget.isSelected ? 1.15 : 0.9,
                curve: Curves.easeOutBack,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: outerColor,
                    border: Border.all(
                      color: AppColors.getTextPrimary(context).withValues(
                        alpha: widget.isSelected ? 0.8 : 0.12,
                      ),
                      width: widget.isSelected ? 2.5 : 1,
                    ),
                    boxShadow: const [],
                  ),
                  child: Center(
                    // İç Daire (Telegram stili ikincil/vurgu rengi)
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: innerColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          )
                        ],
                      ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
