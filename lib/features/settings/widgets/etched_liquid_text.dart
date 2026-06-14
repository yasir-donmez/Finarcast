import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/theme/app_constants.dart';

class EtchedLiquidText extends StatefulWidget {
  final double progress;
  final Color activeColor;
  final String text;
  final double fontSize;

  const EtchedLiquidText({
    super.key,
    required this.progress,
    required this.activeColor,
    required this.text,
    this.fontSize = 44,
  });

  @override
  State<EtchedLiquidText> createState() => _EtchedLiquidTextState();
}

class _EtchedLiquidTextState extends State<EtchedLiquidText>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _levelController;
  late Listenable _mergeListenable;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Sıvı seviyesi için "nefes alma" animasyonu
    _levelController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _mergeListenable = Listenable.merge([_waveController, _levelController]);

    // İlk açılışta dolsun, sonra yavaşça inip çıksın
    _levelController.forward().then((_) {
      if (mounted) {
        _levelController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _levelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _mergeListenable,
      builder: (context, child) {
        // progress 0 ise animasyonlu seviyeyi kullan (0.45 - 0.65 arası)
        // Start from the bottom (base level) when at the top
        const double idleLevel = 0.0;
        final double effectiveLevel = (widget.progress * (1.0 - idleLevel)) + idleLevel;

        return CustomPaint(
          size: Size(widget.fontSize * 10, widget.fontSize * 2.5), // Increased size slightly to avoid clipping
          painter: _EtchedLiquidPainter(
            progress: effectiveLevel,
            activeColor: widget.activeColor,
            text: widget.text,
            fontSize: widget.fontSize,
            waveValue: _waveController.value,
            context: context,
          ),
        );
      },
    );
  }
}

class _EtchedLiquidPainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final String text;
  final double fontSize;
  final double waveValue;
  final BuildContext context;

  _EtchedLiquidPainter({
    required this.progress,
    required this.activeColor,
    required this.text,
    required this.fontSize,
    required this.waveValue,
    required this.context,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final textStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      letterSpacing: 1.5,
      color: AppColors.getTextPrimary(context),
    );

    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    final textRect = Rect.fromCenter(
      center: center,
      width: textPainter.width,
      height: textPainter.height,
    );

    // Inflate more to capture all shadow effects
    canvas.saveLayer(textRect.inflate(100), Paint());

    // 1. RIM HIGHLIGHT
    final bezelTP = TextPainter(
      text: TextSpan(
        text: text,
        style: textStyle.copyWith(
          color: AppColors.getLightShadow(context).withValues(alpha: 0.5),
          shadows: [
            Shadow(
              color: AppColors.getLightShadow(context).withValues(alpha: 0.3),
              offset: const Offset(0.8, 1.0),
              blurRadius: 1,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    bezelTP.paint(canvas, textRect.topLeft + const Offset(0.8, 1.0));

    // 2. INNER WALL SHADOW
    final darkTP = TextPainter(
      text: TextSpan(
        text: text,
        style: textStyle.copyWith(color: Colors.black.withValues(alpha: 0.8)),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    darkTP.paint(canvas, textRect.topLeft + const Offset(-1.0, -1.2));

    // 3. ETCHED BASE
    final baseTP = TextPainter(
      text: TextSpan(
        text: text,
        style: textStyle.copyWith(
          color: AppColors.getInnerSurface(context),
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.5),
              offset: const Offset(0.5, 0.5),
              blurRadius: 2.0,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    baseTP.paint(canvas, textRect.topLeft);

    if (progress > 0) {
      // Precise liquid level mapping
      final double liquidLevel = textRect.bottom - (textRect.height * progress);
      
      final Path wavePath = Path();
      wavePath.moveTo(textRect.left - 50, liquidLevel);
      
      // More fluid wave parameters
      for (double x = textRect.left - 50; x <= textRect.right + 50; x++) {
        final double wave1 = math.sin((x / 25) + (waveValue * 2 * math.pi)) * (fontSize * 0.1);
        final double wave2 = math.sin((x / 15) - (waveValue * 2 * math.pi)) * (fontSize * 0.03);
        wavePath.lineTo(x, liquidLevel + wave1 + wave2);
      }

      final Path submergedPath = Path.from(wavePath);
      submergedPath.lineTo(textRect.right + 50, textRect.bottom + 50);
      submergedPath.lineTo(textRect.left - 50, textRect.bottom + 50);
      submergedPath.close();

      // Liquid Fill - Dalganın altında kalan yazıyı TAMAMEN temizle
      final Paint erasePaint = Paint()
        ..blendMode = BlendMode.clear;
      canvas.drawPath(submergedPath, erasePaint);

      // Liquid Surface Effects - Only show the active color on the surface edge
      final Paint surfacePaint = Paint()
        ..color = activeColor.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = fontSize * 0.04
        ..blendMode = BlendMode.srcATop;
      canvas.drawPath(wavePath, surfacePaint);

      final Paint surfaceShinePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = fontSize * 0.015
        ..blendMode = BlendMode.srcATop;
      canvas.drawPath(wavePath, surfaceShinePaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _EtchedLiquidPainter old) =>
      old.progress != progress ||
      old.waveValue != waveValue ||
      old.activeColor != activeColor;
}
