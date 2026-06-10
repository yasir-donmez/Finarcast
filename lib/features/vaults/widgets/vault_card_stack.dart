import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/providers/settings_provider.dart';
import '../vaults_providers.dart';
import 'integrated_vault_card.dart';

class VaultCardStack extends ConsumerStatefulWidget {
  final List<String?> deckItems;
  final int currentIndex;
  final Function(String?) onVaultSelect;
  final Color activeColor;
  final AppLocalizations l10n;
  final List<TransactionGroup> groups;
  final double morphProgress;
  final Function(String?) onVaultTap;

  const VaultCardStack({
    super.key,
    required this.deckItems, 
    required this.currentIndex, 
    required this.onVaultSelect, 
    required this.activeColor, 
    required this.l10n, 
    required this.groups, 
    required this.morphProgress,
    required this.onVaultTap,
  });

  @override
  ConsumerState<VaultCardStack> createState() => _VaultCardStackState();
}

class _VaultCardStackState extends ConsumerState<VaultCardStack> {
  late PageController _pageController;
  int? _lastTargetIndex;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.currentIndex, viewportFraction: 0.70);
    _lastTargetIndex = widget.currentIndex;
  }
  
  @override
  void didUpdateWidget(covariant VaultCardStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // YENİ: Daha hassas Manyetik Kilit
    // Kaydırma başladığı an (0.005) hemen en yakın karta otur.
    if (widget.morphProgress > 0.005 && oldWidget.morphProgress <= 0.005) {
      if (_pageController.hasClients) {
        final double? currentPage = _pageController.page;
        if (currentPage != null) {
          final int targetPage = currentPage.round();
          if ((currentPage - targetPage).abs() > 0.001) {
             _pageController.animateToPage(
              targetPage, 
              duration: const Duration(milliseconds: 150), // Daha hızlı kilitlenme
              curve: Curves.easeOutQuart
            );
            if (targetPage >= 0 && targetPage < widget.deckItems.length) {
              Future.microtask(() => widget.onVaultSelect(widget.deckItems[targetPage]));
            }
          }
        }
      }
    }

    if (oldWidget.currentIndex != widget.currentIndex && _pageController.hasClients) {
      if (_lastTargetIndex != widget.currentIndex) {
        _lastTargetIndex = widget.currentIndex;
        _pageController.animateToPage(widget.currentIndex, duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Kasa kartları %1 bile küçülmeye başlasa etkileşimi (kaydırmayı) kapatıyoruz.
    final bool isInteractingDisabled = widget.morphProgress > 0.01;

    return PageView.builder(
      controller: _pageController,
      physics: isInteractingDisabled ? const NeverScrollableScrollPhysics() : const PageScrollPhysics(),
      clipBehavior: Clip.hardEdge,
      itemCount: widget.deckItems.length,
      onPageChanged: (page) {
        _lastTargetIndex = page;
        HapticFeedback.selectionClick();
        if (page >= 0 && page < widget.deckItems.length) {
          widget.onVaultSelect(widget.deckItems[page]);
        }
      },
      itemBuilder: (context, index) {
        final vaultId = widget.deckItems[index];
        final globalCurrency = ref.watch(settingsProvider).currencySymbol;
        final cardDataMap = ref.watch(vaultCardDataProvider);
        
        final cardData = cardDataMap[vaultId] ?? VaultCardData(
          vaultId: vaultId,
          income: 0,
          expense: 0,
          balance: 0,
          currencySymbol: globalCurrency,
          targetCurrency: globalCurrency,
          hasFlexibleTx: false,
          minNet: 0,
          maxNet: 0,
        );

        return AnimatedBuilder(
          animation: _pageController,
          builder: (context, child) {
            double value = 1.0;
            if (_pageController.position.haveDimensions) {
              double diff = (_pageController.page! - index).abs();
              value = (1 - (diff * 0.15)).clamp(0.85, 1.0);
            } else {
              value = index == widget.currentIndex ? 1.0 : 0.85;
            }
            
            final isCurrent = index == widget.currentIndex;
            final cardOpacity = isCurrent ? 1.0 : (1 - widget.morphProgress * 2.0).clamp(0.0, 1.0);
            
            // Seçili olmayan kartlar daha hızlı yanlara doğru kaysın (Depth Effect)
            final double slideOutOffset = (index - widget.currentIndex) * (widget.morphProgress * 450);

            return Center(
              child: Opacity(
                opacity: cardOpacity * (isCurrent ? 1.0 : (value * 2 - 1).clamp(0.0, 1.0)),
                child: Transform.translate(
                  offset: Offset(slideOutOffset, 0),
                  child: Transform.scale(
                    scale: isCurrent ? value : value * (1 - widget.morphProgress * 0.15), // Yumuşak küçülme
                    child: RepaintBoundary(
                      child: GestureDetector(
                        onTap: isCurrent ? () => widget.onVaultTap(vaultId) : null,
                        child: IntegratedVaultCard(
                          vaultId: vaultId,
                          income: cardData.income,
                          expense: cardData.expense,
                          balance: cardData.balance,
                          activeColor: widget.activeColor,
                          l10n: widget.l10n,
                          vaultName: widget.groups[index].name,
                          currencySymbol: cardData.currencySymbol,
                          convertedBalance: cardData.convertedBalance,
                          convertedSymbol: globalCurrency,
                          hasFlexibleTx: cardData.hasFlexibleTx,
                          minNet: cardData.minNet,
                          maxNet: cardData.maxNet,
                          morphProgress: widget.morphProgress,
                          isCurrent: isCurrent,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
