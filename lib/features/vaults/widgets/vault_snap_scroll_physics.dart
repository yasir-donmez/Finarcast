import 'package:flutter/material.dart';

class VaultSnapScrollPhysics extends BouncingScrollPhysics {
  final double maxScrollExtent;

  const VaultSnapScrollPhysics({
    super.parent,
    required this.maxScrollExtent,
  });

  @override
  VaultSnapScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return VaultSnapScrollPhysics(
      parent: buildParent(ancestor),
      maxScrollExtent: maxScrollExtent,
    );
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    final tolerance = toleranceFor(position);
    final offset = position.pixels;

    // Eğer Kasa başlığının küçüldüğü bölgedeysek
    if (offset > 0.0 && offset < maxScrollExtent) {
      final double target;
      
      // Flick (Hızlı kaydırma) veya Konum kontrolü
      if (velocity.abs() > tolerance.velocity) {
        target = velocity > 0 ? maxScrollExtent : 0.0;
      } else {
        // Standart %50 sınırı (daha tahmin edilebilir)
        target = offset > maxScrollExtent / 2 ? maxScrollExtent : 0.0;
      }
      
      return ScrollSpringSimulation(
        spring, // Varsayılan yay ayarı (BouncingScrollPhysics'ten gelir)
        offset,
        target,
        velocity,
        tolerance: tolerance,
      );
    }
    
    return super.createBallisticSimulation(position, velocity);
  }
}
