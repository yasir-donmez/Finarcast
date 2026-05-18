import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/settings_provider.dart';

/// Finarcast "Hafif" Kapsayıcı (Light Card).
/// Mekansal Adaptif Cam Sistemine Entegre Edilmiştir.
class PrecisionCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColorStyle = ref.watch(settingsProvider.select((s) => s.bgColorStyle));
    
    bool activeIsGlass = true;
    double activeBlur = blur;
    Color activeBgColor;
    Color activeBorderColor;

    if (bgColorStyle == 2) {
      // 1. SADE MOD (Mat & Katı)
      activeIsGlass = false;
      activeBlur = 0.0;
      activeBgColor = backgroundColor ?? (isDark ? const Color(0xFF161720) : Colors.white);
      activeBorderColor = borderColor ?? (isDark 
          ? const Color(0xFF2A2B36) 
          : const Color(0xFFE4E7EB));
    } else if (bgColorStyle == 1) {
      // 3. ZEMİNİ BOYA MODU (Doygun Mekansal / Koyu Cam)
      activeIsGlass = true;
      activeBlur = 20.0;
      activeBgColor = backgroundColor ?? (isDark 
          ? Colors.black.withValues(alpha: 0.35) 
          : Colors.white.withValues(alpha: 0.45));
      activeBorderColor = borderColor ?? (isDark 
          ? Colors.white.withValues(alpha: 0.12) 
          : Colors.black.withValues(alpha: 0.15));
    } else {
      // 2. HAFİF BOYALI MOD (Pürüzsüz Mekansal / VisionOS)
      activeIsGlass = true;
      activeBlur = 12.0;
      activeBgColor = backgroundColor ?? (isDark 
          ? Colors.white.withValues(alpha: 0.04) 
          : Colors.black.withValues(alpha: 0.04));
      activeBorderColor = borderColor ?? (isDark 
          ? Colors.white.withValues(alpha: 0.15) 
          : Colors.black.withValues(alpha: 0.10));
    }

    final innerContainer = Container(
      padding: padding ?? EdgeInsets.all(12 * scalingFactor),
      decoration: BoxDecoration(
        color: activeBgColor,
        borderRadius: BorderRadius.circular(16 * scalingFactor),
        border: Border.all(
          color: activeBorderColor,
          width: 0.5,
        ),
      ),
      child: child,
    );

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16 * scalingFactor),
        child: activeIsGlass
            ? BackdropFilter(
                filter: ImageFilter.blur(sigmaX: activeBlur, sigmaY: activeBlur),
                child: innerContainer,
              )
            : innerContainer,
      ),
    );
  }
}
