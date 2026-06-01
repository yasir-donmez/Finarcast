import 'package:flutter/material.dart';
import '../../../core/theme/app_constants.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/settings_provider.dart';

/// Finarcast "Sıvı Ruh" Arka Planı (Liquid Spirit Background).
/// Arkada yavaşça süzülen, organik formda renkli blob'lar (leke) oluşturur.
class AuthBackground extends ConsumerStatefulWidget {
  final Widget? child;
  final bool useSystemBackground;
  final bool showPattern;
  const AuthBackground({
    super.key,
    this.child,
    this.useSystemBackground = true,
    this.showPattern = false,
  });

  @override
  ConsumerState<AuthBackground> createState() =>
      _PrecisionBackgroundState();
}

class _PrecisionBackgroundState extends ConsumerState<AuthBackground> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColorStyle = ref.watch(
      settingsProvider.select((s) => s.bgColorStyle),
    );

    final accentColor = AppColors.getPrimary(context);
    final bgGradient = AppColors.getGradientColors(accentColor);
    final baseColor = AppColors.getBackground(context);

    // Base layer styling
    Decoration baseDecoration;

    if (bgColorStyle == 2) {
      // ════ SADE ════
      baseDecoration = BoxDecoration(
        color: AppColors.getThemeBackground(context, 2),
      );
    } else {
      // ════ RENKLİ ════
      if (bgGradient != null) {
        baseDecoration = BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: bgGradient
                .map((c) => isDark 
                    ? Color.lerp(const Color(0xFF07080A), c, 0.08)! 
                    : Color.lerp(baseColor, c, 0.12)!)
                .toList(),
          ),
        );
      } else {
        baseDecoration = BoxDecoration(
          color: AppColors.getThemeBackground(context, 1),
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
