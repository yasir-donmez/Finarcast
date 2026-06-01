import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../home/home_providers.dart';
import '../settings_list_items.dart';

class ThemeSetting extends ConsumerWidget {
  const ThemeSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final themeIndex = ref.watch(settingsProvider.select((s) => s.themeModeIndex));
    final activeColor = SettingsListItems.getSettingColor(context, SettingType.theme, ref.watch(rotaryColorProvider));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: activeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.brightness_6_outlined, size: 22, color: activeColor),
          ),
          const SizedBox(width: 16),
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
                const SizedBox(height: 2),
                Text(
                  _getThemeName(themeIndex, l10n),
                  style: TextStyle(
                    color: AppColors.getTextSecondary(context).withValues(alpha: 0.5),
                    fontSize: 12,
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

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  CelestialSwitcher
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

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

class _CelestialSwitcherState extends ConsumerState<CelestialSwitcher>
    with TickerProviderStateMixin {
  late AnimationController _loopCtrl;

  @override
  void initState() {
    super.initState();
    _loopCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _loopCtrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.heavyImpact();
    widget.onChanged((widget.currentIndex + 1) % 3);
  }

  @override
  Widget build(BuildContext context) {
    // Haritalama: Light(1)→0.0, System(0)→1.0, Dark(2)→2.0
    double getTValue(int i) => i == 1 ? 0.0 : (i == 0 ? 1.0 : 2.0);

    final sysColor = Theme.of(context).colorScheme.primary;
    final targetT = getTValue(widget.currentIndex);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: targetT),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutQuart,
      builder: (context, tVal, _) {
        // ── Boyutlar ──
        const W = 116.0;
        const H = 40.0;
        const orbSize = 36.0;
        const pad = 2.0;
        const travel = W - orbSize - pad * 2;
        const borderW = 2.5;

        // Sakız esnemesi
        final eff = (targetT - tVal).abs() > 1.1
            ? (1.0 - (tVal - targetT).abs() / 2.0).clamp(0.0, 1.0)
            : (1.0 - (tVal - targetT).abs()).clamp(0.0, 1.0);
        final stretch = 1.0 + (eff < 0.5 ? eff : 1.0 - eff);
        final leftPos = pad + (tVal / 2.0) * travel;

        // Kenarlık rengi: Aydınlık → beyaz, Karanlık → koyu gri
        final borderColor = Color.lerp(
          Colors.white,
          const Color(0xFF2D323E),
          (tVal / 2).clamp(0.0, 1.0),
        )!;

        final outlineColor = Color.lerp(
          const Color(0xFFD0D0D0),
          const Color(0xFF1E222B),
          (tVal / 2).clamp(0.0, 1.0),
        )!;

        return GestureDetector(
          onTap: _handleTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular((H + borderW * 2) / 2),
              color: borderColor,
              border: Border.all(
                color: outlineColor,
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 1.5),
                ),
              ],
            ),
            padding: const EdgeInsets.all(borderW),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(H / 2),
              child: SizedBox(
                width: W,
                height: H,
                child: Stack(
                  children: [
                    // Gökyüzü
                    AnimatedBuilder(
                      animation: _loopCtrl,
                      builder: (_, __) => CustomPaint(
                        size: const Size(W, H),
                        painter: _SkyPainter(
                          t: tVal,
                          anim: _loopCtrl.value,
                          sysColor: sysColor,
                        ),
                      ),
                    ),
                    // Güneş / Ay
                    Positioned(
                      left: leftPos,
                      top: (H - orbSize) / 2,
                      child: SizedBox(
                        width: orbSize * stretch,
                        height: orbSize,
                        child: CustomPaint(
                          size: const Size(orbSize, orbSize),
                          painter: _OrbPainter(
                            t: tVal,
                            anim: _loopCtrl.value,
                            sysColor: sysColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SkyPainter extends CustomPainter {
  final double t;    // 0=Light  1=System  2=Dark
  final double anim; // 0..1 döngüsel
  final Color sysColor;

  _SkyPainter({required this.t, required this.anim, required this.sysColor});

  @override
  void paint(Canvas canvas, Size size) {
    // Dinamik Merkez Noktaları:
    // Aydınlık gökyüzü güneşin konumunu takip eder (t=0 iken solda 20, t=1 iken ortada 58).
    final double daySkyCenterX = 20.0 + t.clamp(0.0, 1.0) * 38.0;
    final Offset daySkyCenter = Offset(daySkyCenterX, size.height / 2);

    // Karanlık gökyüzü ayın konumunu takip eder (t=1 iken ortada 58, t=2 iken sağda 96).
    final double nightSkyCenterX = 58.0 + (t - 1.0).clamp(0.0, 1.0) * 38.0;
    final Offset nightSkyCenter = Offset(nightSkyCenterX, size.height / 2);

    if (t == 0.0) {
      // Aydınlık Mod (Statik çizim - SaveLayer performansı koruma)
      _daySky(canvas, size, daySkyCenter);
      _clouds(canvas, size, 1.0);
    } else if (t == 2.0) {
      // Karanlık Mod (Statik çizim)
      _nightSky(canvas, size, nightSkyCenter);
      _stars(canvas, size, 1.0);
    } else {
      // Geçiş Durumu (Sistem modu t=1.0 dahil)
      // 1. Zemin Katmanı (Day Sky)
      _daySky(canvas, size, daySkyCenter);

      // 2. Üst Gece Katmanı (Maske ile soldan sağa kayarak bindirilir)
      canvas.saveLayer(Offset.zero & size, Paint());
      _nightSky(canvas, size, nightSkyCenter);

      // Maskeyi uyguluyoruz (t=1.0 iken tam ortadan böler)
      final s0 = (0.45 - (t - 1.0) * 0.5).clamp(0.0, 1.0);
      final s1 = (0.55 - (t - 1.0) * 0.5).clamp(0.0, 1.0);
      canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: const [Colors.transparent, Colors.white],
            stops: [s0, s1],
          ).createShader(Offset.zero & size)
          ..blendMode = BlendMode.dstIn,
      );
      canvas.restore();

      // 3. Bulutlar (Tüm genişliğe yayılır, unmasked!)
      final cloudOpacity = (2.0 - t).clamp(0.0, 1.0);
      _clouds(canvas, size, cloudOpacity);

      // 4. Yıldızlar (Tüm genişliğe yayılır, unmasked!)
      final starsOpacity = t.clamp(0.0, 1.0);
      _stars(canvas, size, starsOpacity);
    }

    // ── 5. Orb ışık yansıması ──
    final orbX = 2.0 + (t / 2.0) * (size.width - 36 - 4) + 18;
    final gc = Offset(orbX, size.height / 2);
    final Color gCol = t <= 1.0
        ? Color.lerp(Colors.orange, sysColor, t)!
        : Color.lerp(sysColor, Colors.blue.shade200, t - 1.0)!;
    canvas.drawCircle(
      gc,
      size.height * 1.2,
      Paint()
        ..shader = RadialGradient(
          colors: [gCol.withValues(alpha: 0.2), gCol.withValues(alpha: 0.0)],
        ).createShader(Rect.fromCircle(center: gc, radius: size.height * 1.2)),
    );

    // ── 6. İç Kenarlık Gölgesi (Recessed bevel effect - Gömülü hissi için) ──
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(size.height / 2));

    canvas.save();
    canvas.clipRRect(rrect);

    // Gömülü hissi için sol-üstten gelen belirgin iç gölge (inner shadow)
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);

    // Delik hafif sağa-aşağı kaydırıldığında, sol-üstte daha kalın bir gölge oluşur
    final shadowPath = Path()
      ..addRect(rect.inflate(30.0))
      ..addRRect(rrect.shift(const Offset(1.0, 1.5)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(shadowPath, shadowPaint);
    canvas.restore();

    // İnce, keskin iç kontur çizgisi
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  // ────── Bulutlar ──────
  void _clouds(Canvas canvas, Size size, double opacity) {
    if (opacity <= 0) return;
    final front = Paint()..color = Colors.white.withValues(alpha: opacity);

    // Gündüz modu (Aydınlık) bulut pozisyonları (Sağ dikey duvarı sarar)
    final dayCenters = [
      const Offset(42, 43),  // C1
      const Offset(60, 39),  // C2
      const Offset(78, 40),  // C3
      const Offset(98, 32),  // C4
      const Offset(112, 18), // C5
      const Offset(104, 6),  // C6
      const Offset(88, 4),   // C7
    ];

    // Sistem/Hibrit modu bulut pozisyonları (Tamamen asimetrik ve düzensiz, sol ve sağ yarısı çok farklı)
    final hybridCenters = [
      const Offset(8, 43),   // H1 (Sol uç - orta yükseklik)
      const Offset(22, 38),  // H2 (Sol taraf - oldukça iri ve yüksek)
      const Offset(38, 42),  // H3 (Sol-orta - alçak ve küçük)
      const Offset(53, 40),  // H4 (Tam orta split - dengeli)
      const Offset(69, 44),  // H5 (Sağ-orta - çok alçak ve ufak)
      const Offset(84, 39),  // H6 (Sağ taraf - devasa ve yayvan)
      const Offset(102, 42), // H7 (Sağ uç - orta derinlik)
    ];

    // Bulut boyutları (Day ve Hybrid için lerp edilerek düzensiz, irili ufaklı büyüklükler elde edilir)
    final dayRadii = [10.0, 13.0, 12.0, 14.0, 13.0, 11.0, 9.0];
    final hybridRadii = [10.0, 14.0, 8.5, 12.0, 7.5, 15.0, 9.0];

    // Gündüz modu bulutlarının kendi dış kenarına doğru yaslanma vektörleri
    final whiteOffsets = [
      const Offset(3.2, 2.6),   // C1
      const Offset(2.5, 3.2),   // C2
      const Offset(1.5, 3.5),   // C3
      const Offset(3.2, 2.6),   // C4
      const Offset(3.8, 0.0),   // C5
      const Offset(3.0, -3.2),  // C6
      const Offset(1.8, -3.5),  // C7
    ];

    final hybridWhiteOffsets = [
      const Offset(-2.0, 2.0),
      const Offset(-1.5, 2.5),
      const Offset(-1.0, 2.8),
      const Offset(-0.5, 2.5),
      const Offset(0.0, 2.0),
      const Offset(0.5, 1.5),
      const Offset(1.0, 1.0),
    ];

    // factor = 0.0 (Aydınlık modu, sağ kenarda), 1.0 (Hibrit modu, tüm alt kenarda)
    final factor = t.clamp(0.0, 1.0);

    // Dinamik geçiş koordinatları
    final dynamicCenters = List<Offset>.generate(dayCenters.length, (i) {
      return Offset.lerp(dayCenters[i], hybridCenters[i], factor)!;
    });

    final dynamicWhiteOffsets = List<Offset>.generate(whiteOffsets.length, (i) {
      return Offset.lerp(whiteOffsets[i], hybridWhiteOffsets[i], factor)!;
    });

    // Gölgelerin kaydırma vektörü
    final shadowOffset = Offset(-1.5 * (1.0 - 2.0 * factor), -1.0);

    // Gökyüzü aydınlık/karanlık sınır çizgisi (Aydınlık modda splitX = size.width olur, yani hepsi aydınlık bulut olur)
    final splitX = size.width * (1.0 - t / 2.0).clamp(0.0, 1.0);

    // 1. ADIM: Tüm derin şeffaf arka bulutları (gölgeleri) çiziyoruz.
    for (int i = 0; i < dynamicCenters.length; i++) {
      final r = dayRadii[i] + factor * (hybridRadii[i] - dayRadii[i]);
      final isDayCloud = dynamicCenters[i].dx <= splitX;

      // Sol (Gündüz) ile Sağ (Gece) tarafları için gölgelerin ton farkı
      final backPaint = Paint()
        ..color = (isDayCloud 
            ? const Color(0xFF90CAF9) // Gündüz açık mavi yumuşak gölgesi
            : const Color(0xFF232B3C) // Gece koyu lacivert gizemli gölgesi
          ).withValues(alpha: 0.35 * opacity);

      canvas.drawCircle(
        dynamicCenters[i] + shadowOffset,
        r + 2.0,
        backPaint,
      );
    }

    // 2. ADIM: Ön beyaz bulutlar (Alt katmanda kalır)
    for (int i = 0; i < dynamicCenters.length; i++) {
      final r = dayRadii[i] + factor * (hybridRadii[i] - dayRadii[i]);
      canvas.drawCircle(
        dynamicCenters[i] + dynamicWhiteOffsets[i] * 0.65,
        r,
        front,
      );
    }

    // 3. ADIM: Üst katman şeffaf bulutlar (Beyaz bulutların her zaman önünde durur, derinlik ve yumuşak sis efekti verir!)
    for (int i = 0; i < dynamicCenters.length; i++) {
      final r = dayRadii[i] + factor * (hybridRadii[i] - dayRadii[i]);
      final isDayCloud = dynamicCenters[i].dx <= splitX;

      // Sol (Gündüz) ile Sağ (Gece) tarafları için şeffaf sislerin ton farkı
      final midPaint = Paint()
        ..color = (isDayCloud 
            ? const Color(0xFFBBDEFB) // Gündüz soft tatlı açık mavi sisi
            : const Color(0xFF4E5D78) // Gece gizemli bulut lacivert/gri sisi
          ).withValues(alpha: 0.55 * opacity);

      canvas.drawCircle(
        dynamicCenters[i] + dynamicWhiteOffsets[i],
        r + 0.8,
        midPaint,
      );
    }
  }

  // ────── Yıldızlar (dört kollu sparkle) ──────
  void _stars(Canvas canvas, Size size, double opacity) {
    if (opacity <= 0) return;
    final p = Paint()..color = Colors.white.withValues(alpha: 0.9 * opacity);

    // factor = 0.0 (t=2.0, Dark Mode), 1.0 (t=1.0, System Mode)
    final double factor = (2.0 - t).clamp(0.0, 1.0);

    void drawStar(Offset c, double hybridX, double hybridY, double s) {
      // t=1.0 (System) iken x = hybridX, y = hybridY olur.
      // t=2.0 (Dark) iken x = c.dx, y = c.dy olur (orijinal koyu tema).
      final x = c.dx + factor * (hybridX - c.dx);
      final y = c.dy + factor * (hybridY - c.dy);
      final dynamicCenter = Offset(x, y);
      _sparkle(canvas, dynamicCenter, s, p);
    }

    void drawDot(Offset c, double hybridX, double hybridY, double r) {
      final x = c.dx + factor * (hybridX - c.dx);
      final y = c.dy + factor * (hybridY - c.dy);
      final dynamicCenter = Offset(x, y);
      canvas.drawCircle(dynamicCenter, r, p);
    }

    // Büyük / orta sparkle yıldızları (Gece modunda soldadır, sistem modunda tüm üst kenara yayılır ve yukarı çekilir)
    drawStar(Offset(size.width * 0.10, size.height * 0.30), 8, size.height * 0.15, 3.0);
    drawStar(Offset(size.width * 0.16, size.height * 0.70), 22, size.height * 0.22, 2.0);
    drawStar(Offset(size.width * 0.24, size.height * 0.35), 36, size.height * 0.10, 4.5);
    drawStar(Offset(size.width * 0.32, size.height * 0.72), 50, size.height * 0.28, 2.5);
    drawStar(Offset(size.width * 0.38, size.height * 0.25), 65, size.height * 0.12, 4.0);
    drawStar(Offset(size.width * 0.46, size.height * 0.55), 79, size.height * 0.25, 5.0);
    drawStar(Offset(size.width * 0.52, size.height * 0.30), 93, size.height * 0.15, 3.0);
    drawStar(Offset(size.width * 0.58, size.height * 0.65), 108, size.height * 0.22, 2.0);

    // Ufak yuvarlak yıldızlar
    drawDot(Offset(size.width * 0.08, size.height * 0.50), 15, size.height * 0.28, 0.8);
    drawDot(Offset(size.width * 0.20, size.height * 0.15), 29, size.height * 0.12, 0.7);
    drawDot(Offset(size.width * 0.30, size.height * 0.50), 58, size.height * 0.15, 0.8);
    drawDot(Offset(size.width * 0.42, size.height * 0.82), 72, size.height * 0.28, 0.7);
    drawDot(Offset(size.width * 0.55, size.height * 0.18), 101, size.height * 0.12, 0.8);
  }

  void _sparkle(Canvas canvas, Offset c, double s, Paint paint) {
    final tw = 0.7 + 0.3 * math.sin(anim * math.pi * 24 + c.dx * 6);
    final r = s * tw;
    canvas.drawPath(
      Path()
        ..moveTo(c.dx, c.dy - r)
        ..quadraticBezierTo(c.dx, c.dy, c.dx + r, c.dy)
        ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r)
        ..quadraticBezierTo(c.dx, c.dy, c.dx - r, c.dy)
        ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r),
      paint,
    );
  }

  // ────── Gündüz gökyüzü gradyanı (Açıktan Koyuya) ──────
  void _daySky(Canvas canvas, Size size, Offset center) {
    final ringColors = [
      const Color(0xFF1565C0), // R8 (en dış - en koyu)
      const Color(0xFF1976D2), // R7
      const Color(0xFF1E88E5), // R6
      const Color(0xFF2196F3), // R5
      const Color(0xFF42A5F5), // R4
      const Color(0xFF64B5F6), // R3
      const Color(0xFF90CAF9), // R2
      const Color(0xFFBBDEFB), // R1 (en iç - en açık/güneş etrafı)
    ];
    final ringRadii = [148.0, 130.0, 112.0, 94.0, 76.0, 58.0, 40.0, 22.0];

    for (int i = 0; i < ringColors.length; i++) {
      canvas.drawCircle(
        center,
        ringRadii[i],
        Paint()
          ..color = ringColors[i]
          ..style = PaintingStyle.fill,
      );
    }
  }

  // ────── Gece gökyüzü gradyanı ──────
  void _nightSky(Canvas canvas, Size size, Offset center) {
    const colors = [
      Color(0xFF1A1E28),
      Color(0xFF222732),
      Color(0xFF2A303C),
      Color(0xFF333A47),
      Color(0xFF3C4452),
      Color(0xFF454E5E),
      Color(0xFF4F596A),
      Color(0xFF596477),
    ];
    for (int i = 0; i < colors.length; i++) {
      final r = size.width * (1.3 - i * 0.15);
      if (r > 0) canvas.drawCircle(center, r, Paint()..color = colors[i]);
    }
  }

  @override
  bool shouldRepaint(covariant _SkyPainter old) => true;
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  Güneş / Ay
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _OrbPainter extends CustomPainter {
  final double t;
  final double anim;
  final Color sysColor;

  _OrbPainter({required this.t, required this.anim, required this.sysColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.height * 0.47;

    // Sistem aurası
    if (t > 0.5 && t < 1.5) {
      final op = (1.0 - (t - 1.0).abs()).clamp(0.0, 1.0);
      canvas.drawCircle(
        center,
        radius * 1.2,
        Paint()
          ..shader = RadialGradient(
            colors: [
              sysColor.withValues(alpha: 0.4 * op),
              sysColor.withValues(alpha: 0.0),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: radius * 1.2)),
      );
    }

    // Sınır çizgisi
    final mx = size.width * (1.0 - t / 2.0).clamp(0.0, 1.0);

    // Güneş (soldan kırpılır - sol yarıyı oluşturur)
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, mx, size.height));
    _sun(canvas, center, radius);
    canvas.restore();

    // Ay (sağdan kırpılır - sağ yarıyı oluşturur)
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(mx, 0, size.width - mx, size.height));
    _moon(canvas, center, radius);
    canvas.restore();
  }

  void _sun(Canvas canvas, Offset c, double r) {
    // 1. Havada süzülme hissi için derin ve yumuşak gölge (Drop Shadow)
    canvas.drawCircle(
      c + const Offset(2.0, 3.5),
      r,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0),
    );

    // 2. Gradyan gövde (Daha parlak, 3D küre etkisi ve sıcak ışık tonları)
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: const [
            Color(0xFFFFFFFF), // Merkezde beyaz parlama
            Color(0xFFFFF176), // Açık sarı
            Color(0xFFFFD54F), // Canlı altın sarısı
            Color(0xFFFF8F00), // Kenarlarda sıcak turuncu-sarı geçişi
          ],
          center: const Alignment(-0.35, -0.35),
          radius: 0.95,
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
  }

  void _moon(Canvas canvas, Offset c, double r) {
    // 1. Havada süzülme hissi için derin ve yumuşak gölge (Drop Shadow)
    canvas.drawCircle(
      c + const Offset(2.0, 3.5),
      r,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.32)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0),
    );

    // 2. Gradyan gövde (3D Küre Etkisi)
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: const [
            Color(0xFFFFFFFF), // Merkezde parlak yansıma
            Color(0xFFECEFF1), // Açık gümüş gri
            Color(0xFFCFD8DC), // Orta krater grisi
            Color(0xFF90A4AE), // Kenarlarda koyu gümüş gölge
          ],
          center: const Alignment(-0.35, -0.35),
          radius: 0.95,
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );

    // 4. Kraterler (Daha yumuşak ve gömülü entegre görünüm)
    final cp = Paint()..color = const Color(0xFF78909C).withValues(alpha: 0.35);
    canvas.drawCircle(c + Offset(-r * 0.35, -r * 0.1), r * 0.26, cp);
    canvas.drawCircle(c + Offset(r * 0.25, -r * 0.4), r * 0.14, cp);
    canvas.drawCircle(c + Offset(r * 0.35, r * 0.2), r * 0.17, cp);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}
