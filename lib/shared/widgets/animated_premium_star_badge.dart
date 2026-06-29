import 'package:flutter/material.dart';

/// A small circular gold star badge with a premium gold gradient.
/// Optimized as a StatelessWidget to avoid continuous ticks and repaints.
class AnimatedPremiumStarBadge extends StatelessWidget {
  final double size;
  final double padding;

  const AnimatedPremiumStarBadge({
    super.key,
    this.size = 10,
    this.padding = 2.5,
  });

  @override
  Widget build(BuildContext context) {
    // Richer gold tones to avoid washing out the white star icon
    final premiumColor = const Color(0xFFFF9100); // Deep premium orange-gold
    final shineColor = const Color(0xFFFFE082); // Warm light-gold sheen (not pure white)

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            premiumColor,
            shineColor,
            premiumColor,
          ],
          stops: const [0.0, 0.5, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
        size: size,
      ),
    );
  }
}
