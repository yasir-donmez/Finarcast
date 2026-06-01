import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_constants.dart';
import '../../core/providers/settings_provider.dart';

/// Finarcast Standart Organik Açılır Ekran (Fluid Sheet).
/// Tüm popup ve modal ekranlar bu bileşeni kullanarak standartlaşır.
class CustomBottomSheet extends ConsumerWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final double? height;
  final bool showHandle;
  final bool isFullScreen;

  const CustomBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.height,
    this.showHandle = true,
    this.isFullScreen = false,
  });

  /// Statik bir yardımcı metod ile kolayca çağrılabilir
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    List<Widget>? actions,
    double? height,
    bool showHandle = true,
    bool isFullScreen = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: isDark 
          ? Colors.black.withValues(alpha: 0.5) 
          : Colors.black.withValues(alpha: 0.1), // Daha da şeffaf karartma
      sheetAnimationStyle: AnimationStyle(
        duration: const Duration(milliseconds: 280),
        reverseDuration: const Duration(milliseconds: 200),
      ),
      builder: (context) => CustomBottomSheet(
        title: title,
        actions: actions,
        height: height,
        showHandle: showHandle,
        isFullScreen: isFullScreen,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    
    final bgColorStyle = ref.watch(settingsProvider.select((s) => s.bgColorStyle));

    final Color activeBgColor;
    final Color activeBorderColor;

    if (bgColorStyle == 2) {
      // ════ SADE ════ (Solid, plain)
      activeBgColor = AppColors.getThemeSurface(context, 2, isInsideSheet: false);
      activeBorderColor = AppColors.getThemeBorder(context, 2);
    } else {
      // ════ RENKLİ ════ (Solid, tinted) - Varsayılan
      activeBgColor = AppColors.getThemeSurface(context, 1, isInsideSheet: false);
      activeBorderColor = AppColors.getThemeBorder(context, 1);
    }
    
    return PrecisionSheetScope(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Sayfa kapandığında tetiklenecek alan
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(color: Colors.transparent),
              ),
            ),
            
            // Bombeli Gövde
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              constraints: BoxConstraints(
                maxHeight: isFullScreen 
                    ? MediaQuery.of(context).size.height 
                    : MediaQuery.of(context).size.height * 0.88,
              ),
              width: double.infinity,
              decoration: BoxDecoration(
                color: activeBgColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLarge * 2.5)),
                border: Border.all(
                  color: activeBorderColor,
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
                    blurRadius: 40,
                    offset: const Offset(0, -10),
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLarge * 2.5)),
                child: _buildSheetContent(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSheetContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showHandle) ...[
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.getTextSecondary(context).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
        ],
        
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingLarge),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title!,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.getTextPrimary(context),
                      letterSpacing: -0.8,
                    ),
                  ),
                ),
                if (actions != null) Row(children: actions!),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        Flexible(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.98, end: 1.0),
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(
                    opacity: ((value - 0.95) / 0.05).clamp(0.0, 1.0),
                    child: child,
                  ),
                );
              },
              child: RepaintBoundary(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: AppSizes.paddingLarge,
                    right: AppSizes.paddingLarge,
                    bottom: AppSizes.paddingLarge,
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ),
        
        // Alt boşluk (Güvenli alan kontrolü ile)
        SizedBox(height: MediaQuery.of(context).padding.bottom > 0 ? MediaQuery.of(context).padding.bottom : AppSizes.paddingLarge),
      ],
    );
  }
}

/// InheritedWidget providing context-based checking of whether a widget is rendered inside a CustomBottomSheet.
class PrecisionSheetScope extends InheritedWidget {
  const PrecisionSheetScope({
    super.key,
    required super.child,
  });

  static PrecisionSheetScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PrecisionSheetScope>();
  }

  @override
  bool updateShouldNotify(PrecisionSheetScope oldWidget) => false;
}
