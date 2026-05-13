import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_constants.dart';

/// Finarcast "Sıvı Ruh" Arka Planı (Liquid Spirit Background).
/// Arkada yavaşça süzülen, organik formda renkli blob'lar (leke) oluşturur.
class PrecisionBackground extends StatefulWidget {
  final Widget? child;
  final bool useSystemBackground;
  const PrecisionBackground({
    super.key, 
    this.child,
    this.useSystemBackground = true,
  });

  @override
  State<PrecisionBackground> createState() => _PrecisionBackgroundState();
}

class _PrecisionBackgroundState extends State<PrecisionBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Stack(
      children: [
        // Ana Arka Plan Rengi
        if (widget.useSystemBackground)
          Positioned.fill(
            child: Container(
              color: AppColors.getBackground(context),
            ),
          ),
         // Hareketli Blob'lar
        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _LiquidPainter(
                animation: _controller,
                primaryColor: AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.2),
                secondaryColor: AppColors.secondary.withValues(alpha: isDark ? 0.12 : 0.15),
                isDark: isDark,
              ),
            ),
          ),
        ),
        
        // Üstteki İçerik
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class _LiquidPainter extends CustomPainter {
  final Animation<double> animation;
  final Color primaryColor;
  final Color secondaryColor;
  final bool isDark;

  _LiquidPainter({
    required this.animation,
    required this.primaryColor,
    required this.secondaryColor,
    required this.isDark,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final progress = animation.value;
    final paint = Paint()..style = PaintingStyle.fill;
    
    // 🎨 DİNAMİK RENK GEÇİŞİ (Dynamic Color Cycle)
    final colors = [
      primaryColor,
      secondaryColor,
      const Color(0xFF7C4DFF).withValues(alpha: isDark ? 0.15 : 0.2), // Deep Purple
      const Color(0xFF448AFF).withValues(alpha: isDark ? 0.15 : 0.2), // Blue
      primaryColor,
    ];
    
    final section = (progress * (colors.length - 1)).floor();
    final localProgress = (progress * (colors.length - 1)) % 1.0;
    final waveColor = Color.lerp(colors[section], colors[section + 1], localProgress)!;

    // 1. ANA DALGA (Master Wave - Sol Üstten Süpüren)
    _drawBlob(
      canvas, 
      size, 
      paint, 
      progress,
      color: waveColor,
      center: Offset(
        size.width * (-0.15 + 0.3 * math.sin(progress * 2 * math.pi)),
        size.height * (-0.15 + 0.3 * math.cos(progress * 2 * math.pi)),
      ),
      radius: size.width * (0.8 + 0.2 * math.sin(progress * math.pi)),
      variation: 0.25 * math.sin(progress * 2 * math.pi),
    );

    // 2. İKİNCİL RENKLİ DALGA (Secondary Color Wave)
    _drawBlob(
      canvas, 
      size, 
      paint, 
      progress,
      color: Color.lerp(secondaryColor, primaryColor, math.sin(progress * math.pi).abs())!,
      center: Offset(
        size.width * (0.8 - 0.2 * math.cos(progress * 2 * math.pi)),
        size.height * (0.85 - 0.2 * math.sin(progress * 2 * math.pi)),
      ),
      radius: size.width * 0.6,
      variation: 0.2 * math.cos(progress * 3 * math.pi),
    );

    // 3. MERKEZİ ORGANİK FORMLAR (Existing Blobs for Depth)
    _drawBlob(
      canvas, 
      size, 
      paint, 
      progress,
      color: waveColor.withValues(alpha: 0.05),
      center: Offset(
        size.width * (0.5 + 0.25 * math.sin(progress * math.pi)),
        size.height * (0.4 + 0.2 * math.cos(progress * 1.5 * math.pi)),
      ),
      radius: size.width * 0.45,
      variation: 0.15 * math.sin(progress * 2 * math.pi),
    );
  }

  void _drawBlob(
    Canvas canvas, 
    Size size, 
    Paint paint,
    double progress, {
    required Color color,
    required Offset center,
    required double radius,
    required double variation,
  }) {
    paint.color = color;
    paint.maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.65); // Daha yumuşak geçiş
    
    final path = Path();
    const int segments = 12; // Daha yumuşak kenarlar
    for (int i = 0; i <= segments; i++) {
      final double angle = (i * 2 * math.pi) / segments;
      final double currentRadius = radius * (1.0 + variation * math.sin(angle * 3 + progress * 2 * math.pi));
      final double x = center.dx + currentRadius * math.cos(angle);
      final double y = center.dy + currentRadius * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LiquidPainter oldDelegate) => 
      oldDelegate.animation != animation || 
      oldDelegate.primaryColor != primaryColor || 
      oldDelegate.secondaryColor != secondaryColor || 
      oldDelegate.isDark != isDark;
}
