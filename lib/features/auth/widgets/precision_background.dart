import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_constants.dart';

/// Finarcast "Sıvı Ruh" Arka Planı (Liquid Spirit Background).
/// Arkada yavaşça süzülen, organik formda renkli blob'lar (leke) oluşturur.
class PrecisionBackground extends StatefulWidget {
  final Widget? child;
  final bool useSystemBackground;
  const PrecisionBackground({
    super.key, 
    this.child,
    this.useSystemBackground = true,
  });

  @override
  State<PrecisionBackground> createState() => _PrecisionBackgroundState();
}

class _PrecisionBackgroundState extends State<PrecisionBackground> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      // 1. En alt katman: Düz Siyah veya Temiz Aydınlık Gri
      color: isDark ? Colors.black : const Color(0xFFF5F7FA),
      child: Stack(
        children: [
          // 2. Orta katman: Desen (İkonlar)
          Positioned.fill(
            child: Opacity(
              opacity: isDark ? 0.15 : 0.12,
              child: Image.asset(
                AppAssets.getBackgroundImg(context),
                repeat: ImageRepeat.repeat,
                scale: 2.8,
                // 3. İkonları tema rengine boyuyoruz
                color: AppColors.getPrimary(context),
                colorBlendMode: BlendMode.srcIn,
                filterQuality: FilterQuality.low,
              ),
            ),
          ),
          
          // Üstteki İçerik
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}
