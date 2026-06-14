import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum SwipeDismissDirection {
  leftToRight,
  rightToLeft,
}

typedef SwipeBackgroundBuilder = Widget Function(
  BuildContext context,
  double progress,
  bool isThresholdReached,
);

class CustomDismissible extends StatefulWidget {
  final Widget child;
  final FutureOr<void> Function(SwipeDismissDirection direction) onDismissed;
  final bool enableLeftToRight;
  final bool enableRightToLeft;
  final SwipeBackgroundBuilder? leftToRightBackgroundBuilder;
  final SwipeBackgroundBuilder? rightToLeftBackgroundBuilder;
  final double dismissThreshold;

  const CustomDismissible({
    super.key,
    required this.child,
    required this.onDismissed,
    this.enableLeftToRight = false,
    this.enableRightToLeft = false,
    this.leftToRightBackgroundBuilder,
    this.rightToLeftBackgroundBuilder,
    this.dismissThreshold = 0.20,
  });

  @override
  State<CustomDismissible> createState() => _CustomDismissibleState();
}

class _CustomDismissibleState extends State<CustomDismissible>
    with SingleTickerProviderStateMixin {
  double _dragExtent = 0.0;
  late AnimationController _animController;
  late Animation<double> _animation;
  bool _dismissed = false;
  bool _hasTriggeredStartHaptic = false;
  bool _hasTriggeredThresholdHaptic = false;
  double _cardWidth = 300.0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = _animController.drive(Tween(begin: 0.0, end: 0.0));
    _animController.addListener(() {
      if (mounted) {
        setState(() {
          _dragExtent = _animation.value;
        });
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onDragStart(DragStartDetails details) {
    _animController.stop();
    _hasTriggeredStartHaptic = false;
    _hasTriggeredThresholdHaptic = false;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      double newExtent = _dragExtent + details.primaryDelta!;
      
      // Allow drag only in enabled directions
      if (!widget.enableLeftToRight && !widget.enableRightToLeft) {
        newExtent = 0.0;
      } else if (!widget.enableLeftToRight) {
        newExtent = newExtent.clamp(-_cardWidth, 0.0);
      } else if (!widget.enableRightToLeft) {
        newExtent = newExtent.clamp(0.0, _cardWidth);
      } else {
        newExtent = newExtent.clamp(-_cardWidth, _cardWidth);
      }
      
      _dragExtent = newExtent;
    });

    final ratio = _dragExtent.abs() / _cardWidth;

    // Trigger light haptic when swipe first reveals the background
    if (!_hasTriggeredStartHaptic && _dragExtent.abs() > 8) {
      _hasTriggeredStartHaptic = true;
      HapticFeedback.lightImpact();
    }

    // Trigger medium haptic when threshold is crossed
    if (!_hasTriggeredThresholdHaptic && ratio >= widget.dismissThreshold) {
      _hasTriggeredThresholdHaptic = true;
      HapticFeedback.mediumImpact();
    } else if (_hasTriggeredThresholdHaptic && ratio < widget.dismissThreshold) {
      _hasTriggeredThresholdHaptic = false;
    }
  }

  void _onDragEnd(DragEndDetails details) {
    if (_dismissed) return;

    final ratio = _dragExtent.abs() / _cardWidth;
    final velocity = details.primaryVelocity ?? 0;

    final bool isLeftToRightDismiss = widget.enableLeftToRight && 
        _dragExtent > 0 && 
        (ratio > widget.dismissThreshold || velocity > 1200);

    final bool isRightToLeftDismiss = widget.enableRightToLeft && 
        _dragExtent < 0 && 
        (ratio > widget.dismissThreshold || velocity < -1200);

    if (isLeftToRightDismiss || isRightToLeftDismiss) {
      final target = _dragExtent > 0 ? _cardWidth * 1.2 : -_cardWidth * 1.2;
      _dismissed = true;

      _animation = Tween(begin: _dragExtent, end: target).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeInCubic),
      );
      
      final direction = _dragExtent > 0 
          ? SwipeDismissDirection.leftToRight 
          : SwipeDismissDirection.rightToLeft;

      _animController.forward(from: 0).then((_) async {
        await widget.onDismissed(direction);
        if (mounted) {
          setState(() {
            _dragExtent = 0.0;
            _dismissed = false;
          });
        }
      });
      HapticFeedback.mediumImpact();
    } else {
      // Spring back
      _animation = Tween(begin: _dragExtent, end: 0.0).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
      );
      _animController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _cardWidth = constraints.maxWidth;
        final progress = (_dragExtent.abs() / _cardWidth).clamp(0.0, 1.0);
        final isLeftToRight = _dragExtent > 0;
        final showBackground = _dragExtent.abs() > 2;

        return Stack(
          children: [
            if (showBackground)
              Positioned.fill(
                child: isLeftToRight
                    ? (widget.leftToRightBackgroundBuilder?.call(context, progress, _hasTriggeredThresholdHaptic) ?? const SizedBox())
                    : (widget.rightToLeftBackgroundBuilder?.call(context, progress, _hasTriggeredThresholdHaptic) ?? const SizedBox()),
              ),

            Transform.translate(
              offset: Offset(_dragExtent, 0),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragStart: _onDragStart,
                onHorizontalDragUpdate: _onDragUpdate,
                onHorizontalDragEnd: _onDragEnd,
                child: widget.child,
              ),
            ),
          ],
        );
      },
    );
  }
}

