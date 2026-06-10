import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_widget.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/db_providers.dart';
import '../../../core/database/models/transaction_record.dart';
import '../../../core/database/models/transaction_status.dart';
import '../../../core/database/models/custom_category.dart';
import '../../../core/database/models/exchange_rate.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/theme/app_constants.dart';
import '../../../core/utils/category_utils.dart';
import '../../../l10n/app_localizations.dart';

class TimelineActivityWidget extends ConsumerWidget {
  final HomeWidgetSize size;
  final String? selectedVaultId;
  const TimelineActivityWidget({super.key, this.size = HomeWidgetSize.large, this.selectedVaultId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(allTransactionsProvider)
        .where((tx) => tx.status != TransactionStatus.skipped)
        .toList();
    final customCategories = ref.watch(customCategoriesProvider);
    final rates = ref.watch(exchangeRatesProvider).value ?? [];
    final settings = ref.watch(settingsProvider);
    final symbol = settings.currencySymbol;
    
    // EKLEME SIRASINA GÖRE SIRALA (En son eklenen en üstte)
    final sortedTxs = transactions..sort((a, b) => b.id.compareTo(a.id));

    // Kasa / Vault bazında filtrele
    List<TransactionRecord> vaultFilteredTxs = sortedTxs;
    if (selectedVaultId != null && selectedVaultId!.startsWith('v_')) {
      final filterVaultId = int.tryParse(selectedVaultId!.replaceFirst('v_', ''));
      if (filterVaultId != null) {
        vaultFilteredTxs = sortedTxs.where((tx) => tx.vaultId == filterVaultId).toList();
      }
    }
    
    // Veri Saklama Süresine Göre Filtrele
    final now = DateTime.now();
    final retentionDays = settings.dataRetentionDays;
    final filteredTxs = vaultFilteredTxs.where((tx) {
      if (retentionDays <= 0 || retentionDays > 3650) return true; // 0 veya çok büyükse (Sonsuz) filtreleme yapma
      final cutoffDate = now.subtract(Duration(days: retentionDays));
      return tx.updatedAt.isAfter(cutoffDate);
    }).toList();
    
    // Gelir ve Giderleri ayır (Kesinlikle max 7şer adet)
    final incomeTxs = filteredTxs.where((tx) => tx.isIncome).take(7).toList();
    final expenseTxs = filteredTxs.where((tx) => !tx.isIncome).take(7).toList();

    if (filteredTxs.isEmpty) {
      return _buildEmptyState(context);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // SOL: Gelirler
        Expanded(
          child: _buildColumn(context, incomeTxs, symbol, rates, true, customCategories),
        ),
        
        const SizedBox(width: 8),
        
        // SAĞ: Giderler
        Expanded(
          child: _buildColumn(context, expenseTxs, symbol, rates, false, customCategories),
        ),
      ],
    );
  }

