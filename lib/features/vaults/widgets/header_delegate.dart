import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_constants.dart';
import '../vaults_providers.dart';
import 'vault_card_stack.dart';

class TrueMorphDeckHeaderDelegate extends SliverPersistentHeaderDelegate {
  final List<TransactionGroup> groups;
  final List<TransactionUI> allTransactions;
  final String? selectedVaultId;
  final Function(String?) onVaultSelect;
  final Color activeColor;
  final VoidCallback onAddVault;
  final AppLocalizations l10n;
  final Function(String?) onVaultTap;
  final double topPadding;
  final VoidCallback onShowNotifications;
  final int unseenNotificationsCount;

  TrueMorphDeckHeaderDelegate({
    required this.groups,
    required this.allTransactions,
    required this.selectedVaultId,
    required this.onVaultSelect,
    required this.activeColor,
    required this.onAddVault,
    required this.l10n,
    required this.onVaultTap,
    required this.topPadding,
    required this.onShowNotifications,
    required this.unseenNotificationsCount,
  });

  // --- Tasarım Sistemi Sabitleri ---
  static const double kCompactCardHeight = 56.0;
  static const double kExpandedCardHeight = 300.0;
  static const double kHeaderBottomBuffer = 20.0; // Pinned haldeyken alttaki nefes payı
  
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final topPadding = MediaQuery.of(context).padding.top;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final deckItems = [null, ...groups.map((g) => g.id)];
    final currentIndex = deckItems.indexOf(selectedVaultId);

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
          // GPU-Friendly Blur Layer: Constant blur radius, dynamic opacity
          if (bgAlpha > 0.01)
            Positioned.fill(
              child: Opacity(
                opacity: bgAlpha,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.getBackground(context).withValues(alpha: 0.15),
                        border: Border(
                          bottom: BorderSide(
                            color: (isDark ? Colors.white : Colors.black).withValues(
                              alpha: progress > 0.95 ? (progress - 0.95) * 2 : 0.0,
                            ),
                            width: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          // Content Layer
          Positioned.fill(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: lerpDouble(topPadding + 80, compactTopOffset, progress)!,
                  left: 0, right: 0,
                  height: lerpDouble(kExpandedCardHeight, kCompactCardHeight, progress)!,
                  child: VaultCardStack(
                    deckItems: deckItems,
                    allTransactions: allTransactions,
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
                      child: Text(l10n.vaults, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1.5)),
                    ),
                  ),

                if (iconOpacity > 0.01)
                  Positioned(
                    right: 20 - (progress * 150),
                    top: topPadding + 10,
                    child: Opacity(
                      opacity: iconOpacity,
                      child: Row(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              HeaderIconButton(
                                icon: Icons.notifications_none_rounded,
                                onTap: onShowNotifications,
                              ),
                              if (unseenNotificationsCount > 0)
                                Positioned(
                                  right: 2,
                                  top: 2,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.redAccent.withValues(alpha: 0.5),
                                          blurRadius: 4,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          HeaderIconButton(icon: Icons.add_rounded, onTap: onAddVault),
                        ],
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
  double get maxExtent => 420;
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
  
  const HeaderIconButton({
    super.key,
    required this.icon, 
    required this.onTap,
    this.isSelected = false,
    this.activeColor,
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
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isPressed
                        ? (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05))
                        : (isDark ? Colors.black.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.8)),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: (activeColor ?? AppColors.getPrimary(context)).withValues(alpha: 0.15),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isPressed ? 0.05 : 0.1),
                        blurRadius: isPressed ? 4 : 8,
                        offset: Offset(0, isPressed ? 1 : 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon, 
                    size: 20, 
                    color: isSelected 
                        ? (activeColor ?? AppColors.getPrimary(context)) 
                        : AppColors.getTextPrimary(context).withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
