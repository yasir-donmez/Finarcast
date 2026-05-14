import 'package:flutter/material.dart';
import 'dart:ui';
import '../../core/theme/app_constants.dart';

/// Finarcast "Yeni Nesil" Buzlu Cam Kapsayıcı (Frosted Glass Surface).
/// Tasarım Dili: Maksimum verimlilik, pürüzsüz cam dokusu ve kristal netliğinde kenarlar.
class PrecisionSurface extends StatelessWidget {
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
    this.blur = 12.0,
    this.borderWidth,
    this.borderColor,
    this.showShadow = true,
    // isConvex artık kullanılmıyor, yeni sade tasarım dilinde düz cam tercih ediliyor
    @Deprecated('Yeni sade tasarımda düz yüzeyler tercih ediliyor') bool isConvex = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppColors.getPrimary(context);
    
    // Camın içindeki hafif renk tonu (Tint)
    final Color surfaceBaseColor = color ?? AppColors.getSurface(context);
    final Color glassTint = isDark 
        ? Color.lerp(surfaceBaseColor, primaryColor, 0.03)! // Karanlıkta hafif ana renk tonu
        : Colors.white;

    final double glassOpacity = isDark ? 0.85 : 0.90; // Sıçramaları önlemek için opaklığı artırdık

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: showShadow ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
            spreadRadius: -5,
          ),
        ] : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: isGlass ? blur : 0, 
            sigmaY: isGlass ? blur : 0,
          ),
          child: Container(
            padding: padding ?? const EdgeInsets.all(AppSizes.paddingMedium),
            decoration: BoxDecoration(
              color: isGlass 
                  ? glassTint.withValues(alpha: glassOpacity) 
                  : surfaceBaseColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor ?? (isDark 
                    ? Colors.white.withValues(alpha: 0.1) 
                    : Colors.white.withValues(alpha: 0.6)),
                width: borderWidth ?? 0.8,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