// ==========================================
// SHARED ANIMATED TRASH ICON
// ==========================================

class AnimatedTrashIcon extends StatelessWidget {
  final double progress;
  final Color color;
  const AnimatedTrashIcon({super.key, required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 26,
      height: 28,
      child: CustomPaint(
        painter: _TrashIconPainter(
          progress: progress,
          color: color,
        ),
      ),
    );
  }
}

class _TrashIconPainter extends CustomPainter {
  final double progress;
  final Color color;

  _TrashIconPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final lidLift = (progress * -18).clamp(-8.0, 0.0);
    final lidRotation = (progress * -0.8).clamp(-0.35, 0.0);

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    final bodyTopY = centerY - 2;
    final bodyBottomY = centerY + 11;
    final bodyTopHalfWidth = 8.0;
    final bodyBottomHalfWidth = 6.0;

    final bodyPath = Path()
      ..moveTo(centerX - bodyTopHalfWidth, bodyTopY)
      ..lineTo(centerX - bodyBottomHalfWidth, bodyBottomY)
      ..lineTo(centerX + bodyBottomHalfWidth, bodyBottomY)
      ..lineTo(centerX + bodyTopHalfWidth, bodyTopY)
      ..close();

    final bodyPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(bodyPath, bodyPaint);

    final stripeY1 = bodyTopY + 3.0;
    final stripeY2 = bodyBottomY - 3.0;
    canvas.drawLine(
      Offset(centerX - 3.0, stripeY1),
      Offset(centerX - 2.5, stripeY2),
      paint..strokeWidth = 1.8,
    );
    canvas.drawLine(
      Offset(centerX + 3.0, stripeY1),
      Offset(centerX + 2.5, stripeY2),
      paint..strokeWidth = 1.8,
    );

    canvas.save();
    
    final hingeX = centerX - 10.0;
    final hingeY = centerY - 4.0 + lidLift;
    canvas.translate(hingeX, hingeY);
    canvas.rotate(lidRotation);
    canvas.translate(-hingeX, -hingeY);

    final lidY = centerY - 4.0 + lidLift;

    canvas.drawLine(
      Offset(centerX - 10.0, lidY),
      Offset(centerX + 10.0, lidY),
      paint..strokeWidth = 2.0,
    );

    final handlePath = Path()
      ..moveTo(centerX - 3.5, lidY)
      ..lineTo(centerX - 3.5, lidY - 3.5)
      ..lineTo(centerX + 3.5, lidY - 3.5)
      ..lineTo(centerX + 3.5, lidY);
    
