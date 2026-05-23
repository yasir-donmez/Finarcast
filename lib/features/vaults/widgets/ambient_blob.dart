import 'package:flutter/material.dart';
import 'dart:math' as math;

class AmbientBlob extends StatefulWidget {
  final Color color;
  final double size;
  const AmbientBlob({super.key, required this.color, required this.size});

  @override
  State<AmbientBlob> createState() => _PrecisionBlobState();
}

class _PrecisionBlobState extends State<AmbientBlob> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double t = _controller.value * 2 * math.pi;
        final double dx = math.sin(t) * 20;
        final double dy = math.cos(t) * 20;
        
        return Transform.translate(
          offset: Offset(dx, dy),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [widget.color, widget.color.withValues(alpha: 0)],
              ),
            ),
          ),
        );
      },
    );
  }
}
