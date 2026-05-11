import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/database/models/financial_goal.dart';
import '../../../../shared/widgets/precision_glass_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../analysis_detail_screen.dart';

import 'optimization_loading_card.dart';

class OptimizationHistorySection extends StatelessWidget {
  final List<FinancialGoal> goals;
  final AppLocalizations l10n;
  final bool isAnalyzing;

  const OptimizationHistorySection({
    super.key,
    required this.goals,
    required this.l10n,
    this.isAnalyzing = false,
  });

  @override
  Widget build(BuildContext context) {
    if (goals.isEmpty && !isAnalyzing) return const SizedBox.shrink();
    
    return AnimatedSize(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutQuart,
      alignment: Alignment.topCenter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history_rounded,
                color: AppColors.getPrimary(context),
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                l10n.recentAnalyses.toUpperCase(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Analiz ediliyor kartı en üstte belirir
          if (isAnalyzing) 
            const OptimizationLoadingCard(key: ValueKey('loading_card')),
          
          // Geçmiş analizler her zaman görünür kalır
          ...goals.map((g) => _buildHistoryCardFluid(context, g, l10n)),
        ],
      ),
    );
  }

  Widget _buildHistoryCardFluid(BuildContext context, FinancialGoal g, AppLocalizations l10n) {
    final currencyFormat = NumberFormat('#,##0', 'tr_TR');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: PrecisionGlassCard(
        padding: EdgeInsets.zero,
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AnalysisDetailScreen(goal: g),
              ),
            );
          },
          borderRadius: BorderRadius.circular(AppSizes.radiusDefault),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.getTextSecondary(
                      context,
                    ).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.history_edu_rounded,
                    color: AppColors.getTextSecondary(context),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${g.currencySymbol}${currencyFormat.format(g.targetAmount.toInt())}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        DateFormat('dd MMM yyyy • HH:mm').format(g.createdAt),
                        style: TextStyle(
                          color: AppColors.getTextSecondary(
                            context,
                          ).withValues(alpha: 0.6),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.getTextSecondary(
                    context,
                  ).withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
