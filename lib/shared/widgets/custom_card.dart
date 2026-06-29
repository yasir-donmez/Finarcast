import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/theme/app_constants.dart';
import 'custom_bottom_sheet.dart';

/// Finarcast "Hafif" Mat Kapsayıcı (Light Card).
class CustomCard extends ConsumerWidget {
  final Widget child;
  final double scalingFactor;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;

  const CustomCard({
    super.key,
    required this.child,
    this.scalingFactor = 1.0,
    this.padding,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bgColorStyle = ref.watch(settingsProvider.select((s) => s.bgColorStyle));
    final isInsideSheet = PrecisionSheetScope.of(context) != null;
    
    Color activeBgColor;
    Color activeBorderColor;

    if (bgColorStyle == 2) {
      // 1. SADE MOD (Mat & Katı - Sabit Gri/Beyaz)
      activeBgColor = backgroundColor ?? AppColors.getThemeSurface(context, 2, isInsideSheet: isInsideSheet);
      activeBorderColor = borderColor ?? AppColors.getThemeBorder(context, 2);
    } else {
      // 2. RENKLİ MOD (Mat & Katı - Tema Uyumlu Renkli) - Varsayılan
      activeBgColor = backgroundColor ?? AppColors.getThemeSurface(context, 1, isInsideSheet: isInsideSheet);
      activeBorderColor = borderColor ?? AppColors.getThemeBorder(context, 1);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? EdgeInsets.all(12 * scalingFactor),
        decoration: BoxDecoration(
          color: activeBgColor,
          borderRadius: BorderRadius.circular(16 * scalingFactor),
          border: Border.all(
            color: activeBorderColor,
            width: 0.5,
          ),
          boxShadow: (bgColorStyle == 1 && !isDark && backgroundColor == null)
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: child,
      ),
    );
  }
}
