import 'package:flutter/material.dart';
import 'dart:ui';
import '../../core/theme/app_constants.dart';

/// Finarcast Yeni Nesil "Sıvı & Organik" Kapsayıcı (Fluid Container).
/// Geleneksel Neumorphism'den uzaklaşıp, Squircle kavisler,
/// Soft-Depth (Yumuşak Derinlik) ve Glassmorphism dokusunu birleştirir.
class PrecisionSurface extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final bool isGlass;
  final bool isConvex;
  final Color? color;
  final List<BoxShadow>? extraShadows;
  final double blur;
  final double? borderWidth;
  final Color? borderColor;

  const PrecisionSurface({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = AppSizes.radiusDefault * 1.5,
    this.isGlass = true,
    this.isConvex = true,
    this.color,
    this.extraShadows,
    this.blur = 15.0,
    this.borderWidth,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Aydınlık modda 'Gri' görünümü engellemek için Renk Aşılaması (Tinting)
    final Color baseSurface = color ?? AppColors.getSurface(context);
    final Color tintedSurface = isDark
        ? baseSurface
        : Color.lerp(baseSurface, color ?? AppColors.primary, 0.02)!;

    // Su damlası (Convex)
    final gradient = isConvex
        ? RadialGradient(
            center: const Alignment(-0.35, -0.45),
            radius: 1.5,
            colors: [
              isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.15),
              Colors.transparent,
              isDark
                  ? Colors.black.withValues(alpha: 0.22)
                  : AppColors.lightDarkShadow.withValues(alpha: 0.08),
            ],
            stops: const [0.0, 0.45, 1.0],
          )
        : null;

    // Çok katmanlı gölge yapısı (Multi-layered Depth)
    final List<BoxShadow> shadows =
        extraShadows ??
        [
          if (isDark) ...[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.55),
              blurRadius: isConvex ? 40 : 24,
              offset: Offset(0, isConvex ? 16 : 8),
              spreadRadius: isConvex ? -8 : -4,
            ),
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -6),
              spreadRadius: -4,
            ),
          ] else ...[
            // Aydınlık Mod: Lüks Katmanlı Gölgeler
            BoxShadow(
              color: (color ?? AppColors.lightDarkShadow).withValues(
                alpha: 0.25,
              ),
              blurRadius: 40,
              offset: const Offset(0, 15),
              spreadRadius: -10,
            ),
            BoxShadow(
              color: (color ?? AppColors.lightDarkShadow).withValues(
                alpha: 0.3,
              ),
              blurRadius: 10,
              offset: const Offset(0, 2),
              spreadRadius: -4,
            ),
          ],
        ];

    // Varsayılan çerçeve rengi (Eğer borderColor verilmemişse)
    final defaultBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.white.withValues(alpha: 0.8);

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: isGlass
            ? tintedSurface.withValues(alpha: isDark ? 0.6 : 0.92)
            : tintedSurface,
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: gradient,
        boxShadow: shadows,
        border: Border.all(
          color: borderColor ?? defaultBorderColor,
          width: borderWidth ?? 0.8,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        // BackdropFilter SADECE isGlass aktifken kullanılır.
        // sigma=0 bile olsa BackdropFilter GPU maliyeti taşır ve
        // klavye animasyonu sırasında çoklu BackdropFilter'lar GPU'yu kilitler.
        child: isGlass && blur > 0
            ? BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: _buildInnerContent(isDark),
              )
            : _buildInnerContent(isDark),
      ),
    );
  }

  Widget _buildInnerContent(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: isConvex
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.white.withValues(alpha: 0.2),
                  Colors.transparent,
                  isDark
                      ? Colors.black.withValues(alpha: 0.05)
                      : (color ?? AppColors.lightDarkShadow).withValues(
                          alpha: 0.03,
                        ),
                ],
              )
            : null,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppSizes.paddingMedium),
        child: child,
      ),
    );
  }
}
