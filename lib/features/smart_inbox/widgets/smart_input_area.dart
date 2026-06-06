import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math';
import '../../../core/theme/app_constants.dart';
import '../../../shared/widgets/glass_surface.dart';
import '../../../l10n/app_localizations.dart';

class SmartInputArea extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onCameraPressed;
  final VoidCallback onGalleryPressed;
  final VoidCallback onSendPressed;

  const SmartInputArea({
    super.key,
    required this.controller,
    required this.onCameraPressed,
    required this.onGalleryPressed,
    required this.onSendPressed,
  });

  @override
  State<SmartInputArea> createState() => _SmartInputAreaState();
}

class _SmartInputAreaState extends State<SmartInputArea>
    with SingleTickerProviderStateMixin {
  static const _animDuration = Duration(milliseconds: 350);
  static const _curve = Curves.easeOutBack;
  static const _reverseCurve = Curves.easeInOutCubic;

  static const _sideGap = 8.0;
  static const _sendSize = 50.0;
  static const _barHeight = 50.0;

  late final AnimationController _anim;
  late final Animation<double> _t;

  bool _isMenuExpanded = false;
  bool _hadText = false;

  bool get _hasText => widget.controller.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: _animDuration);
    _t = CurvedAnimation(
      parent: _anim,
      curve: _curve,
      reverseCurve: _reverseCurve,
    );
    _hadText = _hasText;
    widget.controller.addListener(_onTextChanged);
    if (_hasText) {
      _anim.value = 1;
    }
    
    // Trigger haptic feedback when the send button finishes detaching (medium impact)
    _anim.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        HapticFeedback.mediumImpact();
      }
    });
  }

  @override
  void didUpdateWidget(SmartInputArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTextChanged);
      widget.controller.addListener(_onTextChanged);
      final hasTextNow = _hasText;
      if (hasTextNow != _hadText) {
        _hadText = hasTextNow;
      }
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _anim.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (!mounted) return;
    final hasTextNow = _hasText;
    if (hasTextNow != _hadText) {
      HapticFeedback.selectionClick();
      _hadText = hasTextNow;
      if (hasTextNow) {
        _anim.forward();
        if (_isMenuExpanded) {
          _isMenuExpanded = false;
        }
      } else {
        _anim.reverse();
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TapRegion(
      onTapOutside: (event) {
        if (_isMenuExpanded) {
          setState(() {
            _isMenuExpanded = false;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: AnimatedBuilder(
          animation: _t,
          child: Container(
            height: _barHeight,
            padding: const EdgeInsets.only(left: 16.0),
            child: Center(
              child: TextField(
                controller: widget.controller,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) {
                  if (_hasText) widget.onSendPressed();
                },
                onTap: () {
                  if (_isMenuExpanded) {
                    setState(() {
                      _isMenuExpanded = false;
                    });
                  }
                },
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.smartInputHint,
                  hintStyle: TextStyle(
                    color: AppColors.getTextFaint(context)
                        .withValues(alpha: 0.55),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 11,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          builder: (context, textFieldChild) {
            final t = _t.value;

            final buttonSize = _sendSize; // 50.0
            
            final capsuleLeft = buttonSize + _sideGap;

            // Camera horizontal position relative to the Stack
            // Always separate at the left edge
            const cameraLeft = 0.0;

            // Send horizontal position relative to the Stack.
            // During separation, the button resists and is pulled to the left (14px tension) and snaps back.
            // During merging, it has an extremely soft pull (6px tension) for a quiet docking feel.
            final double rawTension = 4.0 * t * (1.0 - t);
            final double sendRight = rawTension * (_hasText ? 14.0 : 6.0);

            // Vertical alignment: both buttons are centered vertically in the 50px tall bar.
            // Since buttons are 50px and bar is 50px, the top offset is 0.0.
            const buttonTop = (_barHeight - _sendSize) / 2;

            final double stretchFactor = (4.0 * t * (1.0 - t)).clamp(0.0, 1.0);
            final double buttonWidth = buttonSize + 22.0 * stretchFactor;

            // When expanded, total stack height is 162px.
            final currentStackHeight = _isMenuExpanded ? 162.0 : _barHeight;

            return SizedBox(
              height: currentStackHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // 1. COMBINED GLASS BACKGROUND
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    height: _barHeight,
                    child: CombinedGlassBackground(
                      t: t,
                      isDark: isDark,
                      sendRight: sendRight,
                      buttonWidth: buttonWidth,
                    ),
                  ),

                  // 2. MAIN CAPSULE CONTENT (Static layout prevents text jitter)
                  Positioned(
                    left: capsuleLeft,
                    right: 74.0,
                    top: 0,
                    height: _barHeight,
                    child: textFieldChild!,
                  ),

                  // 3. EXPANDING MENU BUTTON (Left side)
                  Positioned(
                    left: cameraLeft,
                    top: buttonTop,
                    child: _ExpandingMenuButton(
                      isDark: isDark,
                      isExpanded: _isMenuExpanded,
                      onTapToggle: () {
                        if (!_isMenuExpanded) {
                          FocusScope.of(context).unfocus();
                        }
                        setState(() {
                          _isMenuExpanded = !_isMenuExpanded;
                        });
                      },
                      onCameraPressed: () {
                        setState(() {
                          _isMenuExpanded = false;
                        });
                        widget.onCameraPressed();
                      },
                      onGalleryPressed: () {
                        setState(() {
                          _isMenuExpanded = false;
                        });
                        widget.onGalleryPressed();
                      },
                    ),
                  ),

                  // 4. SEND BUTTON (Right side)
                  Positioned(
                    right: sendRight,
                    top: buttonTop,
                    child: _SendCircleButton(
                      isDark: isDark,
                      enabled: _hasText,
                      t: t,
                      width: buttonWidth,
                      onTap: _hasText ? widget.onSendPressed : null,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ExpandingMenuButton extends StatefulWidget {
  final bool isDark;
  final bool isExpanded;
  final VoidCallback onTapToggle;
  final VoidCallback onCameraPressed;
  final VoidCallback onGalleryPressed;

  const _ExpandingMenuButton({
    required this.isDark,
    required this.isExpanded,
    required this.onTapToggle,
    required this.onCameraPressed,
    required this.onGalleryPressed,
  });

  @override
  State<_ExpandingMenuButton> createState() => _ExpandingMenuButtonState();
}

class _ExpandingMenuButtonState extends State<_ExpandingMenuButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _heightFactor;
  late final Animation<double> _rotationAnim;
  late final Animation<double> _cameraAnim;
  late final Animation<double> _galleryAnim;

  bool _isMainPressed = false;

  void _safeSetState(VoidCallback fn) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(fn);
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _heightFactor = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInOutCubic,
    );

    _rotationAnim = Tween<double>(begin: 0.0, end: 0.125).animate(_heightFactor);

    _cameraAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.1, 0.6, curve: Curves.easeOut),
    );
    _galleryAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        HapticFeedback.mediumImpact();
      }
    });

    if (widget.isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_ExpandingMenuButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isExpanded != widget.isExpanded) {
      if (widget.isExpanded) {
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
    final l10n = AppLocalizations.of(context)!;
    return AnimatedBuilder(
      animation: _heightFactor,
      builder: (context, _) {
        final height = 50.0 + _heightFactor.value * (162.0 - 50.0);

        final contentStack = Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // 1. Camera Option Button
            Positioned(
              top: 58,
              left: 0,
              right: 0,
              height: 44,
              child: _MenuOptionItem(
                icon: Icons.camera_alt_rounded,
                tooltip: l10n.camera,
                onTap: widget.onCameraPressed,
                animation: _cameraAnim,
                isDark: widget.isDark,
              ),
            ),

            // 2. Gallery Option Button
            Positioned(
              top: 110,
              left: 0,
              right: 0,
              height: 44,
              child: _MenuOptionItem(
                icon: Icons.photo_library_rounded,
                tooltip: l10n.gallery,
                onTap: widget.onGalleryPressed,
                animation: _galleryAnim,
                isDark: widget.isDark,
              ),
            ),

            // 4. Main Toggle Button (at the top)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 50,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (_) {
                  HapticFeedback.lightImpact();
                  setState(() => _isMainPressed = true);
                },
                onTapUp: (_) => _safeSetState(() => _isMainPressed = false),
                onTapCancel: () => _safeSetState(() => _isMainPressed = false),
                onTap: widget.onTapToggle,
                child: Container(
                  color: Colors.transparent, // Ensures full hit testing
                  child: Center(
                    child: RotationTransition(
                      turns: _rotationAnim,
                      child: Icon(
                        Icons.add_rounded,
                        size: 24,
                        color: (_isMainPressed || widget.isExpanded)
                            ? AppColors.getPrimary(context)
                            : AppColors.getTextPrimary(context).withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );

        return AnimatedScale(
          scale: _isMainPressed ? 0.94 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: GlassSurface(
            borderRadius: 25,
            width: 50.0,
            height: height,
            blurSigma: 28.0,
            showShadow: true,
            backgroundColor: _isMainPressed
                ? (widget.isDark
                    ? AppColors.getThemeSurface(context, 2).withValues(alpha: 0.75)
                    : Colors.grey[200]!.withValues(alpha: 0.85))
                : (widget.isDark
                    ? Colors.black.withValues(alpha: 0.65)
                    : Colors.white.withValues(alpha: 0.75)),
            borderColor: _isMainPressed
                ? (widget.isDark
                    ? Colors.white.withValues(alpha: 0.25)
                    : Colors.black.withValues(alpha: 0.15))
                : (widget.isDark
                    ? Colors.white.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: widget.isDark ? 0.35 : 0.06),
                blurRadius: 30,
                offset: const Offset(0, 5),
              ),
            ],
            child: contentStack,
          ),
        );
      },
    );
  }
}

class _MenuOptionItem extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Animation<double> animation;
  final bool isDark;

  const _MenuOptionItem({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    required this.animation,
    required this.isDark,
  });

  @override
  State<_MenuOptionItem> createState() => _MenuOptionItemState();
}

class _MenuOptionItemState extends State<_MenuOptionItem> {
  bool _isPressed = false;

  void _safeSetState(VoidCallback fn) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(fn);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animation,
      builder: (context, child) {
        final val = widget.animation.value;
        if (val < 0.01) {
          return const SizedBox.shrink();
        }

        final bg = _isPressed
            ? (widget.isDark
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.06))
            : Colors.transparent;

        final iconColor = AppColors.getTextPrimary(context).withValues(alpha: 0.85);

        return Opacity(
          opacity: val,
          child: Center(
            child: AnimatedScale(
              scale: val,
              duration: const Duration(milliseconds: 100),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (_) => setState(() => _isPressed = true),
                onTapUp: (_) => _safeSetState(() => _isPressed = false),
                onTapCancel: () => _safeSetState(() => _isPressed = false),
                onTap: widget.onTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: bg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.icon,
                    size: 20,
                    color: iconColor,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SendCircleButton extends StatefulWidget {
  final bool isDark;
  final bool enabled;
  final double t;
  final double width;
  final VoidCallback? onTap;

  const _SendCircleButton({
    required this.isDark,
    required this.enabled,
    required this.t,
    required this.width,
    required this.onTap,
  });

  @override
  State<_SendCircleButton> createState() => _SendCircleButtonState();
}

class _SendCircleButtonState extends State<_SendCircleButton> {
  bool _isPressed = false;

  void _safeSetState(VoidCallback fn) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(fn);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final enabled = widget.enabled;
    final isDark = widget.isDark;
    final width = widget.width;

    // Calculate icon color based on enabled state, pressed state, and t transition
    final iconIdle = AppColors.getTextFaint(context).withValues(alpha: 0.5);
    final iconActive = _isPressed && enabled
        ? AppColors.getPrimary(context)
        : AppColors.getTextPrimary(context).withValues(alpha: 0.85);
    final targetIconColor = enabled ? iconActive : iconIdle;
    final iconColor = Color.lerp(iconIdle, targetIconColor, t) ?? iconIdle;

    return AnimatedScale(
      scale: (_isPressed && enabled) ? 0.94 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) {
          if (enabled) {
            HapticFeedback.lightImpact();
            setState(() => _isPressed = true);
          }
        },
        onTapUp: (_) => _safeSetState(() => _isPressed = false),
        onTapCancel: () => _safeSetState(() => _isPressed = false),
        onTap: enabled ? widget.onTap : null,
        child: SizedBox(
          width: width,
          height: 50.0,
          child: Stack(
            children: [
              // 1. Separate Glass Background (Drawn only when t >= 0.99 for smooth press scaling)
              Positioned.fill(
                child: Opacity(
                  opacity: (t >= 0.99) ? 1.0 : 0.0,
                  child: GlassSurface(
                    borderRadius: 25,
                    blurSigma: 28.0,
                    showShadow: true,
                    backgroundColor: _isPressed && enabled
                        ? (isDark
                            ? AppColors.getThemeSurface(context, 2).withValues(alpha: 0.75)
                            : Colors.grey[200]!.withValues(alpha: 0.85))
                        : (isDark
                            ? Colors.black.withValues(alpha: 0.65)
                            : Colors.white.withValues(alpha: 0.75)),
                    borderColor: _isPressed && enabled
                        ? (isDark
                            ? Colors.white.withValues(alpha: 0.25)
                            : Colors.black.withValues(alpha: 0.15))
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.15)
                            : Colors.black.withValues(alpha: 0.08)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
                        blurRadius: 30,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
              // 2. Icon (Always visible, color transition handled by iconColor, positioned to the right side of the stretch)
              Positioned(
                right: 0,
                width: 50.0,
                height: 50.0,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 2.0),
                    child: Icon(
                      Icons.send_rounded,
                      size: 20,
                      color: iconColor,
                    ),
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

class CombinedGlassBackground extends StatelessWidget {
  final double t;
  final bool isDark;
  final double sendRight;
  final double buttonWidth;

  const CombinedGlassBackground({
    super.key,
    required this.t,
    required this.isDark,
    required this.sendRight,
    required this.buttonWidth,
  });

  @override
  Widget build(BuildContext context) {
    final double clampedT = t.clamp(0.0, 1.5);
    const double buttonSize = 50.0;
    const double detachGap = 8.0;
    const double capsuleLeft = 58.0;
    final double capsuleRight = clampedT * (buttonSize + detachGap);

    final double bgOpacity = isDark ? 0.65 : 0.75;

    final normalBg = isDark
        ? Colors.black.withValues(alpha: bgOpacity)
        : Colors.white.withValues(alpha: bgOpacity);

    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.black.withValues(alpha: 0.08);

    final shadowColor = Colors.black.withValues(alpha: isDark ? 0.35 : 0.06);

    return LayoutBuilder(
      builder: (context, constraints) {
        final W = constraints.maxWidth;
        const H = 50.0;

        final Path path;
        final capsuleRightEdge = W - capsuleRight;

        final capsuleRRect = RRect.fromLTRBR(
          capsuleLeft,
          0.0,
          capsuleRightEdge.clamp(capsuleLeft, W),
          H,
          const Radius.circular(25.0),
        );

        if (t < 0.99) {
          final buttonLeftEdge = W - sendRight - buttonWidth;
          final buttonRRect = RRect.fromLTRBR(
            buttonLeftEdge.clamp(0.0, W),
            0.0,
            (W - sendRight).clamp(0.0, W),
            H,
            const Radius.circular(25.0),
          );

          final c1 = Offset(capsuleRightEdge - 25.0, 25.0);
          final c2 = Offset(buttonLeftEdge + 25.0, 25.0);

          final double d = c2.dx - c1.dx;
          if (d <= 0.0) {
            path = Path()..addRRect(capsuleRRect);
          } else {
            final capsulePath = Path()..addRRect(capsuleRRect);
            final buttonPath = Path()..addRRect(buttonRRect);

            // Calculate the perfect gooey metaball path between the capsule cap (c1) and the button (c2)
            final double ratio = (d / 58.0).clamp(0.0, 1.0);
            final double angle = (pi / 2) - (pi / 2 - 0.38) * ratio;

            final double cosA = cos(angle);
            final double sinA = sin(angle);

            // Tangent connection points on C1 and C2
            final Offset p1 = Offset(c1.dx + 25.0 * cosA, c1.dy - 25.0 * sinA);
            final Offset p4 = Offset(c1.dx + 25.0 * cosA, c1.dy + 25.0 * sinA);

            final Offset p2 = Offset(c2.dx - 25.0 * cosA, c2.dy - 25.0 * sinA);
            final Offset p3 = Offset(c2.dx - 25.0 * cosA, c2.dy + 25.0 * sinA);

            // Control points distance based on fluid dynamic spacing.
            // Using a scale that doesn't drop to 0 ensures smooth tangent curves at all distances.
            final double scale = 0.5 - 0.2 * ratio;
            final double cpDist = max(0.0, (p2.dx - p1.dx) * scale);

            final Offset cp1 = Offset(p1.dx + cpDist * sinA, p1.dy + cpDist * cosA);
            final Offset cp2 = Offset(p2.dx - cpDist * sinA, p2.dy + cpDist * cosA);

            final Offset cp3 = Offset(p3.dx - cpDist * sinA, p3.dy - cpDist * cosA);
            final Offset cp4 = Offset(p4.dx + cpDist * sinA, p4.dy - cpDist * cosA);

            final Path bridgePath = Path();
            bridgePath.moveTo(p1.dx, p1.dy);
            bridgePath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
            bridgePath.lineTo(p3.dx, p3.dy);
            bridgePath.cubicTo(cp3.dx, cp3.dy, cp4.dx, cp4.dy, p4.dx, p4.dy);
            bridgePath.close();

            final union1 = Path.combine(PathOperation.union, capsulePath, buttonPath);
            path = Path.combine(PathOperation.union, union1, bridgePath);
          }
        } else {
          path = Path()..addRRect(capsuleRRect);
        }

        return _buildCombined(path, normalBg, borderColor, shadowColor);
      },
    );
  }

  Widget _buildCombined(Path path, Color normalBg, Color borderColor, Color shadowColor) {
    return Stack(
      children: [
        // 1. Shadow Layer
        CustomPaint(
          painter: _CombinedShadowPainter(
            path: path,
            shadowColor: shadowColor,
          ),
        ),
        // 2. Backdrop Filter & Color Layer
        ClipPath(
          clipper: _CombinedPathClipper(path),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 28.0, sigmaY: 28.0),
            child: Container(
              color: normalBg,
            ),
          ),
        ),
        // 3. Border Layer
        CustomPaint(
          painter: _CombinedBorderPainter(
            path: path,
            borderColor: borderColor,
            borderWidth: 1.0,
          ),
        ),
      ],
    );
  }
}

class _CombinedPathClipper extends CustomClipper<Path> {
  final Path path;
  _CombinedPathClipper(this.path);

  @override
  Path getClip(Size size) => path;

  @override
  bool shouldReclip(covariant _CombinedPathClipper oldClipper) => oldClipper.path != path;
}

class _CombinedBorderPainter extends CustomPainter {
  final Path path;
  final Color borderColor;
  final double borderWidth;

  _CombinedBorderPainter({
    required this.path,
    required this.borderColor,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..isAntiAlias = true;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CombinedBorderPainter oldDelegate) {
    return oldDelegate.path != path ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth;
  }
}

class _CombinedShadowPainter extends CustomPainter {
  final Path path;
  final Color shadowColor;

  _CombinedShadowPainter({
    required this.path,
    required this.shadowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = shadowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15.0)
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(0, 5);
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CombinedShadowPainter oldDelegate) {
    return oldDelegate.path != path || oldDelegate.shadowColor != shadowColor;
  }
}
