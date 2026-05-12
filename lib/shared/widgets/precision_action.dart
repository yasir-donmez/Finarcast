import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PrecisionAction extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color? color;
  final Color? pressedColor; // Basıldığındaki renk
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final double? width;
  final double? height;
  final bool showFlash;
  final double scaleOnPress;
  final bool useHaptic;

  const PrecisionAction({
    super.key,
    required this.child,
    required this.onTap,
    this.color,
    this.pressedColor,
    this.borderRadius,
    this.padding,
    this.width,
    this.height,
    this.showFlash = true,
    this.scaleOnPress = 0.95,
    this.useHaptic = true,
  });

  @override
  State<PrecisionAction> createState() => _PrecisionActionState();
}

class _PrecisionActionState extends State<PrecisionAction> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool hasPressedColor = widget.pressedColor != null;
    
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        if (widget.useHaptic) HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _isPressed ? widget.scaleOnPress : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOutCubic,
          width: widget.width,
          height: widget.height,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: _isPressed && hasPressedColor 
                ? widget.pressedColor 
                : (widget.color ?? Colors.transparent),
            borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
          ),
          child: widget.showFlash && !hasPressedColor
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    // Flash Overlay
                    Positioned.fill(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 100),
                        opacity: _isPressed ? 1.0 : 0.0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    widget.child,
                  ],
                )
              : widget.child,
        ),
      ),
    );
  }
}
