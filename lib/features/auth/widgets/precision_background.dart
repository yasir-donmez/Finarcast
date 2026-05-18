import 'package:flutter/material.dart';
import '../../../core/theme/app_constants.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/settings_provider.dart';
import '../../profile/widgets/settings/color_theme_setting.dart';

/// Finarcast "Sıvı Ruh" Arka Planı (Liquid Spirit Background).
/// Arkada yavaşça süzülen, organik formda renkli blob'lar (leke) oluşturur.
class PrecisionBackground extends ConsumerStatefulWidget {
  final Widget? child;
  final bool useSystemBackground;
  final bool showPattern;
  const PrecisionBackground({
    super.key,
    this.child,
    this.useSystemBackground = true,
    this.showPattern = false,
  });

  @override
  ConsumerState<PrecisionBackground> createState() =>
      _PrecisionBackgroundState();
}

class _PrecisionBackgroundState extends ConsumerState<PrecisionBackground> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColorValue = ref.watch(
      settingsProvider.select((s) => s.accentColorValue),
    );

    final bgColorStyle = ref.watch(
      settingsProvider.select((s) => s.bgColorStyle),
    );

    // Check if the current color is a vibrant gradient color
    List<Color>? bgGradient;
    for (var option in ColorThemeSetting.vibrantColors) {
      if (option.primaryColor.toARGB32() == accentColorValue) {
        bgGradient = option.gradientColors;
        break;
      }
    }

    // Base layer styling
    final baseColor = isDark ? Colors.black : const Color(0xFFF5F7FA);
    Decoration baseDecoration = BoxDecoration(color: baseColor);

    if (bgColorStyle == 1) {
      // Zemini Boya (Gerçek, doygun renk stili)
      if (bgGradient != null) {
        baseDecoration = BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            // Alpha yerine doğrudan renkleri harmanlıyoruz (Solid painting)
            colors: bgGradient
                .map((c) => isDark 
                    ? Color.lerp(Colors.black, c, 0.45)! 
                    : Color.lerp(const Color(0xFFF5F7FA), c, 0.18)!)
                .toList(),
          ),
        );
      } else {
        final primaryColor = AppColors.getPrimary(context);
        baseDecoration = BoxDecoration(
          color: isDark 
              ? Color.lerp(Colors.black, primaryColor, 0.40)
              : Color.lerp(const Color(0xFFF5F7FA), primaryColor, 0.12),
        );
      }
    } else if (bgColorStyle == 0) {
      // Hafif Boyalı (Yeni Soft Tint stili)
      if (bgGradient != null) {
        baseDecoration = BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: bgGradient
                .map((c) => isDark 
                    ? Color.lerp(Colors.black, c, 0.15)! 
                    : Color.lerp(const Color(0xFFF5F7FA), c, 0.05)!)
                .toList(),
          ),
        );
      } else {
        final primaryColor = AppColors.getPrimary(context);
        baseDecoration = BoxDecoration(
          color: isDark 
              ? Color.lerp(Colors.black, primaryColor, 0.12)
              : Color.lerp(const Color(0xFFF5F7FA), primaryColor, 0.04),
        );
      }
    }

    // Pattern Styling (Sadece Giriş/Kayıt ekranında gösterilmek üzere)
    final double patternOpacity = isDark ? 0.12 : 0.09;
    final Color patternColor = bgColorStyle == 2
        ? (isDark ? Colors.white : Colors.black)
        : AppColors.getPrimary(context);

    final double activePatternOpacity = bgColorStyle == 2
        ? patternOpacity * 0.4 // Sade modda ikonlar çok hafif
        : patternOpacity;

    return Container(
      decoration: baseDecoration,
      child: Stack(
        children: [
          // 2. Orta katman: Desen (İkonlar) - Sadece showPattern true ise çizilir
          if (widget.showPattern)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppAssets.getBackgroundImg(context)),
                    repeat: ImageRepeat.repeat,
                    scale: 2.8,
                    filterQuality: FilterQuality.medium,
                    colorFilter: ColorFilter.mode(
                      patternColor.withValues(alpha: activePatternOpacity),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),

          // Üstteki İçerik
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}
