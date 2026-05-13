import 'package:flutter/material.dart';
import '../../core/theme/app_constants.dart';

/// Finarcast Fiziksel "Buton/Kadran" Yüzeyi.
/// RotaryTimeDial'daki gerçekçi, dokunulabilir ve derinlikli tasarımı
/// diğer bileşenlerde de kullanmak için modernize edilmiş hali.
class PrecisionKnobSurface extends StatelessWidget {
  final Widget child;
  final double size;
  final Color? color;
  final EdgeInsetsGeometry? padding;

  const PrecisionKnobSurface({
    super.key,
    required this.child,
    this.size = 54,
    this.color,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = color ?? AppColors.getSurface(context);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          // 1. Fiziksel Derinlik Gölgesi (Daha keskin ve koyu)
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.4),
            offset: const Offset(4, 4),
            blurRadius: 12,
            spreadRadius: 1,
          ),
          // 2. Ters Yön Işığı (Hafif bir derinlik vurgusu)
          BoxShadow(
            color: Colors.white.withValues(alpha: isDark ? 0.04 : 0.4),
            offset: const Offset(-2, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. DÖNEN FİZİKSEL GÖVDE (Açı kadrandaki gibi -pi/2 shifted)
          Transform.rotate(
            angle: -1.5708, // -pi/2
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: surfaceColor,
                gradient: SweepGradient(
                  colors: [
                    surfaceColor,
                    surfaceColor.withValues(alpha: 0.75),
                    surfaceColor,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // 2. STATİK ÜST IŞIKLANDIRMA (Environment Highlight)
          IgnorePointer(
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.5, -0.5),
                  radius: 1.0,
                  colors: [
                    Colors.white.withValues(alpha: isDark ? 0.08 : 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      Colors.transparent,
                      Colors.white.withValues(alpha: isDark ? 0.04 : 0.12),
                      Colors.transparent,
                      Colors.black.withValues(alpha: isDark ? 0.08 : 0.04),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. İÇERİK
          Padding(
            padding: padding ?? EdgeInsets.zero,
            child: child,
          ),
        ],
      ),
    );
  }
}
