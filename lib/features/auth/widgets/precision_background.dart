import 'dart:math' as math;
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
  const PrecisionBackground({
    super.key,
    this.child,
    this.useSystemBackground = true,
  });

  @override
  ConsumerState<PrecisionBackground> createState() =>
      _PrecisionBackgroundState();
}

class _PrecisionBackgroundState extends ConsumerState<PrecisionBackground> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final density = ref.watch(
      settingsProvider.select((s) => s.bgPatternDensity),
    );
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

    // Opacity Mapping: [0: Kapalı, 1: Hafif, 2: Orta, 3: Yoğun]
    final double opacity;
    if (density == 0) {
      opacity = 0.0;
    } else if (density == 1) {
      opacity = isDark ? 0.10 : 0.08;
    } else if (density == 2) {
      opacity = isDark ? 0.20 : 0.15;
    } else {
      opacity = isDark ? 0.30 : 0.20;
    }

    // Base layer styling
    final baseColor = isDark ? Colors.black : const Color(0xFFF5F7FA);
    Decoration baseDecoration = BoxDecoration(color: baseColor);

    if (density > 0 && bgColorStyle == 1) {
      // Zemini Boya (Gerçek, doygun renk stili)
      if (bgGradient != null) {
        baseDecoration = BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            // Alpha yerine doğrudan renkleri harmanlıyoruz (Solid painting)
            // Bu sayede "filtre" gibi değil, zemin o renkteymiş gibi durur.
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
    }

    Color neutralIconColor = isDark ? Colors.white : Colors.black;
    // Eğer zemini boyama modu aktifse, ikonları zemine göre zıt renkte seçiyoruz
    if (bgColorStyle == 1) {
      // Artık sabit siyah yerine kontrast kontrolü yapabiliriz
      // Ancak tasarım gereği "gölge" efekti için aydınlık modda siyah, karanlıkta hafif beyaz/gri iyidir.
      neutralIconColor = isDark ? Colors.white : Colors.black;
    }

    final iconColor = (bgColorStyle == 0)
        ? AppColors.getPrimary(context)
        : Colors.black; // Zemini boyalıyken veya sade modda ikonlar "gölge/derinlik" hissi için siyah

    // İkon şeffaflık ayarı - Çok yoğun olmamalı
    double iconOpacity;
    if (bgColorStyle == 0) {
      iconOpacity = opacity * 0.8; // Renkli ikonlar biraz daha yumuşak
    } else if (bgColorStyle == 1) {
      // Boyalı zeminde siyah ikonlar "oyma" veya "gölge" efekti yaratır
      // Kullanıcı talebi üzerine belirginliği ciddi oranda artırdık
      iconOpacity = isDark ? opacity * 2.2 : opacity * 1.8; 
    } else {
      iconOpacity = opacity * 0.3; // Sade modda ikonlar çok hafif
    }

    return Container(
      decoration: baseDecoration,
      child: Stack(
        children: [
          // 2. Orta katman: Desen (İkonlar)
          if (opacity > 0.0)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppAssets.getBackgroundImg(context)),
                    repeat: ImageRepeat.repeat,
                    scale: 2.8,
                    filterQuality: FilterQuality.medium,
                    colorFilter: ColorFilter.mode(
                      iconColor.withValues(alpha: iconOpacity),
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
