import 'package:flutter/material.dart';
import '../../../../core/theme/app_constants.dart';

class ThinkingOrb extends StatelessWidget {
  final Animation<double> breathe;
  final double size;
  
  const ThinkingOrb({
    super.key, 
    required this.breathe,
    this.size = 100,
  });
  
  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: breathe,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColors.primary,
              AppColors.secondary,
              Colors.transparent,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.5),
              blurRadius: size * 0.4,
              spreadRadius: size * 0.05,
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.psychology_rounded, 
            color: Colors.white, 
            size: size * 0.4,
          ),
        ),
      ),
    );
  }
}
