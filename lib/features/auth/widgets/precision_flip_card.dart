import 'dart:math' as math;
import 'package:flutter/material.dart';

/// FinCast "Akışkan Çift Yüzlü Kart" (Fluid 3D Flip Card).
/// Giriş ve Kayıt formlarını kartın ön ve arka yüzünde taşıyan, 
/// 3D döndürme animasyonuna sahip premium bileşen.
class PrecisionFlipCard extends StatefulWidget {
  final bool isFront;
  final Widget front;
  final Widget back;

  const PrecisionFlipCard({
    super.key,
    required this.isFront,
    required this.front,
    required this.back,
  });

  @override
  State<PrecisionFlipCard> createState() => _PrecisionFlipCardState();
}

class _PrecisionFlipCardState extends State<PrecisionFlipCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutSine,
    );

    if (!widget.isFront) _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(PrecisionFlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFront != oldWidget.isFront) {
      if (widget.isFront) {
        _controller.reverse();
      } else {
        _controller.forward();
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
    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        // LAYOUT PROVIDER (Hayalet Katman)
        // Bu bölüm kartın asıl boyutunu belirler. 
        // widget.isFront değiştiği anda (0. milisaniyede) hedef formun 
        // boyutunu üst katmandaki AnimatedSize'a raporlar.
        // Verimlilik için 'visible: false' tutulur ama yer kaplaması sağlanır.
        Visibility(
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          visible: false,
          child: widget.isFront ? widget.front : widget.back,
        ),

        // ANIMATION PROVIDER (Dönen Katman)
        // 'Positioned.fill' + 'OverflowBox' kombinasyonu sayesinde:
        // 1. Dönen içerik, Layout Provider'ın alanına ortalanır.
        // 2. Boyut değişimleri sırasında içerik "ezilmez" (squeezing olmaz), 
        //    çünkü OverflowBox içeriğin kendi doğal boyutunda kalmasına izin verir.
        Positioned.fill(
          child: OverflowBox(
            minHeight: 0,
            maxHeight: double.infinity,
            alignment: Alignment.topCenter,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                final double rotationValue = _animation.value * math.pi;
                final bool isBackVisible = rotationValue > math.pi / 2;

                // İçeriğin kaybolma ve belirme mantığı (90 dereceye yaklaştıkça yok olur)
                // 0 -> 1.0, 90 -> 0.0, 180 -> 1.0
                final double contentProgress = (rotationValue - (isBackVisible ? math.pi : 0)).abs();
                final double opacity = (1.0 - (contentProgress / (math.pi / 2)) * 2).clamp(0.0, 1.0);
                final double scale = 0.95 + (0.05 * opacity);

                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0007) // Yumuşak perspektif
                    ..rotateY(rotationValue),
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.scale(
                      scale: scale,
                      child: isBackVisible
                          ? Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()..rotateY(math.pi),
                              child: widget.back,
                            )
                          : widget.front,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

