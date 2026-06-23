import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/string_utils.dart';
import '../../../../core/providers/db_providers.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../../../core/services/balance_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../vaults_providers.dart';
import 'staggered_entry_anim.dart';
import 'history_record_tile.dart';
import '../../../../core/database/models/transaction_status.dart';


class HistoryDayGroup extends ConsumerWidget {
  final DateTime date;
  final List<TransactionUI> transactions;
  final Future<void> Function(TransactionUI) onReviewed;
  final Future<void> Function(TransactionUI) onSkipped;
  final void Function(TransactionUI) onTap;
  final void Function(TransactionUI) onLongPress;
  final String? selectedVaultId;
  final int startIndex;
  final Set<String> animatedTxIds;

  const HistoryDayGroup({
    super.key,
    required this.date,
    required this.transactions,
    required this.onReviewed,
    required this.onSkipped,
    required this.onTap,
    required this.onLongPress,
    required this.startIndex,
    required this.animatedTxIds,
    this.selectedVaultId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final settings = ref.watch(settingsProvider);
    final rates = ref.watch(exchangeRatesProvider).value ?? [];

    // Calculate net amount for this day in target settings currency
    double dailyNet = 0.0;
    for (final tx in transactions) {
      if (tx.status == TransactionStatus.skipped) continue;

      final double convAmount = tx.getConvertedAmount(settings.currencySymbol, rates);
      if (tx.isIncome) {
        dailyNet += convAmount;
      } else {
        dailyNet -= convAmount;
      }
    }

    final String netText = CurrencyUtils.formatAmount(
      dailyNet.abs(),
      currencySymbol: settings.currencySymbol,
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

    // Calculate cumulative balance up to this date
    final allVaults = ref.watch(allVaultsProvider);
    final dbRecords = ref.watch(allTransactionsProvider);
    double dayBalance = 0.0;
    String balanceCurrency = settings.currencySymbol;

    if (selectedVaultId == null) {
      dayBalance = BalanceService.calculateNetBalance(
        vaults: allVaults,
        records: dbRecords,
        targetCurrency: settings.currencySymbol,
        rates: rates,
        untilDate: date,
      );
      balanceCurrency = settings.currencySymbol;
    } else {
      final vault = allVaults.where((v) => 'v_${v.id}' == selectedVaultId).firstOrNull;
      if (vault != null) {
        final vaultCurrency = vault.currency;
        final targetCurrency = vaultCurrency == 'AUTO' ? settings.currencySymbol : vaultCurrency;
        dayBalance = BalanceService.calculateVaultBalance(
          vault: vault,
          records: dbRecords,
          targetCurrency: targetCurrency,
          rates: rates,
          untilDate: date,
        );
        balanceCurrency = targetCurrency;
      }
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day Header Row
        Padding(
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
        ),

        // Record Tiles List
        ...transactions.asMap().entries.map((entry) {
          final txIndex = entry.key;
          final tx = entry.value;
          final globalIndex = startIndex + txIndex;
          
          final txId = 'tx_${tx.id}';
          final shouldAnimate = !animatedTxIds.contains(txId);
          if (shouldAnimate) {
            animatedTxIds.add(txId);
          }

          return StaggeredEntryAnim(
            key: ValueKey(txId),
            index: globalIndex,
            animate: shouldAnimate,
            child: HistoryRecordTile(
              key: ValueKey(tx.id),
              transaction: tx,
              selectedVaultId: selectedVaultId,
              onReviewed: () => onReviewed(tx),
              onSkipped: () => onSkipped(tx),
              onTap: () => onTap(tx),
              onLongPress: () => onLongPress(tx),
            ),
          );
        }),
        const SizedBox(height: 12),
      ],
    );
  }
}
