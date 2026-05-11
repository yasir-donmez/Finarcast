import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dashboard_widget.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/db_providers.dart';
import '../../../core/database/models/transaction_record.dart';
import '../../../core/database/models/exchange_rate.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/theme/app_constants.dart';
import '../../../core/utils/icon_utils.dart';
import '../../../l10n/app_localizations.dart';
import '../../transactions/widgets/transaction_category_data.dart';

class TimelineActivityWidget extends ConsumerWidget {
  final DashboardWidgetSize size;
  const TimelineActivityWidget({super.key, this.size = DashboardWidgetSize.large});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(allTransactionsProvider);
    final rates = ref.watch(exchangeRatesProvider).value ?? [];
    final settings = ref.watch(settingsProvider);
    final symbol = settings.currencySymbol;
    
    // EKLEME SIRASINA GÖRE SIRALA (En son eklenen en üstte)
    final sortedTxs = transactions.toList()..sort((a, b) => b.id.compareTo(a.id));
    
    // Veri Saklama Süresine Göre Filtrele
    final now = DateTime.now();
    final retentionDays = settings.dataRetentionDays;
    final filteredTxs = sortedTxs.where((tx) {
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SOL: Gelirler
        Expanded(
          child: _buildColumn(context, incomeTxs, symbol, rates, true),
        ),
        
        const SizedBox(width: 8),
        
        // SAĞ: Giderler
        Expanded(
          child: _buildColumn(context, expenseTxs, symbol, rates, false),
        ),
      ],
    );
  }

  Widget _buildColumn(BuildContext context, List<TransactionRecord> txs, String symbol, List<ExchangeRate> rates, bool isIncome) {
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
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 6, left: 4, right: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start, // Tepeden başla
              children: txs.map((tx) => _buildMiniCard(context, tx, symbol, rates, isLeft: isIncome)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniCard(BuildContext context, TransactionRecord tx, String symbol, List<ExchangeRate> rates, {required bool isLeft}) {
    final isIncome = tx.isIncome;
    final Color semanticColor = isIncome ? AppColors.getIncome(context) : AppColors.getExpense(context);
    final Color categoryColor = IconUtils.getColor(tx.iconCode ?? tx.categoryId);
    final IconData categoryIcon = IconUtils.getIcon(tx.iconCode ?? tx.categoryId);
    
    final l10n = AppLocalizations.of(context)!;
    final categoryInfo = _getCategoryInfo(context, l10n, tx.categoryId, isIncome);
    final String subName = categoryInfo['sub'] ?? '';
    final String parentName = categoryInfo['parent'] ?? '';
    final String cleanTitle = tx.title.trim();
    
    String displayTitle;
    if (cleanTitle.isNotEmpty && cleanTitle.toLowerCase() != subName.toLowerCase() && cleanTitle.toLowerCase() != parentName.toLowerCase()) {
      displayTitle = cleanTitle;
    } else if (subName.isNotEmpty) {
      displayTitle = subName;
    } else {
      displayTitle = parentName;
    }

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
          if (!isLeft) _buildIcon(categoryIcon, categoryColor),
          if (!isLeft) const SizedBox(width: 5),
          
          if (isLeft) _buildDateText(tx, isLeft, l10n),
          
          Expanded(
            child: Column(
              crossAxisAlignment: isLeft ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayTitle,
                  style: const TextStyle(
                    fontSize: 8, 
                    fontWeight: FontWeight.w800, 
                    letterSpacing: -0.2,
                    color: Colors.white, // Daha net başlık
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
          
          if (!isLeft) _buildDateText(tx, isLeft, l10n),
          if (isLeft) const SizedBox(width: 5),
          if (isLeft) _buildIcon(categoryIcon, categoryColor),
        ],
      ),
    );
  }

  Widget _buildDateText(TransactionRecord tx, bool isLeft, AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.only(left: isLeft ? 0 : 5, right: isLeft ? 5 : 0),
      child: Text(
        _formatSmartDate(tx.updatedAt, l10n), // EKlenme zamanını (updatedAt) kullan
        style: TextStyle(
          fontSize: 6, 
          color: Colors.white.withValues(alpha: 0.25), 
          fontWeight: FontWeight.w700
        ),
      ),
    );
  }

  Widget _buildIcon(IconData icon, Color color) {
    return Container(
      width: 17, height: 17,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
      child: Icon(icon, size: 9, color: Colors.white),
    );
  }

  Map<String, String> _getCategoryInfo(BuildContext context, AppLocalizations l10n, String? categoryId, bool isIncome) {
    if (categoryId == null) return {'parent': l10n.other, 'sub': l10n.other};
    final String targetId = categoryId.toLowerCase();
    
    final categories = isIncome 
        ? TransactionCategoryData.getIncomeCategories(context, l10n)
        : TransactionCategoryData.getExpenseCategories(context, l10n);
        
    for (var cat in categories) {
      final String parentName = cat['name'] as String;
      if ((cat['id'] as String).toLowerCase() == targetId) return {'parent': parentName, 'sub': parentName};
      
      if (cat['subModels'] != null) {
        for (var sub in (cat['subModels'] as List)) {
          if ((sub['id'] as String).toLowerCase() == targetId) {
            return {'parent': parentName, 'sub': sub['name'] as String};
          }
        }
      }
    }
    
    return {'parent': categoryId, 'sub': categoryId};
  }


  String _formatSmartDate(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final txDate = DateTime(date.year, date.month, date.day);
    final diff = today.difference(txDate).inDays;
    
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
          Icon(Icons.history_rounded, color: Colors.white.withValues(alpha: 0.05), size: 48),
          const SizedBox(height: 12),
          Text(
            l10n.historyEmpty,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.15),
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
