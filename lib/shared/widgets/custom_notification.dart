import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/theme/app_constants.dart';
import 'glass_surface.dart';

enum PrecisionNotificationType {
  success,
  error,
  warning,
  info,
}

class CustomNotification {
  static OverlayEntry? _currentOverlay;

  static void show(
    BuildContext context, {
    required String message,
    PrecisionNotificationType type = PrecisionNotificationType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final oldOverlay = _currentOverlay;
    _currentOverlay = null;
    oldOverlay?.remove();

    final overlayState = Overlay.of(context);
    
    _currentOverlay = OverlayEntry(
      builder: (context) => _NotificationWidget(
        message: message,
        type: type,
        duration: duration,
        onDismiss: () {
          final temp = _currentOverlay;
          _currentOverlay = null;
          temp?.remove();
        },
      ),
    );

    overlayState.insert(_currentOverlay!);
  }

  static void success(BuildContext context, String message) {
    show(context, message: message, type: PrecisionNotificationType.success);
  }

  static void error(BuildContext context, String message) {
    show(context, message: message, type: PrecisionNotificationType.error);
  }

  static void warning(BuildContext context, String message) {
    show(context, message: message, type: PrecisionNotificationType.warning);
  }

  static void info(BuildContext context, String message) {
    show(context, message: message, type: PrecisionNotificationType.info);
  }
}

class _NotificationWidget extends StatefulWidget {
  final String message;
  final PrecisionNotificationType type;
  final Duration duration;
  final VoidCallback onDismiss;

  const _NotificationWidget({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<_NotificationWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _opacityAnimation;
  Timer? _dismissTimer;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      reverseCurve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    ));

    _controller.forward();

    _dismissTimer = Timer(widget.duration, () {
      _dismiss();
    });
  }

  void _dismiss() {
    if (_isDismissing) return;
    _isDismissing = true;
    _dismissTimer?.cancel();
    _controller.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color iconColor;
    IconData iconData;

    switch (widget.type) {
      case PrecisionNotificationType.success:
        iconColor = AppColors.success;
        iconData = Icons.check_circle_rounded;
        break;
      case PrecisionNotificationType.error:
        iconColor = AppColors.error;
        iconData = Icons.error_rounded;
        break;
      case PrecisionNotificationType.warning:
        iconColor = AppColors.warning;
        iconData = Icons.warning_rounded;
        break;
      case PrecisionNotificationType.info:
        iconColor = AppColors.info;
        iconData = Icons.info_rounded;
        break;
    }

    final topPadding = MediaQuery.of(context).padding.top + 20;

    return Positioned(
      top: topPadding,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
          position: _offsetAnimation,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: GestureDetector(
              onTap: _dismiss,
              onVerticalDragEnd: (details) {
                if (details.primaryVelocity! < 0) {
                  _dismiss();
                }
              },
              child: GlassSurface(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                borderRadius: 20,
                blurSigma: 20,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: iconColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        iconData,
                        color: AppColors.getAccentDeep(context, iconColor),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: TextStyle(
                          color: AppColors.getTextPrimary(context),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