    canvas.drawPath(handlePath, paint..strokeWidth = 1.8);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_TrashIconPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

// ==========================================
// SHARED ANIMATED CHECK ICON
// ==========================================

class AnimatedCheckIcon extends StatelessWidget {
  final double progress;
  final Color color;
  const AnimatedCheckIcon({super.key, required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    final checkProgress = ((progress - 0.05) / 0.20).clamp(0.0, 1.0);

    return SizedBox(
      width: 28,
      height: 28,
      child: CustomPaint(
        painter: _CheckIconPainter(
          checkProgress: checkProgress,
          color: color,
        ),
      ),
    );
  }
}

class _CheckIconPainter extends CustomPainter {
  final double checkProgress;
  final Color color;

  _CheckIconPainter({
    required this.checkProgress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 1.5;

    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    final outlinePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius, outlinePaint);

    if (checkProgress > 0) {
      final path = Path();
      final start = Offset(size.width * 0.28, size.height * 0.5);
      final turn = Offset(size.width * 0.45, size.height * 0.68);
      final end = Offset(size.width * 0.72, size.height * 0.35);

      final checkPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      if (checkProgress < 0.4) {
        final t = checkProgress / 0.4;
        final p = Offset.lerp(start, turn, t)!;
        path.moveTo(start.dx, start.dy);
        path.lineTo(p.dx, p.dy);
      } else {
        final t = (checkProgress - 0.4) / 0.6;
        final p = Offset.lerp(turn, end, t)!;
        path.moveTo(start.dx, start.dy);
        path.lineTo(turn.dx, turn.dy);
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, checkPaint);
    }
  }

  @override
  bool shouldRepaint(_CheckIconPainter oldDelegate) {
    return oldDelegate.checkProgress != checkProgress || oldDelegate.color != color;
  }
}

// ==========================================
// SHARED ANIMATED SKIP ICON
// ==========================================

class AnimatedSkipIcon extends StatelessWidget {
  final double progress;
  final Color color;
  const AnimatedSkipIcon({super.key, required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    final skipProgress = ((progress - 0.05) / 0.20).clamp(0.0, 1.0);

    return SizedBox(
      width: 28,
      height: 28,
      child: CustomPaint(
        painter: _SkipIconPainter(
          skipProgress: skipProgress,
          color: color,
        ),
      ),
    );
  }
}

class _SkipIconPainter extends CustomPainter {
  final double skipProgress;
  final Color color;

  _SkipIconPainter({
    required this.skipProgress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 1.5;

    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    final outlinePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius, outlinePaint);

    if (skipProgress > 0) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      // Draw two chevrons pointing to the right (fast forward)
      final start1 = Offset(size.width * 0.32, size.height * 0.32);
      final mid1 = Offset(size.width * 0.5, size.height * 0.5);
      final end1 = Offset(size.width * 0.32, size.height * 0.68);

      final start2 = Offset(size.width * 0.54, size.height * 0.32);
      final mid2 = Offset(size.width * 0.72, size.height * 0.5);
      final end2 = Offset(size.width * 0.54, size.height * 0.68);

      if (skipProgress < 0.5) {
        final t = skipProgress / 0.5;
        final pStart = Offset.lerp(start1, mid1, t)!;
        final pEnd = Offset.lerp(end1, mid1, t)!;
        final path = Path()
          ..moveTo(start1.dx, start1.dy)
          ..lineTo(pStart.dx, pStart.dy)
          ..moveTo(end1.dx, end1.dy)
          ..lineTo(pEnd.dx, pEnd.dy);
        canvas.drawPath(path, paint);
      } else {
        final path1 = Path()
          ..moveTo(start1.dx, start1.dy)
          ..lineTo(mid1.dx, mid1.dy)
          ..lineTo(end1.dx, end1.dy);
        canvas.drawPath(path1, paint);

        final t = (skipProgress - 0.5) / 0.5;
        final pStart = Offset.lerp(start2, mid2, t)!;
        final pEnd = Offset.lerp(end2, mid2, t)!;
        final path2 = Path()
          ..moveTo(start2.dx, start2.dy)
          ..lineTo(pStart.dx, pStart.dy)
          ..moveTo(end2.dx, end2.dy)
          ..lineTo(pEnd.dx, pEnd.dy);
        canvas.drawPath(path2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_SkipIconPainter oldDelegate) {
    return oldDelegate.skipProgress != skipProgress || oldDelegate.color != color;
  }
}

