import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_constants.dart';
import 'custom_animated_icon.dart';

class CustomSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final IconData? activeIcon;
  final IconData? inactiveIcon;
  final double scalingFactor;

  const CustomSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.activeIcon = Icons.check_rounded,
    this.inactiveIcon = Icons.close_rounded,
    this.scalingFactor = 1.0,
  });

  @override
  State<CustomSwitch> createState() => _PrecisionToggleState();
}

class _PrecisionToggleState extends State<CustomSwitch> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _moveAnimation;
  late Animation<double> _stretchAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _moveAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutQuart),
    );

    // Hareketin ortasında maksimum uzama, başında ve sonunda yuvarlak form
    _stretchAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 30, end: 44).chain(CurveTween(curve: Curves.easeInQuart)), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 44, end: 30).chain(CurveTween(curve: Curves.easeOutQuart)), weight: 50),
    ]).animate(_controller);

    if (widget.value) _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(CustomSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.activeColor ?? AppColors.getPrimary(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = widget.scalingFactor;

    return GestureDetector(
      onTap: () {
        HapticFeedback.heavyImpact();
        widget.onChanged(!widget.value);
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = _moveAnimation.value;
          final currentWidth = _stretchAnimation.value * s;
          final totalWidth = 72 * s;
          final thumbSize = 30 * s;
          final padding = 4 * s;
          
          // Uzama yönüne göre pozisyonu ayarla (sağa giderken sola yaslı, sola giderken sağa yaslı uzar)
          double leftPos = padding + (t * (totalWidth - thumbSize - (padding * 2)));
          if (_controller.status == AnimationStatus.forward) {
            leftPos = padding + (t * (totalWidth - thumbSize - (padding * 2)));
          } else if (_controller.status == AnimationStatus.reverse) {
             leftPos = padding + (t * (totalWidth - thumbSize - (padding * 2)));
          }

          return Container(
            width: totalWidth,
            height: 40 * s,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20 * s),
              color: AppColors.getInnerSurface(context),
              border: Border.all(
                color: Color.lerp(
                  Colors.white.withValues(alpha: 0.05),
                  activeColor.withValues(alpha: 0.2),
                  t,
                )!,
                width: 1.5,
              ),
            ),
            child: Stack(
              children: [
                // Track Indicator (No glow)
                Positioned(
                  left: leftPos,
                  top: 5 * s,
                  child: Container(
                    width: currentWidth,
                    height: thumbSize,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(thumbSize / 2),
                      // Glow kaldırıldı
                    ),
                  ),
                ),
                // The Jelly Thumb (Sadeleştirilmiş)
                Positioned(
                  left: leftPos,
                  top: 5 * s,
                  child: Container(
                    width: currentWidth,
                    height: thumbSize,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(thumbSize / 2),
                      color: Color.lerp(
                        isDark ? Colors.white24 : Colors.black12, 
                        activeColor, 
                        t
                      ),
                      // Büyük gölgeler kaldırıldı, sadece çok hafif bir derinlik bırakıldı
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: CustomAnimatedIcon(
                        isActive: widget.value,
                        activeIcon: widget.activeIcon ?? Icons.check_rounded,
                        inactiveIcon: widget.inactiveIcon ?? Icons.close_rounded,
                        color: widget.value ? Colors.white : (isDark ? Colors.white38 : Colors.black38),
                        size: 16 * s,
                        duration: const Duration(milliseconds: 300),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
