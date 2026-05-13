import 'package:flutter/material.dart';
import 'precision_action.dart';

/// Finarcast Standart Tasarımlı İkon Butonu.
/// PrecisionAction kullanarak premium tıklama hissiyatı ve standart görsel yapı sunar.
class PrecisionIconButton extends StatelessWidget {
  final IconData? icon;
  final Widget? child;
  final VoidCallback onTap;
  final Color? color;
  final Color? backgroundColor;
  final double size;
  final double padding;
  final double borderRadius;

  const PrecisionIconButton({
    super.key,
    this.icon,
    this.child,
    required this.onTap,
    this.color,
    this.backgroundColor,
    this.size = 22,
    this.padding = 10,
    this.borderRadius = 14,
  }) : assert(icon != null || child != null, 'Either icon or child must be provided');

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? Theme.of(context).primaryColor;
    final bg = backgroundColor ?? themeColor.withValues(alpha: 0.1);

    return PrecisionAction(
      onTap: onTap,
      color: bg,
      pressedColor: themeColor.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(borderRadius),
      padding: EdgeInsets.all(padding),
      scaleOnPress: 0.92,
      child: child ?? Icon(
        icon!,
        color: themeColor,
        size: size,
      ),
    );
  }
}
