import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/database/models/financial_goal.dart';
import '../../../../l10n/app_localizations.dart';

class AnalysisSliverHeader extends StatelessWidget {
  final FinancialGoal goal;
  final AppLocalizations l10n;
  final NumberFormat currencyFormat;
  final String currencySymbol;

  const AnalysisSliverHeader({
    super.key,
    required this.goal,
    required this.l10n,
    required this.currencyFormat,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double safeTop = MediaQuery.of(context).padding.top;

    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final double currentH = constraints.biggest.height;
          final double minH = kToolbarHeight + safeTop;
          final double totalRange = (200 + safeTop - minH);
          
          double t = totalRange > 0 ? ((currentH - minH) / totalRange).clamp(0.0, 1.0) : 0.0;
          if (t.isNaN) t = 0.0;
          
          final double revT = 1.0 - t;

          return Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.none,
            children: [
              // GPU-Friendly Blur Layer: Constant blur radius, dynamic opacity
              Positioned.fill(
                child: Opacity(
                  opacity: revT,
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.getBackground(context).withValues(alpha: 0.15),
                          border: Border(
                            bottom: BorderSide(
                              color: (isDark ? Colors.white : Colors.black).withValues(
                                alpha: revT > 0.95 ? (revT - 0.95) * 2 : 0.0,
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
                  fit: StackFit.expand,
                  clipBehavior: Clip.none,
                  children: [
                    // Gradient background (Expanded only)
                    Positioned.fill(
                      child: Opacity(
                        opacity: t,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.getPrimary(context).withValues(alpha: 0.1),
                                AppColors.getSecondary(context).withValues(alpha: 0.03),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Title Morphing
                    Positioned(
                      top: safeTop + (kToolbarHeight - 20) / 2 + (t * 70),
                      left: 0,
                      right: 0,
                      child: IgnorePointer(
                        child: Text(
                          l10n.analysisResult.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.getTextPrimary(context),
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0 + (t * 2),
                          ),
                        ),
                      ),
                    ),

                    // Left Chip
                    Positioned(
                      top: safeTop + (kToolbarHeight - 20) / 2 + (t * 115),
                      right: MediaQuery.of(context).size.width / 2 + (t * 6) + ((1.0 - t) * 40),
                      child: IgnorePointer(
                        child: Opacity(
                          opacity: (t * 2 - 0.5).clamp(0.0, 1.0),
                          child: Transform.scale(
                            scale: 0.8 + (t * 0.2),
                            child: Transform.rotate(
                              angle: -0.05 * (1.0 - t),
                              child: _headerInfoChip(
                                context,
                                icon: Icons.flag_circle_rounded,
                                label: '$currencySymbol${currencyFormat.format(goal.targetAmount.toInt())}',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Right Chip
                    Positioned(
                      top: safeTop + (kToolbarHeight - 20) / 2 + (t * 115),
                      left: MediaQuery.of(context).size.width / 2 + (t * 6) + ((1.0 - t) * 40),
                      child: IgnorePointer(
                        child: Opacity(
                          opacity: (t * 2 - 0.5).clamp(0.0, 1.0),
                          child: Transform.scale(
                            scale: 0.8 + (t * 0.2),
                            child: Transform.rotate(
                              angle: 0.05 * (1.0 - t),
                              child: _headerInfoChip(
                                context,
                                icon: Icons.calendar_month_rounded,
                                label: goal.targetDate != null
                                    ? DateFormat('MMM yyyy').format(goal.targetDate!)
                                    : "Süresiz",
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Back Button
                    Positioned(
                      top: safeTop + 4,
                      left: 8,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(50),
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.black.withValues(alpha: 0.4)
                                  : Colors.white.withValues(alpha: 0.8),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.getPrimary(context).withValues(alpha: 0.15),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 16,
                              color: AppColors.getTextPrimary(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _headerInfoChip(BuildContext context, {required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.getPrimary(context).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.getPrimary(context).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.getPrimary(context)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(context),
            ),
          ),
        ],
      ),
    );
  }
}
