import 'package:flutter/material.dart';
import '../../core/theme/app_constants.dart';

class CustomAnimatedIcon extends StatelessWidget {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final bool isActive;
  final Color? color;
  final double size;
  final Duration duration;

  const CustomAnimatedIcon({
    super.key,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.isActive,
    this.color,
    this.size = 20,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.linear,
      switchOutCurve: Curves.linear,
      transitionBuilder: (Widget child, Animation<double> animation) {
        final isIncoming = child.key == ValueKey<bool>(isActive);
        
        return RotationTransition(
          turns: isIncoming 
              ? Tween<double>(begin: isActive ? -0.2 : 0.2, end: 0.0).animate(CurvedAnimation(
                  parent: animation, 
                  curve: Curves.easeOutBack,
                ))
              : Tween<double>(begin: isActive ? 0.2 : -0.2, end: 0.0).animate(CurvedAnimation(
                  parent: animation, 
                  curve: Curves.easeInBack,
                )),
          child: ScaleTransition(
            scale: isIncoming
              ? Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                  parent: animation, 
                  curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
                ))
              : animation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          ),
        );
      },
      child: Icon(
        isActive ? activeIcon : inactiveIcon,
        key: ValueKey<bool>(isActive),
        color: color ?? AppColors.getPrimary(context),
        size: size,
      ),
    );
  }
}
