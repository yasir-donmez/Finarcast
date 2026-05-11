import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../shared/widgets/precision_surface.dart';
import '../../../../shared/widgets/precision_glass_card.dart';
import '../../../../l10n/app_localizations.dart';
import 'financial_reactor_button.dart';

class AnalysisCockpit extends StatelessWidget {
  final double targetAmount;
  final bool isAnalyzing;
  final VoidCallback onAnalyzeTap;
  final VoidCallback onAmountTap;
  final DateTime targetDate;
  final String vaultName;
  final VoidCallback onDateTap;
  final VoidCallback onVaultTap;
  final String currencySymbol;
  final AppLocalizations l10n;

  const AnalysisCockpit({
    super.key,
    required this.targetAmount,
    required this.isAnalyzing,
    required this.onAnalyzeTap,
    required this.onAmountTap,
    required this.targetDate,
    required this.vaultName,
    required this.onDateTap,
    required this.onVaultTap,
    required this.currencySymbol,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat('#,##0', 'tr_TR');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 100,
        top: 12,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.getBackground(context).withValues(alpha: 0.0),
            AppColors.getBackground(context).withValues(alpha: 0.7),
          ],
          stops: const [0.0, 1.0],
        ),
      ),
      child: PrecisionSurface(
        padding: const EdgeInsets.all(20),
        isGlass: true,
        borderRadius: 32,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onAmountTap,
                    child: PrecisionGlassCard(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 20,
                      ),
                      color: isDark ? const Color(0xFF0F0F0F) : Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.targetAmountLabel('').trim().toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                              color: AppColors.getPrimary(
                                context,
                              ).withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$currencySymbol${currencyFormat.format(targetAmount.toInt())}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                FinancialReactorButton(
                  isAnalyzing: isAnalyzing,
                  onTap: onAnalyzeTap,
                  label: l10n.analyze,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _GlassChip(
                    label: DateFormat('MMM yyyy').format(targetDate),
                    onTap: onDateTap,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _GlassChip(
                    label: vaultName,
                    onTap: onVaultTap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _GlassChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: PrecisionGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Center(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
