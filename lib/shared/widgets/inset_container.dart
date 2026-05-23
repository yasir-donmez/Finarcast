import 'package:flutter/material.dart';
import '../../core/theme/app_constants.dart';

class InsetContainer extends StatelessWidget {
  final double size;
  final Widget child;
  const InsetContainer({super.key, required this.size, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = AppColors.getBackground(context);
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(32),
        // Göçük efekti için gölgeleri ters çeviriyoruz (Dış gölge yerine içe yakın gölge simülasyonu)
        boxShadow: isDark ? [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.05),
            offset: const Offset(2, 2),
            blurRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            offset: const Offset(-4, -4),
            blurRadius: 10,
          ),
        ] : [
          BoxShadow(
            color: Colors.white,
            offset: const Offset(2, 2),
            blurRadius: 2,
          ),
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            offset: const Offset(-4, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(1), // İnce bir kenarlık çizgisi
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark ? [
              Colors.black.withValues(alpha: 0.3), // Üst sol daha karanlık (derinlik)
              bgColor,                             // Orta bakiye
              Colors.white.withValues(alpha: 0.03), // Alt sağ hafif ışık (kenar)
            ] : [
              Colors.grey.withValues(alpha: 0.2),
              bgColor,
              Colors.white,
            ],
          ),
        ),
        child: Center(
          child: Opacity(
            opacity: 0.6, // İkonun da yüzeye gömülü durması için opaklığı azaltıyoruz
            child: child,
          ),
        ),
      ),
    );
  }
}
