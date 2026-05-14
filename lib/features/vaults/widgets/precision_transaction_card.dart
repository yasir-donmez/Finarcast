import 'package:flutter/material.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../shared/widgets/precision_surface.dart';
import '../../../../shared/widgets/precision_sheet.dart';
import '../vaults_providers.dart';
import '../../../../l10n/app_localizations.dart';
import 'precision_detail_sheet.dart';

String? localizedCategoryName(String? categoryId, AppLocalizations l10n) {
  if (categoryId == null) return null;
  switch (categoryId) {
    case 'exp_grocery':
      return l10n.grocery;
    case 'exp_grocery_food':
      return l10n.food;
    case 'exp_grocery_cleaning':
      return l10n.cleaning;
    case 'exp_grocery_personal':
      return l10n.personalCare;
    case 'exp_dining':
      return l10n.dining;
    case 'exp_dining_restaurant':
      return l10n.restaurant;
    case 'exp_dining_fastfood':
      return l10n.fastFood;
    case 'exp_dining_cafe':
      return l10n.cafe;
    case 'exp_rent':
      return l10n.rent;
    case 'exp_rent_home':
      return l10n.homeRent;
    case 'exp_rent_office':
      return l10n.workspace;
    case 'exp_bill':
      return l10n.bill;
    case 'exp_bill_electricity':
      return l10n.electricity;
    case 'exp_bill_water':
      return l10n.water;
    case 'exp_fun':
      return l10n.entertainment;
    case 'exp_trans':
      return l10n.transportation;
    case 'exp_sub':
      return l10n.subscription;
    case 'exp_health':
      return l10n.health;
    case 'inc_salary':
      return l10n.salary;
    case 'inc_salary_main':
      return l10n.mainSalary;
    case 'inc_salary_bonus':
      return l10n.bonus;
    case 'inc_extra':
      return l10n.extraIncome;
    case 'inc_extra_freelance':
      return l10n.freelance;
    case 'inc_extra_parttime':
      return l10n.partTime;
    case 'inc_extra_commission':
      return l10n.commission;
    case 'inc_invest':
      return l10n.investmentReturn;
    case 'inc_invest_stock':
      return l10n.stock;
    case 'inc_invest_crypto':
      return l10n.crypto;
    case 'inc_invest_interest':
      return l10n.interest;
    case 'inc_rent':
      return l10n.rentalIncome;
    case 'inc_rent_home':
      return l10n.home;
    case 'inc_rent_office':
      return l10n.officeIncome;
    case 'inc_sale':
      return l10n.sale;
    case 'inc_sale_online':
      return l10n.onlineSale;
    case 'inc_sale_physical':
      return l10n.physicalSale;
    case 'inc_scholarship':
      return l10n.scholarshipLoan;
    case 'inc_scholarship_award':
      return l10n.scholarship;
    case 'inc_scholarship_loan':
      return l10n.credit;
    case 'inc_gift':
      return l10n.gift;
    case 'inc_other':
      return l10n.other;
    case 'exp_other':
      return l10n.other;
    default:
      return null;
  }
}

class PrecisionTransactionCard extends StatelessWidget {
  final TransactionUI transaction;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const PrecisionTransactionCard({
    super.key,
    required this.transaction,
    this.onDelete,
    this.onEdit,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final tx = transaction;
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    final sf = (screenHeight / 812.0).clamp(0.85, 1.0);

    String? periodLabel;
    if (tx.periodType != 0) {
      switch (tx.periodType) {
        case 1:
          periodLabel = l10n.weekly;
          break;
        case 2:
          periodLabel = l10n.monthly;
          break;
        case 3:
          periodLabel = l10n.yearly;
          break;
        case 4:
          periodLabel = l10n.every2Weeks;
          break;
        case 5:
          periodLabel = l10n.every3Weeks;
          break;
        case 6:
          periodLabel = l10n.every3Months;
          break;
        case 7:
          periodLabel = l10n.every6Months;
          break;
      }
    }

    final categoryName = localizedCategoryName(tx.categoryId, l10n) ?? l10n.all;
    final parentId = tx.categoryId?.split('_').take(2).join('_');
    final parentName = parentId != null
        ? localizedCategoryName(parentId, l10n)
        : null;
    final hasSubCategory = parentName != null && parentName != categoryName;

    final amountColor = tx.isIncome
        ? AppColors.getIncome(context)
        : AppColors.getExpense(context);
    final vaultCount = tx.groupIds.length;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: PrecisionSurface(
        padding: EdgeInsets.all(10 * sf),
        borderRadius: 18 * sf,
        isGlass: true, // Cam modu açık
        blur: 12, // Buzlu cam derinliği
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
                        color: tx.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8 * sf),
                      ),
                      child: Icon(tx.icon, color: tx.color, size: 15 * sf),
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
                                  color: tx.color.withValues(alpha: 0.5),
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
                                          color: AppColors.getTextPrimary(context).withValues(alpha: 0.3),
                                        ),
                                      ),
                                      Text(
                                        ' – ',
                                        style: TextStyle(
                                          fontSize: 10 * sf,
                                          color: AppColors.getTextPrimary(context).withValues(alpha: 0.15),
                                        ),
                                      ),
                                      Text(
                                        CurrencyUtils.formatAmount(tx.maxAmount!, currencySymbol: tx.currency ?? "₺"),
                                        style: TextStyle(
                                          fontSize: 10.5 * sf,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.getTextPrimary(context).withValues(alpha: 0.3),
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
                                if (tx.isNotificationEnabled)
                                  Icon(
                                    Icons.notifications_active_rounded,
                                    color: AppColors.getPrimary(context),
                                    size: 13 * sf,
                                  ),
                                if (tx.isNotificationEnabled && vaultCount > 0)
                                  SizedBox(width: 4 * sf),
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
  VoidCallback? onRemoveFromVault,
  required bool isInVault,
}) {
  PrecisionSheet.show(
    context: context,
    title: transaction.name,
    child: PrecisionDetailSheet(
      transaction: transaction,
      onEdit: onEdit,
      onDelete: onDelete,
      onRemoveFromVault: onRemoveFromVault,
      isInVault: isInVault,
    ),
  );
}
