import 'package:flutter/material.dart';

/// A small circular gold star badge with the sliding sheen sweep animation.
/// Synchronized with the premium badge sweep interval.
class AnimatedPremiumStarBadge extends StatefulWidget {
  final double size;
  final double padding;

  const AnimatedPremiumStarBadge({
    super.key,
    this.size = 10,
    this.padding = 2.5,
  });

  @override
  State<AnimatedPremiumStarBadge> createState() => _AnimatedPremiumStarBadgeState();
}

class _AnimatedPremiumStarBadgeState extends State<AnimatedPremiumStarBadge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _animation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Richer gold tones to avoid washing out the white star icon
    final premiumColor = const Color(0xFFFF9100); // Deep premium orange-gold
    final shineColor = const Color(0xFFFFE082); // Warm light-gold sheen (not pure white)

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final double t = _animation.value;

        // Mathematically correct alignment bounds to guarantee that the sheen
        // starts completely off-screen on the left and ends completely off-screen on the right.
        final beginAlignment = Alignment(-3.5 + t * 5.5, -0.5);
        final endAlignment = Alignment(-2.0 + t * 5.5, 0.5);

        return Container(
          padding: EdgeInsets.all(widget.padding),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                premiumColor,
                shineColor,
                premiumColor,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: beginAlignment,
              end: endAlignment,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6D00).withValues(alpha: 0.35),
                blurRadius: 4,
                spreadRadius: 0.5,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Icon(
            Icons.star_rounded,
            color: Colors.white,
            size: widget.size,
          ),
        );
      },
    );
  }
}
