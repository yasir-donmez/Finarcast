import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../shared/widgets/precision_glass_card.dart';
import '../../../core/theme/app_constants.dart';

/// Dashboard widget'larının boyut tipleri
enum DashboardWidgetSize {
  small,  // 1x1
  wide,   // 2x1
  large,  // 2x2
}

/// Tüm Dashboard widget'ları için temel sarmalayıcı.
/// Cam efekti, köşeler ve standart padding'i yönetir.
class DashboardWidget extends StatefulWidget {
  final Widget child;
  final DashboardWidgetSize size;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isEditing;

  const DashboardWidget({
    super.key,
    required this.child,
    this.size = DashboardWidgetSize.large,
    this.onTap,
    this.onLongPress,
    this.isEditing = false,
  });

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> with SingleTickerProviderStateMixin {
  late AnimationController _wiggleController;
  late Animation<double> _wiggleAnimation;

  @override
  void initState() {
    super.initState();
    _wiggleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    
    _wiggleAnimation = Tween<double>(begin: -0.015, end: 0.015).animate(
      CurvedAnimation(parent: _wiggleController, curve: Curves.easeInOut),
    );

    if (widget.isEditing) {
      _wiggleController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(DashboardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEditing && !oldWidget.isEditing) {
      _wiggleController.repeat(reverse: true);
    } else if (!widget.isEditing && oldWidget.isEditing) {
      _wiggleController.stop();
      _wiggleController.reset();
    }
  }

  @override
  void dispose() {
    _wiggleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _wiggleAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: widget.isEditing ? _wiggleAnimation.value : 0,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: widget.isEditing ? null : widget.onTap,
        onLongPress: () {
          HapticFeedback.heavyImpact();
          widget.onLongPress?.call();
        },
        child: PrecisionGlassCard(
          padding: const EdgeInsets.all(AppSizes.paddingSmall),
          borderRadius: 24, // Daha yumuşak köşeler
          blur: 20,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              widget.child,
              if (widget.isEditing)
                Positioned(
                  top: -12,
                  left: -12,
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 200),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
