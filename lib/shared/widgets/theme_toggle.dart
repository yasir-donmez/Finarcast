import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/theme/app_constants.dart';
import '../../l10n/app_localizations.dart';

// Global key for screenshot boundary
// Global key is imported from settings_provider

class ThemeToggle extends ConsumerStatefulWidget {
  final Color activeColor;
  const ThemeToggle({super.key, required this.activeColor});

  @override
  ConsumerState<ThemeToggle> createState() => _PrecisionThemeToggleState();
}

class _PrecisionThemeToggleState extends ConsumerState<ThemeToggle> with TickerProviderStateMixin {
  late AnimationController _revealController;
  late AnimationController _iconController;
  OverlayEntry? _overlayEntry;
  ui.Image? _screenshot;
  final GlobalKey _buttonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    _revealController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _screenshot?.dispose();
    _screenshot = null;
  }

  Future<void> _captureSnapshot(BuildContext context) async {
    try {
      final boundary = rootRepaintBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      
      // Performans için 1.5x pixel ratio (3x yerine) kullanıyoruz. 
      // Geçiş anında fark edilmez ama işlemciyi çok rahatlatır.
      _screenshot = await boundary.toImage(pixelRatio: 1.5);
    } catch (e) {
      debugPrint('ThemeReveal screenshot error: $e');
      _screenshot = null;
    }
  }

  void _handleToggle() async {
    if (_revealController.isAnimating) return;
    if (!mounted) return;

    final settings = ref.read(settingsProvider);
    // Mod döngüsü: Sistem (0) -> Açık (1) -> Koyu (2) -> Sistem (0)
    final nextMode = (settings.themeModeIndex + 1) % 3;

    // 1. Ekran görüntüsünü al
    await _captureSnapshot(context);
    if (_screenshot == null || !mounted) return;

    // 2. Buton konumunu bul (açılma merkezini belirlemek için)
    final RenderBox? renderBox = _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final center = renderBox.localToGlobal(renderBox.size.center(Offset.zero));

    // 3. İkon animasyonunu başlat
    _iconController.forward(from: 0.0);
    HapticFeedback.mediumImpact();

    // 4. Temayı değiştir
    await ref.read(settingsProvider.notifier).setThemeMode(nextMode);

    // 5. Overlay'i ekle
    if (!mounted) return;
    _overlayEntry = OverlayEntry(
      builder: (context) => _RevealOverlay(
        center: center,
        animation: _revealController,
        image: _screenshot!,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    // 6. Reveal animasyonunu başlat
    await _revealController.forward(from: 0.0);
    
    _removeOverlay();
    _revealController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeIndex = ref.watch(settingsProvider.select((s) => s.themeModeIndex));
    
    String label;
    IconData icon;
    switch (themeIndex) {
      case 1:
        label = l10n.themeLight;
        icon = Icons.light_mode_rounded;
        break;
      case 2:
        label = l10n.themeDark;
        icon = Icons.dark_mode_rounded;
        break;
      default:
        label = l10n.themeSystem;
        icon = Icons.brightness_auto_rounded;
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.themeMode,
                  style: TextStyle(
                    color: AppColors.getTextPrimary(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.getTextSecondary(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            key: _buttonKey,
            onTap: _handleToggle,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: widget.activeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.activeColor.withValues(alpha: 0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.activeColor.withValues(alpha: 0.05),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: RotationTransition(
                turns: _iconController,
                child: Icon(
                  icon,
                  color: widget.activeColor,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RevealOverlay extends StatelessWidget {
  final Offset center;
  final Animation<double> animation;
  final ui.Image image;

  const _RevealOverlay({
    required this.center,
    required this.animation,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    // Daha yumuşak bir kavis ekliyoruz
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOutQuart,
    );

    return AnimatedBuilder(
      animation: curvedAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _InverseCircularRevealPainter(
            center: center,
            fraction: curvedAnimation.value,
            image: image,
          ),
        );
      },
    );
  }
}

class _InverseCircularRevealPainter extends CustomPainter {
  final Offset center;
  final double fraction;
  final ui.Image image;

  _InverseCircularRevealPainter({
    required this.center,
    required this.fraction,
    required this.image,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (fraction >= 1.0) return; // Animasyon bittiyse çizim yapma

    final maxRadius = _calcMaxRadius(center, size);
    final radius = maxRadius * fraction;

    // Performans için sadece ekranın görünen kısmına katman açıyoruz
    canvas.saveLayer(Offset.zero & size, Paint());

    paintImage(
      canvas: canvas,
      rect: Offset.zero & size,
      image: image,
      fit: BoxFit.fill,
      filterQuality: FilterQuality.low, // Geçiş anında performans için düşük kalite yeterli
    );

    final erasePaint = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius, erasePaint);

    canvas.restore();
  }

  double _calcMaxRadius(Offset center, Size size) {
    final w = math.max(center.dx, size.width - center.dx);
    final h = math.max(center.dy, size.height - center.dy);
    return math.sqrt(w * w + h * h);
  }

  @override
  bool shouldRepaint(covariant _InverseCircularRevealPainter oldDelegate) =>
      oldDelegate.fraction != fraction;
}
