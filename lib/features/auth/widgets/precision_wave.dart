import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Finarcast "Sıvı Geçiş Dalgası" (Liquid Transition Wave).
/// Ekranın bir köşesinden başlayıp tüm ekranı kaplayan enerjik bir renk dalgası.
class PrecisionWave extends StatefulWidget {
  final AnimationController controller;
  final Color color;
  final bool isTriggered;

  const PrecisionWave({
    super.key,
    required this.controller,
    required this.color,
    required this.isTriggered,
  });

  @override
  State<PrecisionWave> createState() => _PrecisionWaveState();
}

class _PrecisionWaveState extends State<PrecisionWave> {
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: _WavePainter(
          animation: widget.controller,
          color: widget.color,
          isTriggered: widget.isTriggered,
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;
  final bool isTriggered;

  _WavePainter({
    required this.animation,
    required this.color,
    required this.isTriggered,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final progress = animation.value;
    
    if (progress <= 0 || progress >= 1) {
      return;
    }
    
    // Safety check for invalid, empty or NaN sizes
    if (size.isEmpty ||
        size.width.isInfinite ||
        size.height.isInfinite ||
        size.width.isNaN ||
        size.height.isNaN) {
      return;
    }

    final paint = Paint()
      ..color = color.withValues(
        alpha: (math.sin(progress * math.pi) * 0.85).clamp(0.0, 0.85),
      )
      ..style = PaintingStyle.fill;

    // Dalga Merkez Başlangıcı (Sol Üst)
    const Offset center = Offset(0, 0);
    // Maksimum çap (Ekran köşegeni)
    final double maxRadius = math.sqrt(size.width * size.width + size.height * size.height);
    
    // Geçiş İlerlemesi (Surge Effect)
    // Progress 0.0 -> Radius 0
    // Progress 1.0 -> Radius full + overshoot
    final double currentRadius = maxRadius * progress * 2.0;

    final path = Path();
    
    // Organik dalga formu (Zenginleştirilmiş fazlar)
    for (double i = 0; i <= 90; i += 2) { // Daha sık örnekleme ile daha pürüzsüz
      final double radians = i * (math.pi / 180);
      // Çok katmanlı dalga bozulması
      final double waveDistortion = 35 * math.sin(progress * 3 * math.pi + radians * 8) +
                                   15 * math.cos(progress * 5 * math.pi + radians * 4);
      
      final double x = center.dx + (currentRadius + waveDistortion) * math.cos(radians);
      final double y = center.dy + (currentRadius + waveDistortion) * math.sin(radians);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    path.lineTo(0, size.height); // Alt Köşe
    path.lineTo(0, 0); // Başlangıç
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) => 
      oldDelegate.animation != animation || 
      oldDelegate.color != color || 
      oldDelegate.isTriggered != isTriggered;
}

