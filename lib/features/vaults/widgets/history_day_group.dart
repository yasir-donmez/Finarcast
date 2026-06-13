import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/string_utils.dart';
import '../../../../core/providers/db_providers.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../vaults_providers.dart';
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

  const HistoryDayGroup({
    super.key,
    required this.date,
    required this.transactions,
    required this.onReviewed,
    required this.onSkipped,
    required this.onTap,
    required this.onLongPress,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day Header Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
        ...transactions.map((tx) {
          return HistoryRecordTile(
            key: ValueKey(tx.id),
            transaction: tx,
            selectedVaultId: selectedVaultId,
            onReviewed: () => onReviewed(tx),
            onSkipped: () => onSkipped(tx),
            onTap: () => onTap(tx),
            onLongPress: () => onLongPress(tx),
          );
        }),
        const SizedBox(height: 12),
      ],
    );
  }
}