  Widget _buildColumn(
    BuildContext context,
    List<TransactionRecord> txs,
    String symbol,
    List<ExchangeRate> rates,
    bool isIncome,
    List<CustomCategory> customCategories,
  ) {
    final Color semanticColor = isIncome ? AppColors.getIncome(context) : AppColors.getExpense(context);
    
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: semanticColor.withValues(alpha: 0.04), // Biraz daha belirgin zemin
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Arka Plan Sembolik İkon (Düzeltilmiş Yönler)
          Positioned(
            right: isIncome ? null : -25,
            left: isIncome ? -25 : null,
            bottom: -25,
            child: Icon(
              isIncome ? Icons.north_east_rounded : Icons.south_west_rounded,
              size: 110,
              color: semanticColor.withValues(alpha: 0.06),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 6, left: 4, right: 4),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start, // Tepeden başla
                  children: txs.map((tx) => _buildMiniCard(context, tx, symbol, rates, customCategories, isLeft: isIncome)).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniCard(
    BuildContext context,
    TransactionRecord tx,
    String symbol,
    List<ExchangeRate> rates,
    List<CustomCategory> customCategories, {
    required bool isLeft,
  }) {
    final isIncome = tx.isIncome;
    final Color semanticColor = isIncome ? AppColors.getIncome(context) : AppColors.getExpense(context);
    final Color categoryColor = CategoryUtils.getCategoryColor(
      categoryId: tx.categoryId,
      customCategories: customCategories,
    );
    final IconData categoryIcon = CategoryUtils.getCategoryIcon(
      categoryId: tx.categoryId,
      customCategories: customCategories,
      iconCode: tx.iconCode,
    );
    
    final l10n = AppLocalizations.of(context)!;
    final String displayTitle = CategoryUtils.getCategoryName(
      categoryId: tx.categoryId,
      context: context,
      customCategories: customCategories,
      fallbackTitle: tx.title,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 3),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: isLeft ? Alignment.centerRight : Alignment.centerLeft,
          end: isLeft ? Alignment.centerLeft : Alignment.centerRight,
          colors: [categoryColor.withValues(alpha: 0.12), Colors.transparent], // Daha canlı gradyan
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: categoryColor.withValues(alpha: 0.05), width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: isLeft ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isLeft) _buildIcon(context, categoryIcon, categoryColor),
          if (!isLeft) const SizedBox(width: 5),
          
          if (isLeft) _buildDateText(tx, isLeft, l10n, context),
          
          Expanded(
            child: Column(
              crossAxisAlignment: isLeft ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayTitle,
                  style: TextStyle(
                    fontSize: 8, 
                    fontWeight: FontWeight.w800, 
                    letterSpacing: -0.2,
                    color: AppColors.getTextPrimary(context), // Daha net başlık
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  CurrencyUtils.formatAmount(tx.effectiveAmount, currencySymbol: tx.currency ?? '₺'),
                  style: TextStyle(
                    fontSize: 8, 
                    fontWeight: FontWeight.w900, 
                    color: semanticColor.withValues(alpha: 0.95) // Tam doygunluğa yakın tutar
                  ),
                ),
              ],
            ),
          ),
          
          if (!isLeft) _buildDateText(tx, isLeft, l10n, context),
          if (isLeft) const SizedBox(width: 5),
          if (isLeft) _buildIcon(context, categoryIcon, categoryColor),
        ],
      ),
    );
  }

  Widget _buildDateText(TransactionRecord tx, bool isLeft, AppLocalizations l10n, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: isLeft ? 0 : 5, right: isLeft ? 5 : 0),
      child: Text(
        _formatSmartDate(tx.updatedAt, l10n), // EKlenme zamanını (updatedAt) kullan
        style: TextStyle(
          fontSize: 6, 
          color: AppColors.getTextSecondary(context).withValues(alpha: 0.5), 
          fontWeight: FontWeight.w700
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context, IconData icon, Color color) {
    return Container(
      width: 17, height: 17,
      decoration: BoxDecoration(
        color: AppColors.getAccentDeep(context, color), 
        borderRadius: BorderRadius.circular(5),
      ),
      child: Icon(icon, size: 9, color: Colors.white),
    );
  }


  String _formatSmartDate(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    
    // DST differences are avoided by converting local dates to midnight UTC before checking difference in days
    final todayUtc = DateTime.utc(now.year, now.month, now.day);
    final txDateUtc = DateTime.utc(date.year, date.month, date.day);
    final diff = todayUtc.difference(txDateUtc).inDays;
    
    final timeStr = DateFormat('HH:mm').format(date);

    if (diff == 0) {
      return '${l10n.today} $timeStr';
    } else if (diff == 1) {
      return '${l10n.yesterday} $timeStr';
    } else if (diff <= 7) {
      return '${l10n.daysAgo(diff)}, $timeStr';
    } else if (diff <= 30) {
      final weeks = (diff / 7).floor();
      return '${l10n.weeksAgo(weeks)}, $timeStr';
    } else {
      final months = (diff / 30).floor();
      return l10n.monthsAgo(months);
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, color: AppColors.getTextSecondary(context).withValues(alpha: 0.15), size: 48),
          const SizedBox(height: 12),
          Text(
            l10n.historyEmpty,
            style: TextStyle(
              color: AppColors.getTextSecondary(context).withValues(alpha: 0.5),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
