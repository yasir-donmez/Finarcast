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
  late final AnimationController _wobbleController, _pressController, _rotationController;

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
    
    _rotationController = AnimationController(
      vsync: this,
      duration: widget.isAnalyzing ? const Duration(milliseconds: 500) : const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void didUpdateWidget(FinancialReactorButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnalyzing != oldWidget.isAnalyzing) {
      if (widget.isAnalyzing) {
        _rotationController.duration = const Duration(milliseconds: 500);
        _rotationController.repeat();
      } else {
        _rotationController.duration = const Duration(seconds: 3);
        _rotationController.repeat();
      }
    }
  }

  @override
  void dispose() {
    _wobbleController.dispose();
    _pressController.dispose();
    _rotationController.dispose();
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
            _rotationController,
          ]),
          builder: (context, child) {
            final scale = 1.0 - (_pressController.value * 0.08);
                
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
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrganicCore(Color color, double t, double rotation) {
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
            ),
          ),
          const Icon(
            Icons.psychology_rounded,
            color: Colors.white,
            size: 28,
          ),
        ],
      ),
    );
  }
}

class _WaterDropPainterForButton extends CustomPainter {
  final Color color;
  final double wobbleValue, rotation;

  _WaterDropPainterForButton({
    required this.color,
    required this.wobbleValue,
    required this.rotation,
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
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    
    // Arka plan
    final bgPaint = Paint()
      ..shader = RadialGradient(
        colors: [color.withValues(alpha: 0.6), color],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawPath(path, bgPaint);
    
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.white.withValues(alpha: 0.5);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _WaterDropPainterForButton oldDelegate) => true;
}
