import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../l10n/app_localizations.dart';

class ColorThemeSetting extends ConsumerWidget {
  const ColorThemeSetting({super.key});

  static const List<Color> _palette = [
    Color(0xFF00E5FF), // Finarcast Cyan
    Color(0xFF7C4DFF), // Royal Purple
    Color(0xFFFF6D00), // Sunset Orange
    Color(0xFF00C853), // Emerald Green
    Color(0xFFFF1744), // Ruby Red
    Color(0xFF2979FF), // Ocean Blue
    Color(0xFFFFD600), // Gold
    Color(0xFFF50057), // Pink
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentColorValue = ref.watch(settingsProvider.select((s) => s.accentColorValue));
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
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _palette.length + 1, // +1 for System option
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Sistem Seçeneği (Dynamic Color)
                  final isSelected = currentColorValue == 0;
                  final dynamicColor = ref.watch(dynamicColorProvider);
                  
                  return LiquidColorDrop(
                    color: dynamicColor,
                    isSelected: isSelected,
                    isSystem: true,
                    onTap: () {
                      if (isSelected) return;
                      HapticFeedback.heavyImpact();
                      ref.read(settingsProvider.notifier).setAccentColor(0);
                    },
                  );
                }

                final color = _palette[index - 1];
                final isSelected = currentColorValue == color.toARGB32();

                return LiquidColorDrop(
                  color: color,
                  isSelected: isSelected,
                  onTap: () {
                    if (isSelected) return;
                    HapticFeedback.heavyImpact();
                    ref.read(settingsProvider.notifier).setAccentColor(color.toARGB32());
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class LiquidColorDrop extends StatefulWidget {
  final Color color;
  final bool isSelected;
  final bool isSystem;
  final VoidCallback onTap;

  const LiquidColorDrop({
    super.key,
    required this.color,
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
                    gradient: RadialGradient(
                      colors: [
                        widget.color,
                        Color.lerp(widget.color, Colors.black, 0.2)!,
                      ],
                      center: const Alignment(-0.3, -0.3),
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: widget.isSelected ? 0.8 : 0.2),
                      width: widget.isSelected ? 2.5 : 1,
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: widget.isSelected
                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                        : (widget.isSystem 
                            ? const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18)
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
