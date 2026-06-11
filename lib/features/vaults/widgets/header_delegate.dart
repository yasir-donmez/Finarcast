import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_constants.dart';
import '../../../shared/widgets/glass_surface.dart';
import '../vaults_providers.dart';
import 'vault_card_stack.dart';

class TrueMorphDeckHeaderDelegate extends SliverPersistentHeaderDelegate {
  final List<TransactionGroup> groups;
  final String? selectedVaultId;
  final Function(String?) onVaultSelect;
  final Color activeColor;
  final VoidCallback onAddVault;
  final AppLocalizations l10n;
  final Function(String?) onVaultTap;
  final double topPadding;
  final VoidCallback onShowNotifications;
  final int unseenNotificationsCount;
  final double dynamicGap;

  TrueMorphDeckHeaderDelegate({
    required this.groups,
    required this.selectedVaultId,
    required this.onVaultSelect,
    required this.activeColor,
    required this.onAddVault,
    required this.l10n,
    required this.onVaultTap,
    required this.topPadding,
    required this.onShowNotifications,
    required this.unseenNotificationsCount,
    required this.dynamicGap,
  });

  // --- Tasarım Sistemi Sabitleri ---
  static const double kCompactCardHeight = 56.0;
  static const double kExpandedCardHeight = 286.0;
  static const double kHeaderBottomBuffer = 20.0; // Pinned haldeyken alttaki nefes payı
  
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final topPadding = MediaQuery.of(context).padding.top;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final deckItems = groups.map((g) => g.id).toList();
    final currentIndex = deckItems.isEmpty
        ? 0
        : deckItems.indexOf(selectedVaultId ?? '').clamp(0, deckItems.length - 1);

    final bgAlpha = Curves.easeOutQuad.transform((progress * 1.6).clamp(0.0, 1.0));
    final iconOpacity = (1 - progress * 1.8).clamp(0.0, 1.0);

    // Kilitli haldeki içerik alanı (Status Bar hariç geri kalan alan)
    final double availableHeaderHeight = minExtent - topPadding;
    // İçeriği dikeyde ortalamak için gereken offset (ama görsel ağırlık için hafif yukarı -4px)
    final double compactTopOffset = topPadding + ((availableHeaderHeight - kCompactCardHeight) / 2) - 2;

    return SizedBox.expand(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Solid Background Layer: Dynamic opacity with glass surface
          if (bgAlpha > 0.01)
            Positioned.fill(
              child: GlassSurface(
                borderRadius: 0,
                showShadow: false,
                opacityMultiplier: bgAlpha,
                borderColor: (isDark ? Colors.white : Colors.black).withValues(
                  alpha: progress > 0.95 ? (progress - 0.95) * 2 : 0.0,
                ),
                showTopBorder: false,
                showLeftBorder: false,
                showRightBorder: false,
                child: const SizedBox.expand(),
              ),
            ),
          // Content Layer
          Positioned.fill(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: lerpDouble(topPadding + 42.0 + dynamicGap, compactTopOffset, progress)!,
                  left: 0, right: 0,
                  height: lerpDouble(kExpandedCardHeight, kCompactCardHeight, progress)!,
                  child: VaultCardStack(
                    deckItems: deckItems,
                    currentIndex: currentIndex,
                    onVaultSelect: onVaultSelect,
                    activeColor: activeColor,
                    l10n: l10n,
                    groups: groups,
                    morphProgress: progress,
                    onVaultTap: onVaultTap,
                  ),
                ),

                if (iconOpacity > 0.01)
                  Positioned(
                    left: 20 - (progress * 150),
                    top: topPadding + 10,
                    child: Opacity(
                      opacity: iconOpacity,
                      child: Transform.scale(
                        scale: iconOpacity,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          l10n.vaults,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.5,
                          ),
                        ),
                      ),
                    ),
                  ),

                if (iconOpacity > 0.01)
                  Positioned(
                    right: 20 - (progress * 150),
                    top: topPadding + 10,
                    child: Opacity(
                      opacity: iconOpacity,
                      child: Transform.scale(
                        scale: iconOpacity,
                        alignment: Alignment.centerRight,
                        child: Row(
                          children: [
                            PulsingNotificationButton(
                              unseenCount: unseenNotificationsCount,
                              onTap: onShowNotifications,
                            ),
                            const SizedBox(width: 8),
                            HeaderIconButton(icon: Icons.add_rounded, onTap: onAddVault),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => topPadding + 42.0 + dynamicGap + kExpandedCardHeight;
  @override
  double get minExtent => topPadding + kCompactCardHeight + kHeaderBottomBuffer;
  @override
  bool shouldRebuild(covariant TrueMorphDeckHeaderDelegate oldDelegate) => true;
}

class HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isSelected;
  final Color? activeColor;
  final Color? iconColor;
  
  const HeaderIconButton({
    super.key,
    required this.icon, 
    required this.onTap,
    this.isSelected = false,
    this.activeColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    bool isPressed = false;
    
    return StatefulBuilder(
      builder: (context, setState) {
        return GestureDetector(
          onTapDown: (_) => setState(() => isPressed = true),
          onTapUp: (_) => setState(() => isPressed = false),
          onTapCancel: () => setState(() => isPressed = false),
          onTap: onTap,
          child: AnimatedScale(
            scale: isPressed ? 0.95 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: GlassSurface(
              borderRadius: 999, // Tam dairesel buton
              padding: const EdgeInsets.all(13),
              showShadow: true,
              backgroundColor: isPressed
                  ? (isDark
                      ? AppColors.getThemeSurface(context, 2).withValues(alpha: 0.75)
                      : Colors.grey[200]!.withValues(alpha: 0.85))
                  : (isDark
                      ? Colors.black.withValues(alpha: 0.35)
                      : Colors.white.withValues(alpha: 0.65)),
              borderColor: isPressed
                  ? (activeColor ?? AppColors.getPrimary(context)).withValues(alpha: 0.3)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isPressed ? 0.03 : 0.08),
                  blurRadius: isPressed ? 4 : 8,
                  offset: Offset(0, isPressed ? 1 : 2),
                ),
              ],
              child: Icon(
                icon, 
                size: 24, 
                color: isPressed
                    ? (activeColor ?? AppColors.getPrimary(context))
                    : (iconColor ?? AppColors.getTextPrimary(context).withValues(alpha: 0.8)),
              ),
            ),
          ),
        );
      },
    );
  }
}

class PulsingNotificationButton extends StatefulWidget {
  final int unseenCount;
  final VoidCallback onTap;

  const PulsingNotificationButton({
    super.key,
    required this.unseenCount,
    required this.onTap,
  });

  @override
  State<PulsingNotificationButton> createState() => _PulsingNotificationButtonState();
}

class _PulsingNotificationButtonState extends State<PulsingNotificationButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    if (widget.unseenCount > 0) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant PulsingNotificationButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.unseenCount > 0 && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (widget.unseenCount == 0 && _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultIconColor = AppColors.getTextPrimary(context).withValues(alpha: 0.8);
    final colorTween = ColorTween(
      begin: defaultIconColor,
      end: AppColors.error,
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final currentColor = widget.unseenCount > 0
            ? (colorTween.evaluate(_controller) ?? AppColors.error)
            : defaultIconColor;

        return HeaderIconButton(
          icon: widget.unseenCount > 0 
              ? Icons.notifications_active_rounded 
              : Icons.notifications_none_rounded,
          onTap: widget.onTap,
          iconColor: currentColor,
        );
      },
    );
  }
}
