import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../l10n/app_localizations.dart';

class ThemeColorOption {
  final Color primaryColor;
  final List<Color>? gradientColors;

  const ThemeColorOption(this.primaryColor, {this.gradientColors});
}

class ColorThemeSetting extends ConsumerWidget {
  const ColorThemeSetting({super.key});

  static const List<ThemeColorOption> _simpleColors = [
    ThemeColorOption(Color(0xFF2979FF)), // Ocean Blue
    ThemeColorOption(Color(0xFF00C853)), // Emerald Green
    ThemeColorOption(Color(0xFFD50000)), // Crimson Red
    ThemeColorOption(Color(0xFFFF8F00)), // Amber/Orange
    ThemeColorOption(Color(0xFF8E24AA)), // Deep Purple
    ThemeColorOption(Color(0xFFE91E63)), // Pink
    ThemeColorOption(Color(0xFF00BCD4)), // Cyan
    ThemeColorOption(Color(0xFF607D8B)), // Blue Grey
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
      option: ThemeColorOption(dynamicColor),
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
    // Eger gradyan varsa linear gradyan kullan, yoksa rengin koyusuyla radial gradyan yap
    final bool hasGradient =
        widget.option.gradientColors != null &&
        widget.option.gradientColors!.isNotEmpty;

    final Gradient dropGradient = hasGradient
        ? LinearGradient(
            colors: widget.option.gradientColors!,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : RadialGradient(
            colors: [
              widget.option.primaryColor,
              Color.lerp(widget.option.primaryColor, Colors.black, 0.2)!,
            ],
            center: const Alignment(-0.3, -0.3),
          );

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
              // Ana Damla
              AnimatedScale(
                duration: const Duration(milliseconds: 400),
                scale: widget.isSelected ? 1.1 : 0.85,
                curve: Curves.elasticOut,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: dropGradient,
                    border: Border.all(
                      color: Colors.white.withValues(
                        alpha: widget.isSelected ? 0.8 : 0.2,
                      ),
                      width: widget.isSelected ? 2.5 : 1,
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: widget.isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 20,
                          )
                        : (widget.isSystem
                              ? const Icon(
                                  Icons.auto_awesome_rounded,
                                  color: Colors.white,
                                  size: 18,
                                )
                              : null),
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
