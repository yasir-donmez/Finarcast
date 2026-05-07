import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../shared/widgets/precision_glass_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../ai_service.dart';

class AnalysisOptimizationSection extends StatefulWidget {
  final OptimizationResult opt;
  final AppLocalizations l10n;
  final NumberFormat currencyFormat;

  const AnalysisOptimizationSection({
    super.key,
    required this.opt,
    required this.l10n,
    required this.currencyFormat,
  });

  @override
  State<AnalysisOptimizationSection> createState() => _AnalysisOptimizationSectionState();
}

class _AnalysisOptimizationSectionState extends State<AnalysisOptimizationSection> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeTransition(
          opacity: _controller,
          child: PrecisionGlassCard(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.psychology_rounded,
                  color: AppColors.getSecondary(context),
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.l10n.aiCoachSuggestion.toUpperCase(),
                        style: TextStyle(
                          color: AppColors.getSecondary(context),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.opt.coachMessage,
                        style: TextStyle(
                          color: AppColors.getTextPrimary(context),
                          fontSize: 15,
                          height: 1.6,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        ...List.generate(widget.opt.cuts.length, (index) {
          final cut = widget.opt.cuts[index];
          final animation = CurvedAnimation(
            parent: _controller,
            curve: Interval(
              (0.2 + (index * 0.1)).clamp(0.0, 1.0),
              (0.7 + (index * 0.1)).clamp(0.0, 1.0),
              curve: Curves.easeOutBack,
            ),
          );
          
          return AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Opacity(
                opacity: animation.value,
                child: Transform.translate(
                  offset: Offset(0, 30 * (1 - animation.value)),
                  child: _buildCutRowFluid(context, cut),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildCutRowFluid(BuildContext context, CutSuggestion cut) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: PrecisionGlassCard(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cut.category,
                    style: TextStyle(
                      color: AppColors.getTextPrimary(context),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cut.reason,
                    style: TextStyle(
                      color: AppColors.getTextSecondary(context).withValues(alpha: 0.7),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₺${widget.currencyFormat.format(cut.suggestedAmount.toInt())}',
                  style: TextStyle(
                    color: AppColors.getPrimary(context),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '← ₺${widget.currencyFormat.format(cut.currentAmount.toInt())}',
                  style: TextStyle(
                    color: AppColors.getTextSecondary(context).withValues(alpha: 0.5),
                    fontSize: 12,
                    decoration: TextDecoration.lineThrough,
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
