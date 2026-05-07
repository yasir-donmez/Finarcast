import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../l10n/app_localizations.dart';
import '../../optimization_providers.dart';

class AnalysisStatusSection extends StatefulWidget {
  final AnalysisSnapshot snapshot;
  final AppLocalizations l10n;
  final NumberFormat currencyFormat;

  const AnalysisStatusSection({
    super.key,
    required this.snapshot,
    required this.l10n,
    required this.currencyFormat,
  });

  @override
  State<AnalysisStatusSection> createState() => _AnalysisStatusSectionState();
}

class _AnalysisStatusSectionState extends State<AnalysisStatusSection> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scoreAnimation;
  late final Animation<int> _savingAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    final onTrack = widget.snapshot.isAlreadyOnTrack;
    final targetScore = onTrack
        ? 1.0
        : (widget.snapshot.requiredMonthlySaving > 0
            ? (widget.snapshot.monthlySurplus / widget.snapshot.requiredMonthlySaving)
                .clamp(0.0, 1.0)
            : 1.0);

    _scoreAnimation = Tween<double>(begin: 0, end: targetScore).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart),
    );

    final targetSaving = onTrack ? widget.snapshot.monthlySurplus : widget.snapshot.requiredMonthlySaving;
    _savingAnimation = IntTween(begin: 0, end: targetSaving.toInt()).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart),
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
    final onTrack = widget.snapshot.isAlreadyOnTrack;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Column(
          children: [
            const SizedBox(height: 20),
            _buildExecutiveScoreFluid(context, _scoreAnimation.value, onTrack),
            const SizedBox(height: 40),
            Opacity(
              opacity: _controller.value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - _controller.value)),
                child: Text(
                  onTrack ? widget.l10n.onTrackMessage : widget.l10n.savingsNeeded,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.getTextPrimary(context),
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Metrics Row
            Opacity(
              opacity: _controller.value,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    _vipMetricFluid(
                      context,
                      widget.l10n.targetGap,
                      widget.currencyFormat.format(widget.snapshot.gap.toInt()),
                      Icons.flag_circle_rounded,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.getTextSecondary(context).withValues(alpha: 0.1),
                    ),
                    _vipMetricFluid(
                      context,
                      widget.l10n.remainingTime,
                      widget.l10n.monthsToTargetLabel(widget.snapshot.months),
                      Icons.timelapse_rounded,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Main Value Display
            Container(
              padding: const EdgeInsets.all(32),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                boxShadow: [
                  BoxShadow(
                    color: (onTrack ? AppColors.getSuccess(context) : AppColors.getError(context)).withValues(alpha: 0.1),
                    blurRadius: 30,
                    spreadRadius: -10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    onTrack ? widget.l10n.currentSurplus : widget.l10n.requiredMonthlySavings,
                    style: TextStyle(
                      color: AppColors.getTextSecondary(context).withValues(alpha: 0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '₺',
                        style: TextStyle(
                          color: onTrack ? AppColors.getSuccess(context) : AppColors.getError(context),
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.currencyFormat.format(_savingAnimation.value),
                        style: TextStyle(
                          color: onTrack ? AppColors.getSuccess(context) : AppColors.getError(context),
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -2.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExecutiveScoreFluid(BuildContext context, double score, bool onTrack) {
    final color = onTrack
        ? AppColors.getSuccess(context)
        : (score < 0.4 ? AppColors.getError(context) : AppColors.getPrimary(context));
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 170,
          height: 170,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.15),
                blurRadius: 40,
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(4, 4),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(-4, -4),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 150,
          width: 150,
          child: CircularProgressIndicator(
            value: score,
            strokeWidth: 12,
            backgroundColor: Colors.black.withValues(alpha: 0.05),
            color: color,
            strokeCap: StrokeCap.round,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${(score * 100).toInt()}',
              style: TextStyle(
                color: AppColors.getTextPrimary(context),
                fontSize: 48,
                fontWeight: FontWeight.w900,
                letterSpacing: -2,
              ),
            ),
            Text(
              widget.l10n.score.toUpperCase(),
              style: TextStyle(
                color: AppColors.getTextSecondary(context).withValues(alpha: 0.6),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 3,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _vipMetricFluid(BuildContext context, String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            size: 22,
            color: AppColors.getPrimary(context).withValues(alpha: 0.8),
          ),
          const SizedBox(height: 8),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: AppColors.getTextSecondary(context).withValues(alpha: 0.6),
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: AppColors.getTextPrimary(context),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
