import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/string_utils.dart';
import '../../../../core/database/models/transaction_status.dart';
import '../../../../core/providers/db_providers.dart';
import '../../../../l10n/app_localizations.dart';
import '../vaults_providers.dart';


/// Gün başlığı widget'ı — flat SliverList'te her gün grubunun başında gösterilir.
/// 
/// Artık BalanceService çağrısı yapmaz; bakiye değeri dışarıdan geçirilir.
class DayHeaderTile extends ConsumerWidget {
  final DateTime date;
  final List<TransactionUI> transactions;
  final double dayBalance;
  final String balanceCurrency;
  final String settingsCurrency;

  const DayHeaderTile({
    super.key,
    required this.date,
    required this.transactions,
    required this.dayBalance,
    required this.balanceCurrency,
    required this.settingsCurrency,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final rates = ref.watch(exchangeRatesProvider).value ?? [];

    // Calculate net amount for this day
    double dailyNet = 0.0;
    for (final tx in transactions) {
      if (tx.status == TransactionStatus.skipped) continue;

      final double convAmount = tx.getConvertedAmount(settingsCurrency, rates);
      if (tx.isIncome) {
        dailyNet += convAmount;
      } else {
        dailyNet -= convAmount;
      }
    }

    final String netText = CurrencyUtils.formatAmount(
      dailyNet.abs(),
      currencySymbol: settingsCurrency,
    );

    final String netLabel = dailyNet > 0
        ? '+ $netText'
        : (dailyNet < 0 ? '- $netText' : netText);

    final Color netColor = dailyNet > 0
        ? AppColors.getIncome(context)
        : (dailyNet < 0 ? AppColors.getExpense(context) : AppColors.getTextSecondary(context));

    // Resolve date title
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(date.year, date.month, date.day);
    final difference = checkDate.difference(today).inDays;

    String dateTitle = '';
    if (difference == 0) {
      dateTitle = l10n.today;
    } else if (difference == -1) {
      dateTitle = l10n.yesterday;
    } else if (difference == 1) {
      dateTitle = l10n.tomorrow;
    } else {
      dateTitle = DateFormat('d MMMM yyyy, EEEE', locale).format(date);
    }

    final String dayBalanceText = CurrencyUtils.formatAmount(
      dayBalance,
      currencySymbol: balanceCurrency,
    );

    final String balanceLabel;
    switch (locale) {
      case 'tr':
        balanceLabel = 'Bakiye';
        break;
      case 'de':
        balanceLabel = 'Saldo';
        break;
      case 'es':
        balanceLabel = 'Saldo';
        break;
      case 'fr':
        balanceLabel = 'Solde';
        break;
      case 'it':
        balanceLabel = 'Saldo';
        break;
      case 'pt':
        balanceLabel = 'Saldo';
        break;
      case 'ja':
        balanceLabel = '残高';
        break;
      case 'ko':
        balanceLabel = '잔액';
        break;
      case 'zh':
        balanceLabel = '余额';
        break;
      default:
        balanceLabel = 'Balance';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Text(
                  dateTitle.toSafeUpperCase(context),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: AppColors.getTextSecondary(context).withValues(alpha: 0.6),
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '($balanceLabel: $dayBalanceText)',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.getTextSecondary(context).withValues(alpha: 0.4),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          if (transactions.any((tx) => tx.status != TransactionStatus.skipped))
            Text(
              netLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: netColor,
                letterSpacing: 0.5,
              ),
            ),
        ],
      ),
    );
  }
}
