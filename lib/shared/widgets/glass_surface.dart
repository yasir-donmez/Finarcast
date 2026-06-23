import 'package:flutter/material.dart';
import 'dart:ui';

/// Finarcast Ortak Cam Yüzeyi (Glassmorphism).
///
/// Tüm cam efekti gerektiren bileşenler (navbar, dialog, bildirim, vb.)
/// bu tek widget'ı kullanarak tutarlı bir buzlu cam görünümü elde eder.
///
/// İç yapısı: [RepaintBoundary] → [Container(shadow)] → [ClipRRect] → [BackdropFilter] → [Container(renkli)]
///
/// Kullanım:
/// ```dart
/// GlassSurface(
///   borderRadius: 28,
///   blurSigma: 20,
///   child: Text('Merhaba'),
/// )
/// ```
class GlassSurface extends StatelessWidget {
  final Widget child;

  /// Köşe yuvarlaklığı. Varsayılan: 28.
  final double borderRadius;

  /// Bulanıklık (blur) şiddeti. Varsayılan: 18 (performans optimize).
  final double blurSigma;

  /// İç padding.
  final EdgeInsetsGeometry? padding;

  /// Dış margin.
  final EdgeInsetsGeometry? margin;

  /// Sabit genişlik (opsiyonel).
  final double? width;

  /// Sabit yükseklik (opsiyonel).
  final double? height;

  /// Özel gölgeler. null ise varsayılan gölge kullanılır.
  final List<BoxShadow>? boxShadow;

  /// Cam arka plan rengini override eder.
  /// null ise tema bazlı otomatik renk:
  /// - Dark: Colors.black @ 0.65
  /// - Light: Colors.white @ 0.75
  final Color? backgroundColor;

  /// Border rengini override eder.
  /// null ise tema bazlı otomatik renk:
  /// - Dark: Colors.white @ 0.15
  /// - Light: Colors.black @ 0.08
  final Color? borderColor;

  /// Border kalınlığı. Varsayılan: 1.0.
  final double borderWidth;

  /// Gölge gösterilsin mi? Varsayılan: true.
  final bool showShadow;

  /// Opaklık çarpanı (animasyonlu geçişler için). Varsayılan: 1.0.
  final double opacityMultiplier;

  /// Hangi kenarların çizileceğini kontrol etmek için parametreler.
  /// Not: Kısmi kenarlar çizilirken borderRadius değeri 0 olmalıdır, aksi halde Flutter hata verir.
  final bool showTopBorder;
  final bool showBottomBorder;
  final bool showLeftBorder;
  final bool showRightBorder;

  const GlassSurface({
    super.key,
    required this.child,
    this.borderRadius = 28,
    this.blurSigma = 18,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.boxShadow,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.showShadow = true,
    this.opacityMultiplier = 1.0,
    this.showTopBorder = true,
    this.showBottomBorder = true,
    this.showLeftBorder = true,
    this.showRightBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ═══════════════════════════════════════════
    // Tema Uyumlu Varsayılan Renkler
    // ═══════════════════════════════════════════
    final baseBgColor = backgroundColor ??
        (isDark
            ? Colors.black.withValues(alpha: 0.65)
            : Colors.white.withValues(alpha: 0.75));

    final baseBrdColor = borderColor ??
        (isDark
            ? Colors.white.withValues(alpha: 0.15)
            : Colors.black.withValues(alpha: 0.08));

    final bgColor = baseBgColor.withValues(alpha: baseBgColor.a * opacityMultiplier);
    final brdColor = baseBrdColor.withValues(alpha: baseBrdColor.a * opacityMultiplier);

    final defaultShadow = [
      BoxShadow(
        color: Colors.black.withValues(alpha: (isDark ? 0.35 : 0.06) * opacityMultiplier),
        blurRadius: 30,
        offset: const Offset(0, 10),
        spreadRadius: -5,
      ),
    ];

    final activeShadow = (boxShadow ?? defaultShadow).map((shadow) {
      return BoxShadow(
        color: shadow.color.withValues(alpha: shadow.color.a * opacityMultiplier),
        blurRadius: shadow.blurRadius,
        offset: shadow.offset,
        spreadRadius: shadow.spreadRadius,
      );
    }).toList();

    final activeBlurSigma = blurSigma;

    final activeBgColor = opacityMultiplier < 1.0 ? baseBgColor : bgColor;
    final activeBrdColor = opacityMultiplier < 1.0 ? baseBrdColor : brdColor;

    final hasCustomBorders = !showTopBorder || !showBottomBorder || !showLeftBorder || !showRightBorder;
    final effectiveBorder = hasCustomBorders
        ? Border(
            top: showTopBorder ? BorderSide(color: activeBrdColor, width: borderWidth) : BorderSide.none,
            bottom: showBottomBorder ? BorderSide(color: activeBrdColor, width: borderWidth) : BorderSide.none,
            left: showLeftBorder ? BorderSide(color: activeBrdColor, width: borderWidth) : BorderSide.none,
            right: showRightBorder ? BorderSide(color: activeBrdColor, width: borderWidth) : BorderSide.none,
          )
        : Border.all(
            color: activeBrdColor,
            width: borderWidth,
          );

    // ═══════════════════════════════════════════
    // Widget Hiyerarşisi
    // ═══════════════════════════════════════════
    final glassContent = BackdropFilter(
      filter: ImageFilter.blur(sigmaX: activeBlurSigma, sigmaY: activeBlurSigma, tileMode: TileMode.clamp),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: activeBgColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: effectiveBorder,
        ),
        child: child,
      ),
    );

    return RepaintBoundary(
      child: Container(
        width: width,
        height: height,
        margin: margin,
        decoration: showShadow
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: activeShadow,
              )
            : null,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: opacityMultiplier < 1.0
              ? Opacity(
                  opacity: opacityMultiplier,
                  child: glassContent,
                )
              : glassContent,
        ),
      ),
    );
  }
}
