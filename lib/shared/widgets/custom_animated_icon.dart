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
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  Widget build(BuildContext context) {
    final currentIcon = isActive ? activeIcon : inactiveIcon;
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.easeInOutCubic,
      switchOutCurve: Curves.easeInOutCubic,
      transitionBuilder: (Widget child, Animation<double> animation) {
        final isIncoming = child.key == ValueKey<IconData>(currentIcon);
        
        if (isIncoming) {
          // Gelen ikon: Yumuşak bir şekilde dönerek ve büyüyerek gelir (0.35'ten başlar)
          return RotationTransition(
            turns: Tween<double>(begin: -0.12, end: 0.0).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            )),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.35, end: 1.0).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOutCubic,
              )),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOutCubic,
                )),
                child: child,
              ),
            ),
          );
        } else {
          // Giden ikon: Yumuşak bir şekilde dönerek küçülür (0.35'e kadar) ve kaybolur
          return RotationTransition(
            turns: Tween<double>(begin: 0.12, end: 0.0).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            )),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.35, end: 1.0).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOutCubic,
              )),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOutCubic,
                )),
                child: child,
              ),
            ),
          );
        }
      },
      child: Icon(
        currentIcon,
        key: ValueKey<IconData>(currentIcon),
        color: color ?? AppColors.getPrimary(context),
        size: size,
      ),
    );
  }
}
