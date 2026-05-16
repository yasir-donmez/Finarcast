import 'package:flutter/material.dart';
import '../../core/theme/app_constants.dart';
import 'precision_surface.dart';

/// Finarcast Premium "Glass" Kart.
/// PrecisionSurface'in en optimize edilmiş buzlu cam konfigürasyonunu sunar.
class PrecisionGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final Color? color;
  final double blur;
  final Color? borderColor;
  final double? borderWidth;
  final bool showShadow;
  final double opacityMultiplier;

  const PrecisionGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.color,
    this.blur = 10.0,
    this.borderColor,
    this.borderWidth,
    this.showShadow = true,
    this.opacityMultiplier = 1.0,
    // isGlass parametresi artık varsayılan olarak true ve tasarımın parçası
    bool isGlass = true, 
  });

  @override
  Widget build(BuildContext context) {
    return PrecisionSurface(
      padding: padding,
      borderRadius: borderRadius ?? AppSizes.radiusLarge,
      isGlass: true,
      blur: blur,
      color: color,
      borderColor: borderColor,
      borderWidth: borderWidth,
      showShadow: showShadow,
      opacityMultiplier: opacityMultiplier,
      child: child,
    );
  }
}
