import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class AnimatedPremiumBadge extends StatefulWidget {
  final double fontSize;
  final bool isCapsule;
  
  const AnimatedPremiumBadge({
    super.key, 
    this.fontSize = 12, 
    this.isCapsule = false,
  });

  @override
  State<AnimatedPremiumBadge> createState() => _AnimatedPremiumBadgeState();
}

class _AnimatedPremiumBadgeState extends State<AnimatedPremiumBadge> with SingleTickerProviderStateMixin {
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
    final premiumColor = const Color(0xFFFFB300); // Altın
    final shineColor = Colors.white; // Parlama rengi
    final l10n = AppLocalizations.of(context)!;
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final double t = _animation.value;
        
        // Parlama (sheen) efektinin zıplamasını (stutter) engellemek için,
        // başlangıç ve bitiş noktalarını tamamen ekran dışına (off-screen) taşıyoruz.
        final beginAlignment = Alignment(-3.5 + t * 5.5, -0.5);
        final endAlignment = Alignment(-2.0 + t * 5.5, 0.5);
        
        final textWidget = ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              premiumColor,
              shineColor,
              premiumColor,
            ],
            stops: const [0.0, 0.5, 1.0],
            begin: beginAlignment,
            end: endAlignment,
          ).createShader(bounds),
          child: Text(
            l10n.premiumBadge,
            style: TextStyle(
              color: Colors.white,
              fontSize: widget.fontSize,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        );

        if (!widget.isCapsule) {
          return textWidget;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: premiumColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: premiumColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: textWidget,
        );
      },
    );
  }
}
