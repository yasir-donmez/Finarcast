import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/category_utils.dart';
import '../../../../core/providers/db_providers.dart';
import '../../../../shared/widgets/solid_surface.dart';
import '../../../../shared/widgets/custom_bottom_sheet.dart';
import '../vaults_providers.dart';
import '../../../../l10n/app_localizations.dart';
import 'detail_sheet.dart';

class TransactionCard extends ConsumerWidget {
  final TransactionUI transaction;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.onDelete,
    this.onEdit,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tx = transaction;
    final l10n = AppLocalizations.of(context)!;
    final customCategories = ref.watch(customCategoriesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    final sf = (screenHeight / 812.0).clamp(0.85, 1.0);

    String? periodLabel;
    if (tx.periodType != 0) {
      if (tx.periodType == 250) {
        periodLabel = Localizations.localeOf(context).languageCode == 'tr' ? 'Hafta İçi' : 'Weekdays';
      } else if (tx.periodType == 251) {
        periodLabel = Localizations.localeOf(context).languageCode == 'tr' ? 'Hafta Sonu' : 'Weekends';
      } else {
        final unit = tx.periodType ~/ 100;
        final interval = tx.periodType % 100;
        
        switch (unit) {
          case 1:
            periodLabel = interval == 1 
                ? (Localizations.localeOf(context).languageCode == 'tr' ? 'Günlük' : 'Daily') 
                : (Localizations.localeOf(context).languageCode == 'tr' ? '$interval Gün' : '$interval Days');
            break;
          case 2:
            if (interval == 1) {
              periodLabel = l10n.weekly;
            } else if (interval == 2) {
              periodLabel = l10n.every2Weeks;
            } else if (interval == 3) {
              periodLabel = l10n.every3Weeks;
            } else {
              periodLabel = Localizations.localeOf(context).languageCode == 'tr' ? '$interval Hafta' : '$interval Weeks';
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
              periodLabel = Localizations.localeOf(context).languageCode == 'tr' ? '$interval Ay' : '$interval Months';
            }
            break;
          case 4:
            periodLabel = interval == 1 ? l10n.yearly : (Localizations.localeOf(context).languageCode == 'tr' ? '$interval Yıl' : '$interval Years');
            break;
        }
      }
    }

    final categoryName = CategoryUtils.getCategoryName(
      categoryId: tx.categoryId,
      context: context,
      customCategories: customCategories,
      fallbackTitle: tx.name,
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
    final vaultCount = tx.groupIds.length;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: SolidSurface(
        padding: EdgeInsets.all(10 * sf),
        borderRadius: 18 * sf,
        // Cam modu açık
        // Buzlu cam derinliği
        // color: tx.color override kaldırıldı, artık nötr cam kullanılacak
        child: Stack(
          children: [
            Positioned(
              right: -15 * sf,
              top: -10 * sf,
              child: Opacity(
                opacity: isDark ? 0.05 : 0.03,
                child: Icon(tx.icon, size: 95 * sf, color: tx.color),
              ),
            ),
            Column(
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
                              overflow:
                                  TextOverflow.visible, // FittedBox handles it
                            ),
                            if (hasSubCategory)
                              Text(
                                categoryName.toUpperCase(),
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
                                if (tx.hasNotification) ...[
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
                                  Text(
                                    '$vaultCount',
                                    style: TextStyle(
                                      fontSize: 10 * sf,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.getTextSecondary(context).withValues(alpha: 0.5),
                                    ),
                                  ),
                                  const SizedBox(width: 1),
                                  Icon(
                                    Icons.account_balance_wallet_rounded,
                                    size: 9 * sf,
                                    color: AppColors.getTextSecondary(context).withValues(alpha: 0.3),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(width: 4),
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
                                  periodLabel.toUpperCase(),
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
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void showTransactionActionMenu(
  BuildContext context, {
  required TransactionUI transaction,
  required VoidCallback onEdit,
  required VoidCallback onDelete,
}) {
  CustomBottomSheet.show(
    context: context,
    title: transaction.name,
    child: DetailSheet(
      transaction: transaction,
      onEdit: onEdit,
      onDelete: onDelete,
    ),
  );
}
