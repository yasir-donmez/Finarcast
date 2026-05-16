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
    this.blur = 8.0, // Bulanıklığı düşürdük ki ince desenler silinmesin
    this.borderWidth,
    this.borderColor,
    this.showShadow = true,
    this.opacityMultiplier = 1.0,
    // isConvex artık kullanılmıyor, yeni sade tasarım dilinde düz cam tercih ediliyor
    @Deprecated('Yeni sade tasarımda düz yüzeyler tercih ediliyor') bool isConvex = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Camın içindeki hafif renk tonu (Tint) ve Opaklık (Apple/Samsung Stili)
    final Color surfaceBaseColor = color ?? AppColors.getSurface(context);
    
    // Karanlık modda çok daha şeffaf, aydınlık modda ise "sütlü cam" efekti
    final Color glassTint = isDark 
        ? Colors.white.withValues(alpha: 0.05) // Karanlıkta çok hafif beyaz sızıntısı
        : Colors.white;

    final double glassOpacity = (isDark ? 0.18 : 0.40) * opacityMultiplier; // Opaklığı %12-25'ten %18-40 seviyelerine çekerek okunabilirliği artırdık

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
                      ? Colors.white.withValues(alpha: 0.15 * opacityMultiplier) // Kenar parlaması
                      : Colors.white.withValues(alpha: 0.4 * opacityMultiplier)),
                  width: borderWidth ?? 0.5, // Daha ince kenarlar
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// İçi boş gölge çizici (Hollow Shadow Painter)
/// BackdropFilter'ın, kartın kendi gölgesini bulandırmasını (karanlık kutu hatasını) engeller.
/// Sadece kartın dışına gölge çizer, içini şeffaf bırakır.
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
      
      // İçeriyi kesmek için Path.combine kullanıyoruz (clipOp desteklenmiyor)
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
