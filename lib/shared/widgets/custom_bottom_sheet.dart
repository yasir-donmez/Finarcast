import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_constants.dart';
import '../../core/providers/settings_provider.dart';

/// Finarcast Standart Organik Açılır Ekran (Fluid Sheet).
/// Tüm popup ve modal ekranlar bu bileşeni kullanarak standartlaşır.
class CustomBottomSheet extends ConsumerWidget {
  final Widget child;
  final dynamic title; // String? veya Widget? kabul eder
  final List<Widget>? actions;
  final double? height;
  final bool showHandle;
  final bool isFullScreen;
  final bool hasInput;

  const CustomBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.height,
    this.showHandle = true,
    this.isFullScreen = false,
    this.hasInput = false,
  });

  /// Statik bir yardımcı metod ile kolayca çağrılabilir
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    dynamic title,
    List<Widget>? actions,
    double? height,
    bool showHandle = true,
    bool isFullScreen = false,
    bool hasInput = false,
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
        hasInput: hasInput,
        child: child,
      ),
    );
  }

  static double _lastKnownKeyboardHeight = 290.0; // Makul bir varsayılan klavye yüksekliği

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ═══ Granüler MediaQuery — sadece ilgili alan değişince rebuild ═══
    final viewInsetsBottom = MediaQuery.viewInsetsOf(context).bottom;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final safePadding = MediaQuery.paddingOf(context);
    final safeBottom = safePadding.bottom;
    final safeTop = safePadding.top;
    
    // Klavye yüksekliğini kaydet (sadece gerçek klavye yüksekliği geldiğinde güncelle)
    if (viewInsetsBottom > 0) {
      _lastKnownKeyboardHeight = viewInsetsBottom;
    }

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

    // ═══════════════════════════════════════════════════════════════════
    // NATIVE-LEVEL KEYBOARD TRACKING
    // ═══════════════════════════════════════════════════════════════════
    // viewInsets.bottom OS'un her animasyon karesinde güncellenir.
    // Direkt Padding'e vererek kare-kare senkronize takip sağlanır.
    // AnimatedContainer KULLANILMAZ — çift animasyon jank yaratır.
    // ═══════════════════════════════════════════════════════════════════

    final route = ModalRoute.of(context);
    final bool isEntering = route?.animation?.status == AnimationStatus.forward;

    // Sheet'in alt kenarı klavyenin tam üstünde oturmalı (native davranış).
    final double keyboardOffset;
    if (hasInput && isEntering && viewInsetsBottom == 0) {
      // Klavye henüz açılmadı ama açılacak — önceden konumla
      keyboardOffset = _lastKnownKeyboardHeight;
    } else {
      // Normal durum: OS'un kare-kare verdiği değeri direkt kullan
      keyboardOffset = viewInsetsBottom;
    }

    final double bottomMargin = keyboardOffset > 0
        ? keyboardOffset + 16.0
        : safeBottom + 16.0;

    // ═══ Kullanılabilir alan: ekran - alt boşluk - üst güvenli alan - nefes payı ═══
    // Sheet hiçbir zaman status bar / notch / Dynamic Island'ın arkasına girmemeli.
    final double availableHeight = screenHeight - bottomMargin - safeTop - 8.0;
    final double desiredHeight = height ?? (isFullScreen
        ? availableHeight
        : screenHeight * 0.85);
    final double maxSheetHeight = desiredHeight.clamp(0.0, availableHeight);

    return PrecisionSheetScope(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Sayfa kapandığında tetiklenecek alan (Tüm ekranı kaplar)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(color: Colors.transparent),
            ),
          ),
          
          // Yüzen Gövde — Padding ile kare-kare klavye takibi
          Padding(
            padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: bottomMargin,
            ),
            child: Container(
              constraints: BoxConstraints(maxHeight: maxSheetHeight),
              width: double.infinity,
              decoration: BoxDecoration(
                color: activeBgColor,
                borderRadius: BorderRadius.circular(28.0),
                border: Border.all(
                  color: activeBorderColor,
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28.0),
                child: _buildSheetContent(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSheetContent(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxContentHeight = constraints.maxHeight;
        
        // Calculate static content height to get remaining scrollable height
        double staticHeight = 0.0;
        if (showHandle) staticHeight += 28.0; // handle padding + height
        if (title != null) staticHeight += 56.0; // title height + spacing
        staticHeight += 12.0; // bottom spacing
        
        final double remainingHeight = (maxContentHeight - staticHeight).clamp(0.0, double.infinity);
        
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
                      child: title is Widget
                          ? (title as Widget)
                          : Text(
                              title!.toString(),
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
            
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: remainingHeight,
              ),
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
                        bottom: 0.0,
                      ),
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
            
            // Alt boşluk (Yüzen kart olduğu için standart hafif dolgu yeterlidir)
            const SizedBox(height: 12.0),
          ],
        );
      },
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
