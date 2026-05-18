import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_constants.dart';
import '../../core/providers/settings_provider.dart';

/// Finarcast "Yeni Nesil" Buzlu Cam Kapsayıcı (Frosted Glass Surface).
/// Tasarım Dili: Mekansal Adaptif Cam Sistemi (Spatial Adaptive Glass).
class PrecisionSurface extends ConsumerWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final bool isGlass;
  final Color? color;
  final double blur;
  final double? borderWidth;
  final Color? borderColor;
  final bool showShadow;
  final double opacityMultiplier;

  const PrecisionSurface({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = AppSizes.radiusDefault * 1.5,
    this.isGlass = true,
    this.color,
    this.blur = 8.0, 
    this.borderWidth,
    this.borderColor,
    this.showShadow = true,
    this.opacityMultiplier = 1.0,
    @Deprecated('Yeni sade tasarımda düz yüzeyler tercih ediliyor') bool isConvex = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColorStyle = ref.watch(settingsProvider.select((s) => s.bgColorStyle));
    
    // Mekansal Adaptif Sistem Parametreleri
    bool activeIsGlass = isGlass;
    double activeBlur = blur;
    Color activeGlassTint;
    double activeGlassOpacity;
    Color activeSurfaceColor;
    Color activeBorderColor;

    if (bgColorStyle == 2) {
      // 1. SADE MOD (Mat & Katı)
      activeIsGlass = false;
      activeBlur = 0.0;
      activeSurfaceColor = color ?? (isDark ? const Color(0xFF161720) : Colors.white);
      activeBorderColor = borderColor ?? (isDark 
          ? const Color(0xFF2A2B36) 
          : const Color(0xFFE4E7EB));
      activeGlassTint = Colors.transparent;
      activeGlassOpacity = 0.0;
    } else if (bgColorStyle == 1) {
      // 3. ZEMİNİ BOYA MODU (Doygun Mekansal / Koyu Cam)
      activeIsGlass = isGlass;
      activeBlur = 20.0;
      activeGlassTint = isDark ? Colors.black : Colors.white;
      activeGlassOpacity = (isDark ? 0.35 : 0.45) * opacityMultiplier;
      activeSurfaceColor = color ?? AppColors.getSurface(context);
      activeBorderColor = borderColor ?? (isDark 
          ? Colors.white.withValues(alpha: 0.12 * opacityMultiplier)
          : Colors.black.withValues(alpha: 0.15 * opacityMultiplier));
    } else {
      // 2. HAFİF BOYALI MOD (Pürüzsüz Mekansal / VisionOS)
      activeIsGlass = isGlass;
      activeBlur = 12.0;
      activeGlassTint = isDark ? Colors.white : Colors.black;
      activeGlassOpacity = (isDark ? 0.04 : 0.06) * opacityMultiplier;
      activeSurfaceColor = color ?? AppColors.getSurface(context);
      activeBorderColor = borderColor ?? (isDark 
          ? Colors.white.withValues(alpha: 0.15 * opacityMultiplier)
          : Colors.black.withValues(alpha: 0.10 * opacityMultiplier));
    }

    final List<BoxShadow> shadows = [
      BoxShadow(
        color: Colors.black.withValues(alpha: (isDark ? 0.25 : 0.08) * opacityMultiplier),
        blurRadius: 30,
        offset: const Offset(0, 10),
        spreadRadius: -5,
      ),
    ];

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: CustomPaint(
        painter: showShadow ? HollowShadowPainter(
          borderRadius: borderRadius,
          shadows: shadows,
        ) : null,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: activeIsGlass 
            ? BackdropFilter(
                filter: ImageFilter.blur(sigmaX: activeBlur, sigmaY: activeBlur),
                child: _buildInnerContainer(activeGlassTint, activeGlassOpacity, activeBorderColor, activeSurfaceColor, activeIsGlass),
              )
            : _buildInnerContainer(activeGlassTint, activeGlassOpacity, activeBorderColor, activeSurfaceColor, activeIsGlass),
        ),
      ),
    );
  }

  Widget _buildInnerContainer(Color tint, double opacity, Color bColor, Color sColor, bool glass) {
    return Container(
      padding: padding ?? const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: glass 
            ? tint.withValues(alpha: opacity) 
            : sColor.withValues(alpha: sColor.a * opacityMultiplier),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: bColor,
          width: borderWidth ?? 0.5,
        ),
      ),
      child: child,
    );
  }
}

/// İçi boş gölge çizici (Hollow Shadow Painter)
class HollowShadowPainter extends CustomPainter {
  final double borderRadius;
  final List<BoxShadow> shadows;

  HollowShadowPainter({required this.borderRadius, required this.shadows});

  @override
  void paint(Canvas canvas, Size size) {
    if (shadows.isEmpty) return;
    
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    
    for (final shadow in shadows) {
      final paint = shadow.toPaint();
      final shadowRect = rect.shift(shadow.offset).inflate(shadow.spreadRadius);
      final shadowRRect = RRect.fromRectAndRadius(shadowRect, Radius.circular(borderRadius));
      
      canvas.save();
      
      final Path outerPath = Path()..addRect(Rect.fromLTRB(-10000, -10000, 10000, 10000));
      final Path innerPath = Path()..addRRect(rrect);
      final Path clipPath = Path.combine(PathOperation.difference, outerPath, innerPath);
      
      canvas.clipPath(clipPath);
      canvas.drawRRect(shadowRRect, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant HollowShadowPainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius || oldDelegate.shadows != shadows;
  }
}
