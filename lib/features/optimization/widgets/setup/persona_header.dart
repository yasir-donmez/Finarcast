import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/theme/app_constants.dart';
import '../../../../core/database/models/financial_goal.dart';
import '../../../../shared/widgets/precision_glass_card.dart';
import '../../../../shared/widgets/precision_membership_orb.dart';
import '../../../../l10n/app_localizations.dart';

class OptimizationPersonaHeader extends StatefulWidget {
  final List<FinancialGoal> goals;
  final String? currentPersonaText;
  final bool isAnalyzing;
  final AppLocalizations l10n;

  const OptimizationPersonaHeader({
    super.key,
    required this.goals,
    this.currentPersonaText,
    required this.isAnalyzing,
    required this.l10n,
  });

  @override
  State<OptimizationPersonaHeader> createState() => _OptimizationPersonaHeaderState();
}

class _OptimizationPersonaHeaderState extends State<OptimizationPersonaHeader> with SingleTickerProviderStateMixin {
  late final AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final savedPersona = widget.goals.firstOrNull?.aiPersonaText;
    final displayText = widget.currentPersonaText ?? savedPersona;
    final screenWidth = MediaQuery.of(context).size.width;
    final showGlow = widget.isAnalyzing;

    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: showGlow ? [
                  BoxShadow(
                    color: AppColors.getPrimary(context).withValues(alpha: 0.1 * _glowController.value),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ] : null,
              ),
              child: PrecisionGlassCard(
                borderRadius: 24,
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: 20,
                ),
                child: Row(
                  children: [
                    PrecisionMembershipOrb(
                      color: AppColors.getPrimary(context),
                      size: 56,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.l10n.financialIdentity.toUpperCase(),
                            style: TextStyle(
                              color: AppColors.getPrimary(context),
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            displayText ?? widget.l10n.financialIdentityHint,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.getTextPrimary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (showGlow)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _GradientBorderPainter(
                      progress: _glowController.value,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _GradientBorderPainter extends CustomPainter {
  final double progress;
  _GradientBorderPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(24));
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..shader = SweepGradient(
        colors: [
          Colors.transparent,
          const Color(0xFF4285F4).withValues(alpha: 0.8 * progress),
          const Color(0xFF9B51E0).withValues(alpha: 0.8 * progress),
          const Color(0xFFEA4335).withValues(alpha: 0.8 * progress),
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
        transform: GradientRotation(progress * 2 * math.pi),
      ).createShader(rect);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _GradientBorderPainter oldDelegate) => 
      oldDelegate.progress != progress;
}
