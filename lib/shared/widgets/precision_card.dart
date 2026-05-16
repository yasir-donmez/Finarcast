import 'package:flutter/material.dart';
import 'dart:ui';

/// Finarcast "Hafif" Kapsayıcı (Light Card).
/// Giriş alanları ve küçük öğeler için optimize edilmiş, çok hafif buzlu cam dokusu.
class PrecisionCard extends StatelessWidget {
  final Widget child;
  final double scalingFactor;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final double blur;

  const PrecisionCard({
    super.key,
    required this.child,
    this.scalingFactor = 1.0,
    this.padding,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.blur = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16 * scalingFactor),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? EdgeInsets.all(12 * scalingFactor),
            decoration: BoxDecoration(
              color: backgroundColor ?? (isDark 
                  ? Colors.white.withValues(alpha: 0.08) 
                  : Colors.black.withValues(alpha: 0.04)),
              borderRadius: BorderRadius.circular(16 * scalingFactor),
              border: Border.all(
                color: borderColor ?? (isDark 
                    ? Colors.white.withValues(alpha: 0.12) 
                    : Colors.black.withValues(alpha: 0.08)),
                width: 0.5,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
