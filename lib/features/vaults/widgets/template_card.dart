import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/category_utils.dart';
import '../../../../core/utils/string_utils.dart';
import '../../../../core/providers/db_providers.dart';
import '../../../../shared/widgets/solid_surface.dart';
import '../vaults_providers.dart';
import '../../../../l10n/app_localizations.dart';

class TemplateCard extends ConsumerWidget {
  final TemplateUI template;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const TemplateCard({
    super.key,
    required this.template,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tx = template;
    final l10n = AppLocalizations.of(context)!;
    final customCategories = ref.watch(customCategoriesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    final sf = (screenHeight / 812.0).clamp(0.85, 1.0);

    String? periodLabel;
    if (tx.periodType == 250) {
      periodLabel = l10n.weekdays;
    } else if (tx.periodType == 251) {
      periodLabel = l10n.weekends;
    } else {
      final unit = tx.periodType ~/ 100;
      final interval = tx.periodType % 100;
      
      switch (unit) {
        case 1:
          periodLabel = interval == 1 
              ? l10n.daily 
              : l10n.daysCount(interval);
          break;
        case 2:
          if (interval == 1) {
            periodLabel = l10n.weekly;
          } else if (interval == 2) {
            periodLabel = l10n.every2Weeks;
          } else if (interval == 3) {
            periodLabel = l10n.every3Weeks;
          } else {
            periodLabel = l10n.weeksCount(interval);
          }
          break;
        case 3:
          if (interval == 1) {
            periodLabel = l10n.monthly;
          } else if (interval == 3) {
            periodLabel = l10n.every3Months;
          } else if (interval == 6) {
            periodLabel = l10n.every6Months;
          } else {
            periodLabel = l10n.monthsCount(interval);
          }
          break;
        case 4:
          periodLabel = interval == 1 ? l10n.yearly : l10n.yearsCount(interval);
          break;
      }
    }

    final categoryName = CategoryUtils.getCategoryName(
      categoryId: tx.categoryId,
      context: context,
      customCategories: customCategories,
      fallbackTitle: tx.title,
    );
    final parentId = tx.categoryId?.split('_').take(2).join('_');
    final parentName = parentId != null
        ? CategoryUtils.getCategoryName(
            categoryId: parentId,
            context: context,
            customCategories: customCategories,
          )
        : null;
    final hasSubCategory = parentName != null && parentName != categoryName;

    final amountColor = tx.isIncome
        ? AppColors.getIncome(context)
        : AppColors.getExpense(context);
    final vaultCount = tx.vaultId != null ? 1 : 0;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: SolidSurface(
        padding: EdgeInsets.zero,
        borderRadius: 18 * sf,
        showShadow: true,
        child: Stack(
          children: [
            // 1. Watermark Background Icon
            Positioned(
              right: -15 * sf,
              bottom: -10 * sf,
              child: IgnorePointer(
                child: Transform.rotate(
                  angle: -0.22,
                  child: ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          tx.color.withValues(alpha: isDark ? 0.16 : 0.09),
                          tx.color.withValues(alpha: 0.0),
                        ],
                        stops: const [0.35, 1.0],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.srcIn,
                    child: Icon(
                      tx.icon,
                      size: 105 * sf,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            // 2. Card Content
            Padding(
              padding: EdgeInsets.all(10 * sf),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28 * sf,
                        height: 28 * sf,
                        decoration: BoxDecoration(
                          color: AppColors.getAccentDeep(context, tx.color).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8 * sf),
                        ),
                        child: Icon(tx.icon, color: AppColors.getAccentDeep(context, tx.color), size: 15 * sf),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FittedBox(
                          alignment: Alignment.centerRight,
                          fit: BoxFit.scaleDown,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                hasSubCategory ? parentName : categoryName,
                                style: TextStyle(
                                  fontSize: 15 * sf,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.getTextPrimary(context),
                                  letterSpacing: -0.5,
                                  height: 1.1,
                                ),
                                textAlign: TextAlign.right,
                                maxLines: 1,
                                overflow: TextOverflow.visible,
                              ),
                              if (hasSubCategory)
                                Text(
                                  categoryName.toSafeUpperCase(context),
                                  style: TextStyle(
                                    fontSize: 9 * sf,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.getAccentDeep(context, tx.color).withValues(alpha: 0.7),
                                    letterSpacing: 0.5,
                                    height: 1.1,
                                  ),
                                  textAlign: TextAlign.right,
                                  maxLines: 1,
                                  overflow: TextOverflow.visible,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 4 * sf),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: tx.minAmount != null && tx.maxAmount != null
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      CurrencyUtils.formatAmount(tx.effectiveAmount, currencySymbol: tx.currency ?? "₺"),
                                      style: TextStyle(
                                        fontSize: 36 * sf,
                                        fontWeight: FontWeight.w900,
                                        color: amountColor,
                                        letterSpacing: -1.2,
                                        height: 1.1,
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          CurrencyUtils.formatAmount(tx.minAmount!, currencySymbol: tx.currency ?? "₺"),
                                          style: TextStyle(
                                            fontSize: 10.5 * sf,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.getTextSecondary(context).withValues(alpha: 0.6),
                                          ),
                                        ),
                                        Text(
                                          ' – ',
                                          style: TextStyle(
                                            fontSize: 10 * sf,
                                            color: AppColors.getTextSecondary(context).withValues(alpha: 0.3),
                                          ),
                                        ),
                                        Text(
                                          CurrencyUtils.formatAmount(tx.maxAmount!, currencySymbol: tx.currency ?? "₺"),
                                          style: TextStyle(
                                            fontSize: 10.5 * sf,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.getTextSecondary(context).withValues(alpha: 0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              : Text(
                                  CurrencyUtils.formatAmount(tx.effectiveAmount, currencySymbol: tx.currency ?? "₺"),
                                  style: TextStyle(
                                    fontSize: 44 * sf,
                                    fontWeight: FontWeight.w900,
                                    color: amountColor,
                                    letterSpacing: -1.8,
                                    height: 1.1,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.bottomCenter,
                        child: SizedBox(
                          width: constraints.maxWidth,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (tx.isNotificationEnabled) ...[
                                    Icon(
                                      tx.isNotificationEnabled
                                          ? Icons.notifications_active_rounded
                                          : Icons.notifications_off_rounded,
                                      color: tx.isNotificationEnabled
                                          ? AppColors.getPrimary(context)
                                          : AppColors.getTextSecondary(context).withValues(alpha: 0.3),
                                      size: 13 * sf,
                                    ),
                                    if (vaultCount > 0)
                                      SizedBox(width: 4 * sf),
                                  ],
                                  if (vaultCount > 0) ...[
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 5 * sf,
                                        vertical: 2 * sf,
                                      ),
                                      decoration: BoxDecoration(
                                        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
                                        borderRadius: BorderRadius.circular(5 * sf),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '$vaultCount',
                                            style: TextStyle(
                                              fontSize: 8 * sf,
                                              fontWeight: FontWeight.w900,
                                              color: AppColors.getTextSecondary(context).withValues(alpha: 0.7),
                                              letterSpacing: 0.4,
                                            ),
                                          ),
                                          SizedBox(width: 3 * sf),
                                          Icon(
                                            Icons.account_balance_wallet_rounded,
                                            size: 9 * sf,
                                            color: AppColors.getTextSecondary(context).withValues(alpha: 0.5),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  if (tx.isPaused) ...[
                                    if (vaultCount > 0 || tx.isNotificationEnabled)
                                      SizedBox(width: 4 * sf),
                                    Icon(
                                      Icons.pause_circle_filled_rounded,
                                      size: 13 * sf,
                                      color: Colors.orangeAccent,
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(width: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (tx.totalInstallments != null) ...[
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 5 * sf,
                                        vertical: 2 * sf,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(5 * sf),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '${tx.totalInstallments}',
                                            style: TextStyle(
                                              fontSize: 8 * sf,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.blueAccent,
                                              letterSpacing: 0.4,
                                            ),
                                          ),
                                          SizedBox(width: 3 * sf),
                                          Icon(
                                            Icons.repeat_rounded,
                                            size: 10 * sf,
                                            color: Colors.blueAccent,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ] else if (tx.periodType != 0) ...[
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 5 * sf,
                                        vertical: 2 * sf,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(5 * sf),
                                      ),
                                      child: Icon(
                                        Icons.all_inclusive_rounded,
                                        size: 10 * sf,
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                  ],
                                  if (periodLabel != null)
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 5 * sf,
                                        vertical: 2 * sf,
                                      ),
                                      decoration: BoxDecoration(
                                        color: amountColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(5 * sf),
                                      ),
                                      child: Text(
                                        periodLabel.toSafeUpperCase(context),
                                        style: TextStyle(
                                          fontSize: 8 * sf,
                                          fontWeight: FontWeight.w900,
                                          color: amountColor,
                                          letterSpacing: 0.4,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
