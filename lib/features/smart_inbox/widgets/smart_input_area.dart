import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../core/theme/app_constants.dart';
import '../../../shared/widgets/glass_surface.dart';

class SmartInputArea extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onCameraPressed;
  final VoidCallback onGalleryPressed;
  final VoidCallback onMicPressed;
  final VoidCallback onSendPressed;

  const SmartInputArea({
    super.key,
    required this.controller,
    required this.onCameraPressed,
    required this.onGalleryPressed,
    required this.onMicPressed,
    required this.onSendPressed,
  });

  @override
  State<SmartInputArea> createState() => _SmartInputAreaState();
}

class _SmartInputAreaState extends State<SmartInputArea>
    with SingleTickerProviderStateMixin {
  static const _animDuration = Duration(milliseconds: 350);
  static const _curve = Curves.easeOutBack;
  static const _reverseCurve = Curves.easeOutCubic;

  static const _sideGap = 8.0;
  static const _sendSize = 50.0;
  static const _barHeight = 50.0;
  static const _sendInset = 4.0;

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
    if (_hasText) _anim.value = 1;
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
                  hintText: 'Örn: "Dün Starbucks filtre kahve 120 TL"',
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

            // Send horizontal position relative to the Stack
            // When t = 0, send is at 4.0 (inside the capsule)
            // When t = 1, send is at 0.0 (outside the capsule)
            final sendRight = (1 - t) * _sendInset;

            // Vertical alignment: both buttons are centered vertically in the 50px tall bar.
            // Since buttons are 50px and bar is 50px, the top offset is 0.0.
            const buttonTop = (_barHeight - _sendSize) / 2;

            final double stretchFactor = (4.0 * t * (1.0 - t)).clamp(0.0, 1.0);
            final double buttonWidth = buttonSize + 22.0 * stretchFactor;

            // When expanded, total stack height is 218px.
            final currentStackHeight = _isMenuExpanded ? 218.0 : _barHeight;

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
                      onMicPressed: () {
                        setState(() {
                          _isMenuExpanded = false;
                        });
                        widget.onMicPressed();
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
  final VoidCallback onMicPressed;

  const _ExpandingMenuButton({
    required this.isDark,
    required this.isExpanded,
    required this.onTapToggle,
    required this.onCameraPressed,
    required this.onGalleryPressed,
    required this.onMicPressed,
  });

  @override
  State<_ExpandingMenuButton> createState() => _ExpandingMenuButtonState();
}

class _ExpandingMenuButtonState extends State<_ExpandingMenuButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _heightFactor;
  late final Animation<double> _cameraAnim;
  late final Animation<double> _galleryAnim;
  late final Animation<double> _micAnim;

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
      duration: const Duration(milliseconds: 250),
    );
    _heightFactor = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _cameraAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.1, 0.6, curve: Curves.easeOut),
    );
    _galleryAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
    );
    _micAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );

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
    return AnimatedBuilder(
      animation: _heightFactor,
      builder: (context, _) {
        final height = 50.0 + _heightFactor.value * (218.0 - 50.0);

        final contentStack = Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // 1. Camera Option Button
            Positioned(
              top: 58,
              left: 0,
              right: 0,
              height: 46,
              child: _MenuOptionItem(
                icon: Icons.camera_alt_rounded,
                tooltip: 'Kamera',
                onTap: widget.onCameraPressed,
                animation: _cameraAnim,
                isDark: widget.isDark,
              ),
            ),

            // 2. Gallery Option Button
            Positioned(
              top: 114,
              left: 0,
              right: 0,
              height: 46,
              child: _MenuOptionItem(
                icon: Icons.photo_library_rounded,
                tooltip: 'Galeri',
                onTap: widget.onGalleryPressed,
                animation: _galleryAnim,
                isDark: widget.isDark,
              ),
            ),

            // 3. Microphone Option Button
            Positioned(
              top: 170,
              left: 0,
              right: 0,
              height: 46,
              child: _MenuOptionItem(
                icon: Icons.mic_rounded,
                tooltip: 'Mikrofon',
                onTap: widget.onMicPressed,
                animation: _micAnim,
                isDark: widget.isDark,
              ),
            ),

            // 4. Main Toggle Button (at the top)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 48,
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
                    child: AnimatedRotation(
                      turns: widget.isExpanded ? 0.125 : 0.0, // 45 degrees
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutBack,
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
                    ? Colors.black.withValues(alpha: 0.55)
                    : Colors.white.withValues(alpha: 0.8)),
            borderColor: _isMainPressed
                ? (widget.isDark
                    ? Colors.white.withValues(alpha: 0.25)
                    : Colors.black.withValues(alpha: 0.15))
                : (widget.isDark
                    ? Colors.white.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
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
                  width: 46,
                  height: 46,
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
  final VoidCallback? onTap;

  const _SendCircleButton({
    required this.isDark,
    required this.enabled,
    required this.t,
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

    final double stretchFactor = (4.0 * t * (1.0 - t)).clamp(0.0, 1.0);
    final double buttonWidth = 50.0 + 22.0 * stretchFactor;

    final double targetOpacity = widget.isDark ? 0.65 : 0.75;
    double bgOpacity;
    if (t < 0.25) {
      bgOpacity = (t / 0.25) * targetOpacity;
    } else {
      bgOpacity = targetOpacity;
    }

    final double borderOpacity = t < 0.85 ? 0.0 : (t - 0.85) / 0.15;

    final pressedBg = widget.isDark
        ? AppColors.getThemeSurface(context, 2).withValues(alpha: 0.75 * bgOpacity)
        : Colors.grey[200]!.withValues(alpha: 0.85 * bgOpacity);

    final iconIdle = AppColors.getTextFaint(context).withValues(alpha: 0.5);
    final iconActive = _isPressed && enabled
        ? AppColors.getPrimary(context)
        : AppColors.getTextPrimary(context).withValues(alpha: 0.85);
    final targetIconColor = enabled ? iconActive : iconIdle;
    final iconColor = Color.lerp(iconIdle, targetIconColor, t) ?? iconIdle;

    final double buttonScale = 0.85 + 0.15 * t;

    return GestureDetector(
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
      child: Transform.scale(
        scale: buttonScale * (_isPressed && enabled ? 0.94 : 1.0),
        child: SizedBox(
          width: buttonWidth,
          height: 50.0,
          child: Stack(
            children: [
              if (_isPressed && enabled && t > 0.85)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: pressedBg,
                      borderRadius: BorderRadius.circular(25.0),
                      border: Border.all(
                        color: widget.isDark
                            ? Colors.white.withValues(alpha: 0.25 * borderOpacity)
                            : Colors.black.withValues(alpha: 0.15 * borderOpacity),
                        width: 1.0,
                      ),
                    ),
                  ),
                ),
              Positioned.fill(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 1.5),
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

        final path = Path();
        final capsuleRightEdge = W - capsuleRight;
        final buttonLeftEdge = W - sendRight - buttonWidth;
        final buttonRightEdge = W - sendRight;

        if (clampedT > 0.01 && buttonLeftEdge < capsuleRightEdge) {
          // Overlapping state: draw a single combined capsule path (no inner borders)
          final combinedRRect = RRect.fromLTRBR(
            capsuleLeft,
            0.0,
            buttonRightEdge,
            H,
            const Radius.circular(25.0),
          );
          path.addRRect(combinedRRect);
        } else {
          // Separated state: draw two distinct capsule/circle paths
          final capsuleRRect = RRect.fromLTRBR(
            capsuleLeft,
            0.0,
            capsuleRightEdge.clamp(capsuleLeft, W),
            H,
            const Radius.circular(25.0),
          );
          path.addRRect(capsuleRRect);

          if (clampedT > 0.01) {
            final sendRRect = RRect.fromLTRBR(
              buttonLeftEdge,
              0.0,
              buttonRightEdge,
              H,
              const Radius.circular(25.0),
            );
            path.addRRect(sendRRect);
          }
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
