import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../dashboard/dashboard_providers.dart';
import '../../../../shared/widgets/precision_surface.dart';
import '../../../../shared/widgets/precision_animated_icon.dart';

class ThemeSetting extends ConsumerWidget {
  const ThemeSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final themeIndex = ref.watch(settingsProvider.select((s) => s.themeModeIndex));
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.themeMode,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: AppColors.getTextPrimary(context),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getThemeName(themeIndex, l10n),
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.getTextSecondary(context).withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          CelestialSwitcher(
            currentIndex: themeIndex,
            onChanged: (index) {
              HapticFeedback.mediumImpact();
              ref.read(settingsProvider.notifier).setThemeMode(index);
            },
          ),
        ],
      ),
    );
  }

  String _getThemeName(int index, AppLocalizations l10n) {
    switch (index) {
      case 0: return l10n.themeSystem;
      case 1: return l10n.themeLight;
      case 2: return l10n.themeDark;
      default: return "";
    }
  }
}

class CelestialSwitcher extends ConsumerStatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;

  const CelestialSwitcher({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  @override
  ConsumerState<CelestialSwitcher> createState() => _CelestialSwitcherState();
}

class _CelestialSwitcherState extends ConsumerState<CelestialSwitcher> with TickerProviderStateMixin {
  late AnimationController _continuousController; // Sürekli animasyon (twinkle/drift)
  late AnimationController _transitionController; // Mod geçiş animasyonu
  late List<Offset> _starPositions;
  late List<double> _starSpeeds;
  double _lastIndex = 1.0; // 0: System, 1: Light, 2: Dark

  @override
  void initState() {
    super.initState();
    _continuousController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Başlangıç değerini ayarla
    _lastIndex = widget.currentIndex.toDouble();
    _transitionController.value = _lastIndex / 2.0;

    final random = math.Random(42);
    _starPositions = List.generate(20, (index) => Offset(random.nextDouble(), random.nextDouble()));
    _starSpeeds = List.generate(20, (index) => 0.5 + random.nextDouble());
  }

  @override
  void didUpdateWidget(CelestialSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _transitionController.animateTo(
        widget.currentIndex / 2.0,
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _continuousController.dispose();
    _transitionController.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.heavyImpact();
    final nextIndex = (widget.currentIndex + 1) % 3;
    widget.onChanged(nextIndex);
  }

  @override
  Widget build(BuildContext context) {
    // Haritalama: Light(index 1)->0.0, System(index 0)->1.0, Dark(index 2)->2.0
    double getTValue(int index) {
      if (index == 1) return 0.0;
      if (index == 0) return 1.0;
      return 2.0;
    }

    final systemColor = Theme.of(context).colorScheme.primary;
    final targetT = getTValue(widget.currentIndex);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: targetT),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutQuart,
      builder: (context, tValue, child) {
        // STANDART BOYUT MATEMATİĞİ (40px Yükseklik)
        const totalWidth = 116.0;
        const totalHeight = 40.0;
        const orbBaseSize = 32.0;
        const padding = 4.0;
        const availableSpace = totalWidth - orbBaseSize - (padding * 2);

        // 🍬 SAKIZ MATEMATİĞİ (Zıplamasız Versiyon)
        // tValue'nun hedef t'ye ne kadar yakın olduğunu bularak tek bir esneme döngüsü yaratıyoruz
        final double animationProgress = (1.0 - (tValue - targetT).abs() / 1.0).clamp(0.0, 1.0);
        // tValue bir birimden fazla hareket ediyorsa (0->2 gibi), o zaman tamsayı olmayan kısmı kullan
        final double effectiveProgress = (targetT - tValue).abs() > 1.1 
            ? (1.0 - (tValue - targetT).abs() / 2.0).clamp(0.0, 1.0)
            : (1.0 - (tValue - targetT).abs()).clamp(0.0, 1.0);
            
        final stretchFactor = 1.0 + (effectiveProgress < 0.5 ? effectiveProgress : 1.0 - effectiveProgress) * 1.0;
        final currentGlowColor = widget.currentIndex == 1 
            ? Colors.orange 
            : widget.currentIndex == 2 
                ? Colors.blue.shade200 
                : systemColor;

        final leftPos = padding + ((tValue / 2.0) * availableSpace);

        return GestureDetector(
          onTap: _handleTap,
          child: Container(
            width: totalWidth,
            height: totalHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(totalHeight / 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(totalHeight / 2),
              child: Stack(
                children: [
                  // 🌊 ORGANIC ATMOSPHERE
                  AnimatedBuilder(
                    animation: _continuousController,
                    builder: (context, child) {
                      return CustomPaint(
                        size: const Size(totalWidth, totalHeight),
                        painter: OrganicSkyPainter(
                          transitionValue: tValue,
                          animationValue: _continuousController.value,
                          continuousValue: _continuousController.value,
                          starPositions: _starPositions,
                          starSpeeds: _starSpeeds,
                          systemColor: systemColor,
                        ),
                      );
                    },
                  ),
                  
                  // ☀️🌙 THE "PRECISION GUM" ORB
                  Positioned(
                    left: leftPos,
                    top: (totalHeight - orbBaseSize) / 2,
                    child: Container(
                      width: orbBaseSize * stretchFactor,
                      height: orbBaseSize,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(orbBaseSize / 2),
                      ),
                      child: CustomPaint(
                        size: Size(orbBaseSize, orbBaseSize),
                        painter: OrbIconPainter(
                          transitionValue: tValue,
                          animationValue: _continuousController.value,
                          systemColor: systemColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Alignment _getOrbAlignment(int index) {
    switch (index) {
      case 1: return Alignment.centerLeft;
      case 0: return Alignment.center;
      case 2: return Alignment.centerRight;
      default: return Alignment.center;
    }
  }
}

class OrganicSkyPainter extends CustomPainter {
  final double transitionValue; // 0: Light, 1: System, 2: Dark (YENİ)
  final double animationValue;
  final double continuousValue;
  final List<Offset> starPositions;
  final List<double> starSpeeds;
  final Color systemColor;

  OrganicSkyPainter({
    required this.transitionValue,
    required this.animationValue,
    required this.continuousValue,
    required this.starPositions,
    required this.starSpeeds,
    required this.systemColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // t: 0.0 (Aydınlık) -> 1.0 (Hibrit) -> 2.0 (Karanlık)
    final t = transitionValue;

    // 1. GÜNDÜZ DÜNYASI
    _drawLightSky(canvas, size, Offset(32, size.height / 2));
    _drawScallopedClouds(canvas, size, (1.0 - (t / 2.0)).clamp(0.0, 1.0));

    // 2. GECE DÜNYASI (Maske ile)
    canvas.saveLayer(Offset.zero & size, Paint());
    _drawDarkSky(canvas, size, Offset(size.width - 32, size.height / 2));
    _drawCleanStars(canvas, size, (t / 2.0).clamp(0.0, 1.0));

    final splitStart = 1.0 - (t * 0.6); 
    final splitEnd = 1.2 - (t * 0.6);
    final maskPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [Colors.transparent, Colors.white],
        stops: [splitStart.clamp(0.0, 1.0), splitEnd.clamp(0.0, 1.0)],
      ).createShader(Offset.zero & size);
    
    canvas.drawRect(Offset.zero & size, maskPaint..blendMode = BlendMode.dstIn);
    canvas.restore();

    // 3. 🔦 IŞIK YANSIMASI (Kutunun içine vuran yansıma - Sistem Rengi Duyarlı)
    final orbX = 4.0 + (t / 2.0) * (size.width - 32.0 - 8.0) + 16.0;
    final reflectionCenter = Offset(orbX, size.height / 2);
    
    // Renk geçişi: Turuncu -> Sistem Rengi -> Mavi
    final Color reflectionColor;
    if (t <= 1.0) {
      reflectionColor = Color.lerp(Colors.orange, systemColor, t)!;
    } else {
      reflectionColor = Color.lerp(systemColor, Colors.blue.shade200, t - 1.0)!;
    }
    
    canvas.drawCircle(
      reflectionCenter, 
      size.height * 1.5, 
      Paint()
        ..shader = RadialGradient(
          colors: [
            reflectionColor.withValues(alpha: 0.3),
            reflectionColor.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: reflectionCenter, radius: size.height * 1.5))
    );

    _drawInnerShadow(canvas, size);
  }

  void _drawSplitSky(Canvas canvas, Size size) {
    // 1. Önce tüm zemine Gündüz Gökyüzünü çiziyoruz
    _drawLightSky(canvas, size, Offset(32, size.height / 2));

    // 2. Gece Gökyüzünü yumuşak bir maske ile üzerine bindiriyoruz
    // saveLayer kullanarak şeffaflık ve yumuşak geçiş (feathering) sağlıyoruz
    final paint = Paint()..blendMode = BlendMode.dstIn;
    canvas.saveLayer(Offset.zero & size, Paint());
    
    // Gece tarafını çiz
    _drawDarkSky(canvas, size, Offset(size.width - 32, size.height / 2));

    // Maske: Soldan sağa şeffaftan opağa geçerek geceyi sağ tarafa hapsediyor ama yumuşakça
    final maskPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [Colors.transparent, Colors.white],
        stops: [0.4, 0.6], // Geçişin tam ortada ve yumuşak olmasını sağlar
      ).createShader(Offset.zero & size);
    
    canvas.drawRect(Offset.zero & size, maskPaint..blendMode = BlendMode.dstIn);
    canvas.restore();
  }

  void _drawInterpolatedSky(Canvas canvas, Size size, double start, double end, double t) {
    final startCenter = start == 0.0 ? Offset(size.width / 2, size.height / 2) : Offset(32, size.height / 2);
    final endCenter = end == 1.0 ? Offset(32, size.height / 2) : Offset(size.width - 32, size.height / 2);
    final center = Offset.lerp(startCenter, endCenter, t)!;

    for (int i = 0; i < 8; i++) {
      final color = _getTransitionColor(i, start, end, t);
      final radius = size.width * (1.2 - (i * 0.14)); 
      if (radius > 0) {
        canvas.drawCircle(center, radius, Paint()..color = color);
      }
    }
  }

  void _drawLightSky(Canvas canvas, Size size, Offset center) {
    final colors = [
      const Color(0xFF0D47A1), 
      const Color(0xFF1565C0),
      const Color(0xFF1976D2),
      const Color(0xFF1E88E5),
      const Color(0xFF2196F3),
      const Color(0xFF42A5F5),
      const Color(0xFF64B5F6),
      const Color(0xFF90CAF9), 
    ];
    for (int i = 0; i < colors.length; i++) {
      final radius = size.width * (1.2 - (i * 0.14)); 
      if (radius > 0) {
        canvas.drawCircle(center, radius, Paint()..color = colors[i]);
      }
    }
  }

  void _drawDarkSky(Canvas canvas, Size size, Offset center) {
    final colors = [
      const Color(0xFF000000), // 1. En Dış (Zifiri Karanlık)
      const Color(0xFF0A0A0A), // 2.
      const Color(0xFF121212), // 3.
      const Color(0xFF1A1A1A), // 4.
      const Color(0xFF212121), // 5.
      const Color(0xFF2C2C2C), // 6.
      const Color(0xFF373737), // 7.
      const Color(0xFF424242), // 8. En İç (Ay'ın etrafı)
    ];
    for (int i = 0; i < colors.length; i++) {
      final radius = size.width * (1.2 - (i * 0.14)); 
      if (radius > 0) {
        canvas.drawCircle(center, radius, Paint()..color = colors[i]);
      }
    }
  }

  void _drawSimpleLayeredSky(Canvas canvas, Size size, bool isLight, Offset center) {
    if (isLight) {
      _drawLightSky(canvas, size, center);
    } else {
      _drawDarkSky(canvas, size, center);
    }
  }

  void _drawInterpolatedParticles(Canvas canvas, Size size, double t) {
    double cloudOpacity = 0.0;
    double starOpacity = 0.0;

    if (t == 0.0) {
      canvas.save();
      canvas.clipRect(Rect.fromLTWH(0, 0, size.width / 2, size.height));
      _drawScallopedClouds(canvas, size, 1.0);
      canvas.restore();
      canvas.save();
      canvas.clipRect(Rect.fromLTWH(size.width / 2, 0, size.width / 2, size.height));
      _drawCleanStars(canvas, size, 1.0);
      canvas.restore();
      return;
    }

    if (t <= 1.0) {
      cloudOpacity = t;
      starOpacity = 1.0 - t;
    } else {
      cloudOpacity = 1.0 - (t - 1.0);
      starOpacity = (t - 1.0);
    }

    if (cloudOpacity > 0.01) _drawScallopedClouds(canvas, size, cloudOpacity);
    if (starOpacity > 0.01) _drawCleanStars(canvas, size, starOpacity);
  }

  void _drawScallopedClouds(Canvas canvas, Size size, double opacity) {
    // Gri yerine gökyüzüyle uyumlu, düşük opaklıklı mavi bir ton
    final backPaint = Paint()..color = const Color(0xFFBBDEFB).withValues(alpha: 0.4 * opacity);
    final frontPaint = Paint()..color = Colors.white.withValues(alpha: opacity);
    
    // 1. ARKA KATMAN (Çerçeveleyici Gri Hat)
    final backOffsets = [
      Offset(0, size.height + 5),
      Offset(45, size.height + 2),
      Offset(85, size.height - 5),
      Offset(125, size.height - 25), 
      Offset(155, size.height - 45), // Sağ Duvar
      Offset(165, size.height - 15), // Alt Köşe Desteği
      Offset(145, -5),               // Üst Köşe Dönüşü
    ];
    for (var offset in backOffsets) {
      canvas.drawCircle(offset, 28 + (offset.dx % 8), backPaint);
    }

    // 2. ÖN KATMAN (Net Beyaz Çerçeve)
    final frontOffsets = [
      Offset(-10, size.height + 10),
      Offset(40, size.height + 8),
      Offset(80, size.height + 0),
      Offset(120, size.height - 20),
      Offset(150, size.height - 40), // Sağ Duvar Tırmanışı
      Offset(160, size.height - 10), // Köşeyi Doldurma
      Offset(140, -10),              // Üst Köşeden İniş
    ];
    for (var offset in frontOffsets) {
      canvas.drawCircle(offset, 24 + (offset.dx % 6), frontPaint);
    }
  }

  void _drawCleanStars(Canvas canvas, Size size, double opacity) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.8 * opacity);
    for (int i = 0; i < starPositions.length; i++) {
      final pos = starPositions[i];
      canvas.drawCircle(Offset(pos.dx * size.width, pos.dy * size.height), 1.0, paint);
    }
  }

  void _drawInnerShadow(Canvas canvas, Size size) {
    final path = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(32)));
    canvas.drawPath(
      path, 
      Paint()
        ..color = const Color(0xFF0D47A1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
    );
    canvas.drawPath(
      path, 
      Paint()
        ..color = Colors.black.withValues(alpha: 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
    );
  }

  Color _getTransitionColor(int i, double start, double end, double t) {
    final light = [
      const Color(0xFF0D47A1), const Color(0xFF1565C0), const Color(0xFF1976D2), 
      const Color(0xFF1E88E5), const Color(0xFF2196F3), const Color(0xFF42A5F5),
      const Color(0xFF64B5F6), const Color(0xFF90CAF9)
    ];
    final dark = List.generate(8, (index) => Color.lerp(Colors.black, const Color(0xFF424242), index / 7)!);
    
    final startColors = start == 0.0 ? dark : light;
    final endColors = end == 1.0 ? light : dark;
    return Color.lerp(startColors[i], endColors[i], t)!;
  }

  @override
  bool shouldRepaint(covariant OrganicSkyPainter oldDelegate) => true;
}

class OrbIconPainter extends CustomPainter {
  final double transitionValue;
  final double animationValue;
  final Color systemColor;

  OrbIconPainter({
    required this.transitionValue, 
    required this.animationValue,
    required this.systemColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.44;

    // t: 0.0 (Güneş) -> 1.0 (Hibrit) -> 2.0 (Ay)
    final t = transitionValue;

    // 0. SİSTEM RENGİ AURASI (Hibrit modda merkezi aydınlatma)
    if (t > 0.5 && t < 1.5) {
      final systemOpacity = (1.0 - (t - 1.0).abs()).clamp(0.0, 1.0);
      canvas.drawCircle(
        center, 
        radius * 1.2, 
        Paint()
          ..shader = RadialGradient(
            colors: [
              systemColor.withValues(alpha: 0.4 * systemOpacity),
              systemColor.withValues(alpha: 0.0),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: radius * 1.2))
      );
    }

    // 1. GÜNEŞ (Zemin katman olarak her zaman çizilir veya t'ye göre solar)
    canvas.save();
    // Güneş'i t arttıkça soldan sağa gizle (t=2.0'da tamamen gizli)
    final sunClipX = size.width * (1.0 - (t / 2.0));
    canvas.clipRect(Rect.fromLTWH(0, 0, sunClipX, size.height));
    _drawSun(canvas, center, radius);
    canvas.restore();

    // 2. AY (Üst katman olarak t arttıkça sağdan sola gelir)
    canvas.save();
    // Ay'ı t arttıkça sağdan sola göster (t=0.0'da tamamen gizli, 1.0'da yarı yarıya, 2.0'da tam)
    final moonClipX = size.width * (1.0 - (t / 2.0));
    canvas.clipRect(Rect.fromLTWH(moonClipX, 0, size.width - moonClipX, size.height));
    _drawMoon(canvas, center, radius);
    canvas.restore();
  }

  void _drawSun(Canvas canvas, Offset center, double radius) {
    // 1. Keskin Alt Gölge
    canvas.drawCircle(
      center + const Offset(0, 3), 
      radius, 
      Paint()
        ..color = const Color(0xFFE65100).withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2)
    );

    // 2. Güneş Ana Gövde
    canvas.drawCircle(center, radius, Paint()..color = const Color(0xFFFFEA00));
  }

  void _drawMoon(Canvas canvas, Offset center, double radius) {
    // 1. Havada Durma Gölgesi
    canvas.drawCircle(
      center + const Offset(0, 5), 
      radius, 
      Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
    );

    // 2. Bombeli Ay Gövdesi
    final moonPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFFFFF), 
          const Color(0xFFF5F5F5),
          const Color(0xFFBDBDBD),
        ],
        center: const Alignment(-0.3, -0.3),
        radius: 0.8,
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    
    canvas.drawCircle(center, radius, moonPaint);

    // 3. Kraterler (Derinlik efekti ile)
    final craterPaint = Paint()..color = const Color(0xFF9E9E9E).withValues(alpha: 0.6);
    canvas.drawCircle(center + Offset(-radius * 0.35, -radius * 0.1), radius * 0.28, craterPaint);
    canvas.drawCircle(center + Offset(radius * 0.25, -radius * 0.4), radius * 0.15, craterPaint);
    canvas.drawCircle(center + Offset(radius * 0.35, radius * 0.2), radius * 0.18, craterPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
