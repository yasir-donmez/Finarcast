import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../core/database/models/exchange_rate.dart';

import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_constants.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../shared/widgets/precision_glass_card.dart';
import '../vaults_providers.dart';

class IntegratedVaultCard extends StatelessWidget {
  final String? vaultId;
  final double income;
  final double expense;
  final double balance;
  final List<TransactionUI> txs;
  final Color activeColor;
  final AppLocalizations l10n;
  final String vaultName;
  final String currencySymbol;
  final double morphProgress;
  final bool isCurrent;
  final double? convertedBalance;
  final String? convertedSymbol;
  final List<ExchangeRate> exchangeRates;
  final String targetCurrency;

  const IntegratedVaultCard({
    super.key,
    required this.vaultId, 
    required this.income,
    required this.expense,
    required this.balance,
    required this.txs,
    required this.activeColor, 
    required this.l10n, 
    required this.vaultName, 
    required this.currencySymbol,
    required this.morphProgress, 
    required this.isCurrent,
    this.convertedBalance,
    this.convertedSymbol,
    this.exchangeRates = const [],
    this.targetCurrency = 'TRY',
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // --- Curves for different effects ---
    final double widthT = Curves.easeOutQuart.transform(morphProgress);
    
    final double cardWidth = lerpDouble(screenWidth * 0.70, screenWidth, widthT)!;
    final double cardHeight = lerpDouble(280, 56, morphProgress)!;
    
    // --- Glass Morphing Spread (2. Madde) ---
    final double decorationOpacity = (1 - morphProgress * 2.2).clamp(0.0, 1.0); 
    final double cardRadius = lerpDouble(32, 0, Curves.easeInOutCubic.transform((morphProgress * 1.8).clamp(0.0, 1.0)))!;
    
    final double hPad = lerpDouble(24, 20, morphProgress)!;
    final double effectiveWidth = isCurrent ? cardWidth : screenWidth * 0.70;
    
    return OverflowBox(
      maxWidth: effectiveWidth,
      maxHeight: cardHeight,
      child: SizedBox(
        width: effectiveWidth,
        height: cardHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // === ARKA PLAN: Premium Glass (morph sırasında kaybolur) ===
            if (decorationOpacity > 0.01)
              Positioned.fill(
                child: Opacity(
                  opacity: decorationOpacity,
                  child: PrecisionGlassCard(
                    borderRadius: cardRadius,
                    isGlass: true,
                    child: const SizedBox.expand(),
                  ),
                ),
              ),

            // === İÇERİK: Başlık, bakiye vs. (her zaman görünür) ===
            Positioned(
              left: hPad, right: hPad,
              top: 0, bottom: 0,
              child: _buildMorphContent(context, isDark, cardHeight, effectiveWidth),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMorphContent(BuildContext context, bool isDark, double h, double effectiveWidth) {
    final screenWidth = MediaQuery.of(context).size.width;
    final hasFlexibleTx = txs.any((t) => t.minAmount != null || t.maxAmount != null);
    
    // Animasyon progressleri
    final double contentT = Curves.easeInOutCubic.transform(morphProgress);
    final double magneticT = Curves.easeOutCubic.transform(morphProgress); 
    
    // Smooth Size Logic
    final double titleFontSize = lerpDouble(12, 17, contentT)!; 
    final double balanceFontSize = lerpDouble(42, 18, contentT)!; 
    final double titleLetterSpacing = lerpDouble(1.2, -0.4, contentT)!;
    final double balanceLetterSpacing = lerpDouble(-2.0, 0.2, contentT)!;
    
    final double badgePadH = lerpDouble(0, 12, contentT)!;
    final double badgePadV = lerpDouble(0, 6, contentT)!;
    final double badgeBgAlpha = contentT * (isDark ? 0.12 : 0.06);

    // Smooth Color Logic
    final Color textColor = AppColors.getTextPrimary(context);
    final Color nameColor = Color.lerp(
      activeColor.withValues(alpha: 0.9),
      textColor,
      contentT,
    )!;

    final Color balanceColor = Color.lerp(
      activeColor,
      activeColor, 
      contentT,
    )!;
    
    // --- Geniş Mod (Expanded) Pozisyonları ---
    final double titleExpandedTop = h * 0.12;
    final double balanceExpandedTop = titleExpandedTop + 30; 
    final double secondaryExpandedTop = balanceExpandedTop + 65; 
    
    // --- Dar Mod (Compact) Pozisyonları ---
    final double titleCompactTop = (h - titleFontSize) / 2;
    final double balanceCompactTop = (h - balanceFontSize) / 2;

    final double titleTop = lerpDouble(titleExpandedTop, titleCompactTop, magneticT)!;
    final double balanceTop = lerpDouble(balanceExpandedTop, balanceCompactTop, magneticT)!;
    
    final double statsOpacity = (1 - morphProgress * 5.0).clamp(0.0, 1.0); 
    final double rangeOpacity = (1 - morphProgress * 8.0).clamp(0.0, 1.0); 
    final double swapOpacity  = (1 - morphProgress * 12.0).clamp(0.0, 1.0); 

    // Yukarı kaçma efekti (Parallax)
    final double parallaxOffset = morphProgress * -80.0; 
    
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // === TITLE ===
        Positioned(
          left: 4, right: 4, 
          top: titleTop,
          child: Align(
            alignment: Alignment.lerp(Alignment.center, Alignment.centerLeft, magneticT)!,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: lerpDouble(effectiveWidth * 0.85, screenWidth * 0.55, magneticT)!,
              ),
              child: Text(
                vaultName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w900,
                  letterSpacing: titleLetterSpacing,
                  color: nameColor,
                ),
              ),
            ),
          ),
        ),
        
        // === BALANCE ===
        Positioned(
          left: 4, right: 4,
          top: balanceTop,
          child: Align(
            alignment: Alignment.lerp(Alignment.center, Alignment.centerRight, magneticT)!,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: lerpDouble(effectiveWidth - 24, screenWidth * 0.42, magneticT)!,
              ),
              padding: EdgeInsets.symmetric(horizontal: badgePadH, vertical: badgePadV),
              decoration: BoxDecoration(
                color: activeColor.withValues(alpha: badgeBgAlpha),
                borderRadius: BorderRadius.circular(12),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.lerp(Alignment.center, Alignment.centerRight, magneticT)!,
                child: Text(
                  CurrencyUtils.formatFullAmount(balance, symbol: currencySymbol),
                  style: TextStyle(
                    fontSize: balanceFontSize,
                    fontWeight: FontWeight.w900,
                    color: balanceColor,
                    letterSpacing: balanceLetterSpacing,
                  ),
                ),
              ),
            ),
          ),
        ),
        
        // === DÖNÜŞTÜRÜLMÜŞ BAKİYE ===
        if (convertedBalance != null && statsOpacity > 0.01)
          Positioned(
            left: 0, right: 0,
            top: balanceTop + balanceFontSize + 4,
            child: Opacity(
              opacity: statsOpacity,
              child: Center(
                child: Text(
                  '≈ ${CurrencyUtils.formatFullAmount(convertedBalance!, symbol: convertedSymbol)}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.getTextPrimary(context).withValues(alpha: 0.4),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),

        // === SECONDARY STATS (STAGGERED FADE-OUT + PARALLAX) ===
        if (statsOpacity > 0.01)
          Positioned(
            left: 0, right: 0,
            top: secondaryExpandedTop,
            child: Transform.translate(
              offset: Offset(0, parallaxOffset),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Opacity(
                    opacity: statsOpacity,
                    child: Row(
                      children: [
                        Expanded(child: _buildMiniStat(l10n.income, income, AppColors.getIncome(context))),
                        Container(width: 1, height: 30, color: activeColor.withValues(alpha: 0.15)),
                        Expanded(child: _buildMiniStat(l10n.expense, expense, AppColors.getExpense(context))),
                      ],
                    ),
                  ),
                  
                  if (rangeOpacity > 0.01)
                    Opacity(
                      opacity: rangeOpacity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Divider(
                          height: 1, 
                          thickness: 0.5, 
                          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1)
                        ),
                      ),
                    ),

                  if (hasFlexibleTx && rangeOpacity > 0.01)
                    Opacity(
                      opacity: rangeOpacity,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildRangeStats(txs, targetCurrency, exchangeRates),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),

                  if (swapOpacity > 0.01)
                    Opacity(
                      opacity: swapOpacity,
                      child: Transform.translate(
                        offset: Offset(0, parallaxOffset * 0.5), 
                        child: const Icon(Icons.swap_horiz_rounded, size: 20, color: Colors.grey),
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMiniStat(String label, double amount, Color color) {
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label.toUpperCase(), 
            style: TextStyle(
              fontSize: 9, 
              fontWeight: FontWeight.w900, 
              color: Colors.grey.withValues(alpha: 0.6), 
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            CurrencyUtils.formatAmount(amount, currencySymbol: currencySymbol), 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color),
          ),
        ),
      ],
    );
  }

  Widget _buildRangeStats(List<TransactionUI> txs, String targetCurrency, List<ExchangeRate> rates) {
    final activeTxs = txs.where((t) => !t.isArchived).toList();

    final minNet = activeTxs.where((t) => t.isIncome).fold<double>(0, (s, t) {
          final amt = t.minAmount ?? t.amount;
          final eff = t.effectiveAmount;
          final monthly = (t.periodType == 0 || eff == 0) ? amt : (amt * (t.monthlyEquivalent / eff));
          return s + CurrencyUtils.convert(monthly, t.currency ?? '₺', targetCurrency, rates);
        }) 
        - activeTxs.where((t) => !t.isIncome).fold<double>(0, (s, t) {
          final amt = t.maxAmount ?? t.amount;
          final eff = t.effectiveAmount;
          final monthly = (t.periodType == 0 || eff == 0) ? amt : (amt * (t.monthlyEquivalent / eff));
          return s + CurrencyUtils.convert(monthly, t.currency ?? '₺', targetCurrency, rates);
        });

    final maxNet = activeTxs.where((t) => t.isIncome).fold<double>(0, (s, t) {
          final amt = t.maxAmount ?? t.amount;
          final eff = t.effectiveAmount;
          final monthly = (t.periodType == 0 || eff == 0) ? amt : (amt * (t.monthlyEquivalent / eff));
          return s + CurrencyUtils.convert(monthly, t.currency ?? '₺', targetCurrency, rates);
        }) 
        - activeTxs.where((t) => !t.isIncome).fold<double>(0, (s, t) {
          final amt = t.minAmount ?? t.amount;
          final eff = t.effectiveAmount;
          final monthly = (t.periodType == 0 || eff == 0) ? amt : (amt * (t.monthlyEquivalent / eff));
          return s + CurrencyUtils.convert(monthly, t.currency ?? '₺', targetCurrency, rates);
        });
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildRangeStat(l10n.worstCase, minNet, Colors.orange),
        _buildRangeStat(l10n.bestCase, maxNet, Colors.blue),
      ],
    );
  }

  Widget _buildRangeStat(String label, double amount, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 5, height: 5, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label, 
              style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                CurrencyUtils.formatAmount(amount, currencySymbol: currencySymbol), 
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
