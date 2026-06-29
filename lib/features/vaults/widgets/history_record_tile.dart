import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../shared/widgets/custom_dismissible.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../vaults_providers.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/database/models/transaction_status.dart';


class HistoryRecordTile extends StatefulWidget {
  final TransactionUI transaction;
  final Future<void> Function() onReviewed;
  final Future<void> Function() onSkipped;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final String? selectedVaultId;
  final String categoryName;
  final String? parentName;

  const HistoryRecordTile({
    super.key,
    required this.transaction,
    required this.onReviewed,
    required this.onSkipped,
    required this.onTap,
    required this.onLongPress,
    required this.categoryName,
    this.parentName,
    this.selectedVaultId,
  });

  @override
  State<HistoryRecordTile> createState() => _HistoryRecordTileState();
}

class _HistoryRecordTileState extends State<HistoryRecordTile> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final tx = widget.transaction;
    final bool isSkipped = tx.status == TransactionStatus.skipped;
    final bool isReviewed = tx.isReviewed;

    final bool enableLeftToRight = !isReviewed || isSkipped;
    final bool enableRightToLeft = !isSkipped;


    return CustomDismissible(
      enableLeftToRight: enableLeftToRight,
      enableRightToLeft: enableRightToLeft,
      onDismissed: (direction) async {
        if (direction == SwipeDismissDirection.leftToRight) {
          await widget.onReviewed();
        } else {
          await widget.onSkipped();
        }
      },
      leftToRightBackgroundBuilder: (context, progress, isThresholdReached) =>
          _buildSwipeBackground(isLeftToRight: true, progress: progress, isThresholdReached: isThresholdReached),
      rightToLeftBackgroundBuilder: (context, progress, isThresholdReached) =>
          _buildSwipeBackground(isLeftToRight: false, progress: progress, isThresholdReached: isThresholdReached),
      child: GestureDetector(
        onTapDown: (_) {
          setState(() {
            _scale = 0.98;
          });
        },
        onTapUp: (_) {
          setState(() {
            _scale = 1.0;
          });
        },
        onTapCancel: () {
          setState(() {
            _scale = 1.0;
          });
        },
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap();
        },
        onLongPress: () {
          HapticFeedback.heavyImpact();
          widget.onLongPress();
        },
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
          child: _buildCardContent(context),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground({
    required bool isLeftToRight,
    required double progress,
    required bool isThresholdReached,
  }) {
    final color = isLeftToRight
        ? const Color(0xFF10B981)
        : const Color(0xFFF59E0B);
    final alignment = isLeftToRight
        ? Alignment.centerLeft
        : Alignment.centerRight;
    final rotationSign = isLeftToRight ? -1.0 : 1.0;

    final rotationProgress = (progress / 0.25).clamp(0.0, 1.0);
    final angle = (1.0 - rotationProgress) * (math.pi / 2) * rotationSign;

    final slideSign = isLeftToRight ? -1.0 : 1.0;
    final slideProgress = (progress / 0.25).clamp(0.0, 1.0);
    final xOffset = 30.0 * (1.0 - slideProgress) * slideSign;

    final double bgAlpha = isThresholdReached
        ? 0.22
        : (progress / 0.20).clamp(0.0, 1.0) * 0.08;
        
    final double borderAlpha = isThresholdReached
        ? 0.45
        : (progress / 0.20).clamp(0.0, 1.0) * 0.12;

    final Color bgColor = color.withValues(alpha: bgAlpha);
    final Color borderColor = color.withValues(alpha: borderAlpha);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Align(
          alignment: alignment,
          child: Transform(
            transform: Matrix4.translationValues(xOffset, 0.0, 0.0)
              ..setEntry(3, 2, 0.004)
              ..rotateY(angle),
            alignment: Alignment.center,
            child: AnimatedScale(
              scale: isThresholdReached ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOutCubic,
              child: Opacity(
                opacity: rotationProgress,
                child: isLeftToRight
                    ? AnimatedCheckIcon(progress: progress, color: color)
                    : AnimatedSkipIcon(progress: progress, color: color),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent(BuildContext context) {
    final tx = widget.transaction;
    final categoryName = widget.categoryName;
    final parentName = widget.parentName;
    final bool hasSubCategory = parentName != null && parentName != categoryName;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    
    final bool isSkipped = tx.status == TransactionStatus.skipped;
    final bool isReviewed = tx.isReviewed;

    final double opacity = isSkipped ? 0.45 : 1.0;
    final TextDecoration textDecoration = isSkipped ? TextDecoration.lineThrough : TextDecoration.none;

    final isTransfer = tx.targetVaultId != null;
    bool isIncoming = tx.isIncome;
    if (isTransfer && widget.selectedVaultId != null && widget.selectedVaultId!.startsWith('v_')) {
      final activeId = int.tryParse(widget.selectedVaultId!.replaceFirst('v_', ''));
      isIncoming = activeId == tx.targetVaultId;
    }

    final amountColor = isSkipped
        ? AppColors.getTextSecondary(context).withValues(alpha: 0.5)
        : (isTransfer
            ? Colors.blueGrey
            : (isIncoming ? AppColors.getIncome(context) : AppColors.getExpense(context)));

    final String amountText = tx.minAmount != null && tx.maxAmount != null
        ? "${CurrencyUtils.formatAmount(tx.minAmount!, currencySymbol: tx.currency ?? "₺")} ~ ${CurrencyUtils.formatAmount(tx.maxAmount!, currencySymbol: tx.currency ?? "₺")}"
        : CurrencyUtils.formatAmount(tx.effectiveAmount, currencySymbol: tx.currency ?? "₺");

    String? installmentLabel;
    if (tx.installmentNumber != null && tx.totalInstallments != null) {
      installmentLabel = '${tx.installmentNumber}/${tx.totalInstallments}';
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final sf = (screenHeight / 812.0).clamp(0.85, 1.0);

    Widget cardContent = Opacity(
      opacity: opacity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16 * sf),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.45],
              colors: [
                tx.color.withValues(alpha: isDark ? 0.14 : 0.18),
                Colors.transparent,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -15 * sf,
                bottom: -10 * sf,
                child: IgnorePointer(
                  child: Transform.rotate(
                    angle: -math.pi / 7,
                    child: Icon(
                      tx.icon,
                      size: 105 * sf,
                      color: tx.color.withValues(alpha: isDark ? 0.05 : 0.035),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.getAccentDeep(context, tx.color).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(tx.icon, color: AppColors.getAccentDeep(context, tx.color), size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  categoryName,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: hasSubCategory
                                        ? AppColors.getAccentDeep(context, tx.color)
                                        : AppColors.getTextPrimary(context),
                                    decoration: textDecoration,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Text(
                                isIncoming ? l10n.income : l10n.expense,
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.getTextSecondary(context).withValues(alpha: 0.6)),
                              ),
                              Text(
                                ' • ',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.getTextSecondary(context).withValues(alpha: 0.3),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  DateFormat('d MMMM yyyy', locale).format(tx.date),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.getTextSecondary(context).withValues(alpha: 0.6),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (installmentLabel != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  installmentLabel,
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.getTextSecondary(context),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              amountText,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: amountColor,
                                  decoration: textDecoration),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (isSkipped)
                          Icon(
                            Icons.skip_next_rounded,
                            size: 14,
                            color: AppColors.getTextSecondary(context).withValues(alpha: 0.5),
                          )
                        else if (!isReviewed)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 3, top: 3, bottom: 3),
                            decoration: BoxDecoration(
                              color: AppColors.getPrimary(context),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.getPrimary(context).withValues(alpha: 0.4),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          )
                        else
                          Icon(
                            Icons.check_circle_outline_rounded,
                            size: 14,
                            color: AppColors.getIncome(context).withValues(alpha: 0.7),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final cardContainer = CustomCard(
      padding: EdgeInsets.zero,
      child: cardContent,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: cardContainer,
    );
  }
}


