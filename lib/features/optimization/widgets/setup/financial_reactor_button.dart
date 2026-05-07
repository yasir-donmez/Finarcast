import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_constants.dart';

class FinancialReactorButton extends ConsumerStatefulWidget {
  final bool isAnalyzing;
  final VoidCallback onTap;
  final String label;

  const FinancialReactorButton({
    super.key,
    required this.isAnalyzing,
    required this.onTap,
    required this.label,
  });

  @override
  ConsumerState<FinancialReactorButton> createState() => _FinancialReactorButtonState();
}

class _FinancialReactorButtonState extends ConsumerState<FinancialReactorButton> with TickerProviderStateMixin {
  late final AnimationController _wobbleController, _pressController, _pulseController, _rotationController, _liquidController;

  @override
  void initState() {
    super.initState();
    _wobbleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _rotationController = AnimationController(
      vsync: this,
      duration: widget.isAnalyzing ? const Duration(milliseconds: 800) : const Duration(seconds: 2),
    )..repeat();

    _liquidController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );

    if (widget.isAnalyzing) {
      _liquidController.forward();
    }
  }

  @override
  void didUpdateWidget(FinancialReactorButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnalyzing != oldWidget.isAnalyzing) {
      if (widget.isAnalyzing) {
        _rotationController.duration = const Duration(milliseconds: 800);
        _rotationController.repeat();
        // BASINCA İÇİ BOŞALACAK: Hemen sıfıra çekip sonra dolduruyoruz
        _liquidController.value = 0;
        _liquidController.forward();
      } else {
        _rotationController.duration = const Duration(seconds: 2);
        _rotationController.repeat();
        _liquidController.reverse(); // Durunca yavaşça boşalır
      }
    }
  }

  @override
  void dispose() {
    _wobbleController.dispose();
    _pressController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    _liquidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reactorColor = AppColors.getPrimary(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        _pressController.forward();
      },
      onTapUp: (_) => _pressController.reverse(),
      onTapCancel: () => _pressController.reverse(),
      onTap: widget.isAnalyzing
          ? null
          : () {
              HapticFeedback.heavyImpact();
              widget.onTap();
            },
      child: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _wobbleController,
            _pressController,
            _pulseController,
            _rotationController,
            _liquidController,
          ]),
          builder: (context, child) {
            final scale =
                (1.0 - (_pressController.value * 0.08)) *
                (1.0 + (_pulseController.value * 0.02));
                
            return Transform.scale(
              scale: scale,
              child: SizedBox(
                width: 64,
                height: 64,
                child: Center(
                  child: _buildOrganicCore(
                    reactorColor,
                    _wobbleController.value,
                    _rotationController.value * 2 * math.pi,
                    _liquidController.value,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrganicCore(Color color, double t, double rotation, double progress) {
    return IgnorePointer(
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(64, 64),
            painter: _WaterDropPainterForButton(
              color: color,
              wobbleValue: t,
              rotation: rotation,
              liquidProgress: progress,
              isAnalyzing: widget.isAnalyzing,
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, anim) => ScaleTransition(
              scale: CurvedAnimation(parent: anim, curve: Curves.elasticOut),
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: Icon(
              widget.isAnalyzing
                  ? Icons.auto_awesome_rounded
                  : Icons.psychology_rounded,
              key: ValueKey(widget.isAnalyzing),
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

class _WaterDropPainterForButton extends CustomPainter {
  final Color color;
  final double wobbleValue, rotation, liquidProgress;
  final bool isAnalyzing;

  _WaterDropPainterForButton({
    required this.color,
    required this.wobbleValue,
    required this.rotation,
    required this.liquidProgress,
    required this.isAnalyzing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    final path = Path();
    const int pointsCount = 120;
    for (int i = 0; i <= pointsCount; i++) {
      double angle = (i * 2 * math.pi) / pointsCount;
      double r = radius + math.sin(angle * 3 + wobbleValue * 2 * math.pi) * 2.0;
      double currentAngle = angle + rotation;
      double x = center.dx + r * math.cos(currentAngle);
      double y = center.dy + r * math.sin(currentAngle);
      if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
    }
    path.close();
    
    // Arka plan
    final bgPaint = Paint()
      ..shader = RadialGradient(
        colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.5)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawPath(path, bgPaint);

    if (liquidProgress > 0) {
      canvas.save();
      canvas.clipPath(path);
      
      final fillHeight = size.height * (1.1 - liquidProgress * 1.2); // Biraz daha aşağıdan başlar
      final fillPath = Path();
      
      // SENİN DALGA MATEMATİĞİN (PrecisionWave.dart'tan uyarlandı)
      fillPath.moveTo(-20, fillHeight);
      for (double x = -20; x <= size.width + 20; x += 1) {
        final double normalizedX = x / size.width;
        // 35 ve 15'lik sert bozulmaları butona uygun ölçeklendirdim (7.0 ve 3.0)
        double waveDistortion = 
            7.0 * math.sin(wobbleValue * 6 * math.pi + normalizedX * 10) +
            3.0 * math.cos(wobbleValue * 4 * math.pi + normalizedX * 6);
            
        fillPath.lineTo(x, fillHeight + waveDistortion);
      }
      fillPath.lineTo(size.width + 20, size.height + 40);
      fillPath.lineTo(-20, size.height + 40);
      fillPath.close();
        
      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.95), // Dalga tepesi daha parlak
            color.withValues(alpha: 0.9),
            color,
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
        
      canvas.drawPath(fillPath, fillPaint);
      canvas.restore();
    }
    
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.white.withValues(alpha: 0.5);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _WaterDropPainterForButton oldDelegate) => true;
}
