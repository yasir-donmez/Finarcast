import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_constants.dart';
import '../../core/providers/settings_provider.dart';

/// Finarcast Mat ve Katı Yüzey Kapsayıcısı (Solid Surface).
/// Tasarım Dili: Mekansal Adaptif Mat Yüzey Sistemi (Spatial Adaptive Solid Surface).
class SolidSurface extends ConsumerWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? color;
  final double? borderWidth;
  final Color? borderColor;
  final bool showShadow;
  final double opacityMultiplier;
  final Duration animationDuration;

  const SolidSurface({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = AppSizes.radiusDefault * 1.5,
    this.color,
    this.borderWidth,
    this.borderColor,
    this.showShadow = true,
    this.opacityMultiplier = 1.0,
    this.animationDuration = const Duration(milliseconds: 300),
    @Deprecated('Yeni sade tasarımda düz yüzeyler tercih ediliyor') bool isConvex = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColorStyle = ref.watch(settingsProvider.select((s) => s.bgColorStyle));
    
    Color activeSurfaceColor;
    Color activeBorderColor;

    if (bgColorStyle == 2) {
      // 1. SADE MOD (Mat & Katı - Sabit Gri/Beyaz)
      activeSurfaceColor = color ?? AppColors.getThemeSurface(context, 2);
      activeBorderColor = borderColor ?? AppColors.getThemeBorder(context, 2);
    } else {
      // 2. RENKLİ MOD (Mat & Katı - Tema Uyumlu Renkli) - Varsayılan
      activeSurfaceColor = color ?? AppColors.getThemeSurface(context, 1);
      activeBorderColor = borderColor ?? AppColors.getThemeBorder(context, 1);
    }

    final List<BoxShadow> shadows = [
      BoxShadow(
        color: Colors.black.withValues(alpha: (isDark ? 0.25 : 0.08) * opacityMultiplier),
        blurRadius: 30,
        offset: const Offset(0, 10),
        spreadRadius: -5,
      ),
    ];

    final decoration = BoxDecoration(
      color: activeSurfaceColor.withValues(alpha: activeSurfaceColor.a * opacityMultiplier),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: activeBorderColor.withValues(alpha: activeBorderColor.a * opacityMultiplier),
        width: borderWidth ?? 0.5,
      ),
      boxShadow: showShadow ? shadows : null,
    );

    final innerPadding = padding ?? const EdgeInsets.all(AppSizes.paddingMedium);

    return animationDuration == Duration.zero
        ? Container(
            width: width,
            height: height,
            margin: margin,
            padding: innerPadding,
            decoration: decoration,
            clipBehavior: Clip.antiAlias,
            child: child,
          )
        : AnimatedContainer(
            duration: animationDuration,
            curve: Curves.easeInOut,
            width: width,
            height: height,
            margin: margin,
            padding: innerPadding,
            decoration: decoration,
            clipBehavior: Clip.antiAlias,
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
