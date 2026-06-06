import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_constants.dart';
import '../home_providers.dart';
import '../../../l10n/app_localizations.dart';

/// Finarcast'in "Zaman Makinesi" vizyonu olan Rotary Dial (Fiziksel Kadran)
/// Progressive Time Scale (Giderek Hızlanan Zaman) mekanizması ile birleşti.
class RotaryTimeDial extends ConsumerStatefulWidget {
  const RotaryTimeDial({super.key});

  @override
  ConsumerState<RotaryTimeDial> createState() => _RotaryTimeDialState();
}

class _RotaryTimeDialState extends ConsumerState<RotaryTimeDial> with SingleTickerProviderStateMixin {
  late AnimationController _resetController;
  Animation<double>? _resetAnimation;
  double _currentAngle = 0.0;
  double _lastAngle = 0.0;
  int _lastHapticLevel = 0;

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _resetController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details, Size widgetSize) {
    if (_resetController.isAnimating) _resetController.stop();
    HapticFeedback.lightImpact();
    final center = Offset(widgetSize.width / 2, widgetSize.height / 2);
    _lastAngle = atan2(
      details.localPosition.dy - center.dy,
      details.localPosition.dx - center.dx,
    );
  }

  void _onPanUpdate(DragUpdateDetails details, Size widgetSize) {
    final center = Offset(widgetSize.width / 2, widgetSize.height / 2);
    final touchPosition = details.localPosition;

    final angle = atan2(
      touchPosition.dy - center.dy,
      touchPosition.dx - center.dx,
    );

    setState(() {
      var delta = angle - _lastAngle;
      if (delta > pi) {
        delta -= 2 * pi;
      } else if (delta < -pi) {
        delta += 2 * pi;
      }

      _lastAngle = angle;
      _currentAngle += delta;
      if (_currentAngle < 0) _currentAngle = 0;

      // Haptics synchronized with 84 visual ticks
      int currentTick = (_currentAngle / (2 * pi / 84)).floor();
      if (currentTick != _lastHapticLevel) {
        _lastHapticLevel = currentTick;
        
        // Periyot Geçişine (Major) göre Titreşim Etkisi
        double turns = _currentAngle / (2 * pi);
        double w12 = (turns <= 0.9) ? 1.0 : (turns >= 1.1 ? 0.0 : (1.1 - turns) / 0.2);
        double w21 = (turns > 0.9 && turns < 1.1) ? (turns - 0.9) / 0.2 : (turns >= 1.1 && turns <= 1.9 ? 1.0 : (turns > 1.9 && turns < 2.1 ? (2.1 - turns) / 0.2 : 0.0));
        double w3 = (turns <= 1.9) ? 0.0 : (turns >= 2.1 ? 1.0 : (turns - 1.9) / 0.2);
        
        int tickInTurn = currentTick % 84;
        double majorWeight = 0.0;
        if (tickInTurn % 12 == 0) majorWeight += w12;
        if (tickInTurn % 21 == 0) majorWeight += w21;
        if (tickInTurn % 7 == 0) majorWeight += w3;

        if (majorWeight > 0.5) {
          HapticFeedback.mediumImpact();
        } else {
          HapticFeedback.selectionClick();
        }

        // --- GERÇEKÇİ SİMÜLASYON HESAPLAMASI ---
        // 1. Önce kadranın gösterdiği "Gelecekteki Gün" sayısını hesaplıyoruz
        final double simulatedDays = _calculateSimulatedDays(_currentAngle);
        
        // 2. Kullanıcının cüzdan hızını (Daily Velocity) alıyoruz
        final double dailyVelocity = ref.read(dailyVelocityProvider);
        
        // 3. Bonus = Gün * Hız (Artık kafasına göre değil, verilere göre artıyor)
        ref.read(simulationBonusProvider.notifier).state = simulatedDays * dailyVelocity;
      }
    });
  }

  double _calculateSimulatedDays(double currentAngle) {
    if (currentAngle <= 0.01) return 0;
    double turns = currentAngle / (2 * pi);
    
    if (turns <= 1.0) {
      // 0-1 Tur: 0-7 Gün
      return turns * 7;
    } else if (turns <= 2.0) {
      // 1-2 Tur: 1-4 Hafta (7-28 Gün)
      return 7 + (turns - 1.0) * 21;
    } else if (turns <= 3.0) {
      // 2-3 Tur: 1-12 Ay (28-365 Gün)
      return 28 + (turns - 2.0) * (365 - 28);
    } else {
      // 3+ Tur: Yıllar (Her tur +1 yıl)
      return 365 + (turns - 3.0) * 365;
    }
  }

  Color _getFixedColor() {
    return AppColors.getPrimary(context);
  }

  String _getTimeLabel(double currentAngle, AppLocalizations l10n) {
    if (currentAngle <= 0.01) return l10n.today;
    double turns = currentAngle / (2 * pi);
    if (turns <= 1.0) {
      int days = (turns * 7).round();
      return days == 0 ? l10n.today : l10n.daysCount(days);
    } else if (turns <= 2.0) {
      int weeks = 1 + ((turns - 1.0) * 3).round();
      return weeks >= 4 ? l10n.oneMonth : l10n.weeksCount(weeks);
    } else if (turns <= 3.0) {
      int months = 1 + ((turns - 2.0) * 11).round();
      return months >= 12 ? l10n.oneYear : l10n.monthsCount(months);
    } else {
      int years = 1 + ((turns - 3.0) * 9).round();
      return l10n.yearsCount(years);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final timeLabel = _getTimeLabel(_currentAngle, l10n);
    final activeColor = _getFixedColor();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
            final Set<Key> seenKeys = {};
            if (currentChild?.key != null) seenKeys.add(currentChild!.key!);
            return Stack(
              alignment: Alignment.center,
              children: <Widget>[
                ...previousChildren.where((child) => child.key == null || seenKeys.add(child.key!)),
                if (currentChild != null) currentChild,
              ],
            );
          },
          child: Text(
            timeLabel,
            key: ValueKey(timeLabel),
            style: TextStyle(
              color: activeColor.withValues(alpha: 0.9),
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 5), // Mesafe ~2/3 oranında azaltıldı (8 -> 5)
        LayoutBuilder(
          builder: (context, constraints) {
            const size = 220.0;
            final knobSize = size * 0.68;

            return GestureDetector(
              onPanUpdate: (details) => _onPanUpdate(details, Size(size, size)),
              onPanStart: (details) => _onPanStart(details, Size(size, size)),
              onDoubleTap: () {
                HapticFeedback.heavyImpact();
                _resetAnimation = Tween<double>(
                  begin: _currentAngle,
                  end: 0.0,
                ).animate(CurvedAnimation(
                  parent: _resetController,
                  curve: Curves.easeOutExpo,
                ))
                  ..addListener(() {
                    setState(() {
                      _currentAngle = _resetAnimation!.value.clamp(0.0, double.infinity);
                      _lastAngle = 0.0;
                      _lastHapticLevel = 0;
                      
                      final double simulatedDays = _calculateSimulatedDays(_currentAngle);
                      final double dailyVelocity = ref.read(dailyVelocityProvider);
                      ref.read(simulationBonusProvider.notifier).state = simulatedDays * dailyVelocity;
                    });
                  });
                
                _resetController.forward(from: 0.0);
              },
              child: SizedBox(
                width: size,
                height: size,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Çukur Çentikler (Anlamlı 84 Adet)
                    RepaintBoundary(
                      child: CustomPaint(
                        size: Size(size, size),
                        painter: _DialTicksPainter(
                          currentAngle: _currentAngle,
                          tickCount: 84,
                          activeColor: activeColor,
                          isDark: Theme.of(context).brightness == Brightness.dark,
                        ),
                      ),
                    ),

                    // 1. STATİK GÖLGE VE DERİNLİK KATMANI (Fixed Shadow)
                    Container(
                      width: knobSize,
                      height: knobSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.6),
                            offset: const Offset(6, 6), // Daha sıkı ve gerçekçi gölge
                            blurRadius: 15,
                            spreadRadius: 1,
                          ),
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.05),
                            offset: const Offset(-3, -3),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // 2. DÖNEN FİZİKSEL BUTON GÖVDESİ (Rotating Body)
                          Transform.rotate(
                            angle: _currentAngle - pi / 2,
                            child: Container(
                              width: knobSize,
                              height: knobSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.getSurface(context),
                                gradient: SweepGradient(
                                  colors: [
                                    AppColors.getSurface(context),
                                    AppColors.getSurface(context).withValues(alpha: 0.7),
                                    AppColors.getSurface(context),
                                  ],
                                  stops: const [0.0, 0.5, 1.0],
                                ),
                              ),
                              child: Stack(
                                children: [
                                  // Gösterge Oyuğu (Butona bağlı döner)
                                  Align(
                                    alignment: const Alignment(0.72, 0.0),
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.black.withValues(alpha: 0.4),
                                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                                      ),
                                      child: Center(
                                        child: Container(
                                          width: 4,
                                          height: 4,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: activeColor.withValues(alpha: 0.6),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // 3. STATİK ÜST IŞIKLANDIRMA (Static Environment Highlight)
                          IgnorePointer(
                            child: Container(
                              width: knobSize,
                              height: knobSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  center: const Alignment(-0.5, -0.5),
                                  radius: 1.0,
                                  colors: [
                                    Colors.white.withValues(alpha: 0.08),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: SweepGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.white.withValues(alpha: 0.03),
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.05),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _DialTicksPainter extends CustomPainter {
  final double currentAngle;
  final int tickCount;
  final Color activeColor;
  final bool isDark;

  _DialTicksPainter({
    required this.currentAngle,
    required this.tickCount,
    required this.activeColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final Paint paint = Paint()..strokeCap = StrokeCap.round;

    double turns = currentAngle / (2 * pi);
    double pointerAngle = currentAngle % (2 * pi);

    // Zaman ölçeğine göre hafif büyüme çarpanı
    double timeScale = 1.0 + (turns * 0.3).clamp(0.0, 1.5); 

    // ORGANİK GEÇİŞ: Periyotlar arası (Gün, Hafta, Ay) ana çubuk geçişlerini yumuşat
    double weight12 = (turns <= 0.9) ? 1.0 : (turns >= 1.1 ? 0.0 : (1.1 - turns) / 0.2);
    double weight21 = (turns > 0.9 && turns < 1.1) ? (turns - 0.9) / 0.2 : (turns >= 1.1 && turns <= 1.9 ? 1.0 : (turns > 1.9 && turns < 2.1 ? (2.1 - turns) / 0.2 : 0.0));
    double weight7 = (turns <= 1.9) ? 0.0 : (turns >= 2.1 ? 1.0 : (turns - 1.9) / 0.2);

    for (int i = 0; i < tickCount; i++) {
      double angle = (i * 2 * pi) / tickCount - pi / 2;
      double tickPos = (i * 2 * pi) / tickCount;

      double dist = (pointerAngle - tickPos).abs();
      if (dist > pi) dist = 2 * pi - dist;
      
      // GERİ GETİRİLEN DALGA HİSSİ: sigma 0.35 (Sevilen önceki keskinlik)
      double bulge = exp(-(dist * dist) / (0.35 * 0.35));

      // Her çubuğun "ana çubuk olma" ağırlığını hesapla
      double majorWeight = 0.0;
      if (i % 12 == 0) majorWeight += weight12;
      if (i % 21 == 0) majorWeight += weight21;
      if (i % 7 == 0) majorWeight += weight7;
      majorWeight = majorWeight.clamp(0.0, 1.0);

      bool isPassed = tickPos <= pointerAngle + 0.001 || turns >= 0.99;

      // Sabit Base Uzunluğu (Önceki versiyondaki gibi taban hep aynı kalır)
      double baseLen = 6.0 + (majorWeight * 8.0); // 6.0'dan 14.0'a (6.0+8.0) yumuşak geçiş
      // Dinamik Büyüme: Sadece Dalga (Bulge) Alanı ve Zaman Katmanına (timeScale) Göre Uzama
      double tickLength = baseLen + (8.0 * bulge * timeScale); 
      double tickWidth = 1.0 + (majorWeight * 1.2) + (1.2 * bulge); 

      final p1 = Offset(center.dx + (radius - tickLength) * cos(angle), center.dy + (radius - tickLength) * sin(angle));
      final p2 = Offset(center.dx + radius * cos(angle), center.dy + radius * sin(angle));

      // Oyuk (Inset) Shading
      paint.color = isPassed 
          ? activeColor.withValues(alpha: 0.6 + (0.4 * bulge)) 
          : (isDark ? Colors.white : Colors.black).withValues(alpha: 0.12 + (0.12 * majorWeight));
      paint.strokeWidth = tickWidth;
      canvas.drawLine(p1, p2, paint);

      // Kenar Işığı (Fiziksel Derinlik)
      if (!isPassed || bulge > 0.1) {
        paint.color = Colors.white.withValues(alpha: (0.02 + (0.04 * majorWeight)) + (0.04 * bulge));
        paint.strokeWidth = tickWidth * 0.4;
        canvas.drawLine(Offset(p1.dx + 0.7, p1.dy + 0.7), Offset(p2.dx + 0.7, p2.dy + 0.7), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DialTicksPainter old) => 
      old.currentAngle != currentAngle || 
      old.activeColor != activeColor || 
      old.isDark != isDark;
}
