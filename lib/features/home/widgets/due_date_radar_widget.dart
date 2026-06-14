import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_widget.dart';
import '../../../core/providers/db_providers.dart';
import '../../../core/database/models/transaction_record.dart';
import '../../../core/database/models/recurring_template.dart';
import '../../../core/database/models/custom_category.dart';
import '../../../core/domain/recurrence_engine.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/category_utils.dart';
import '../../../core/theme/app_constants.dart';
import '../../../core/utils/string_utils.dart';
import '../../../l10n/app_localizations.dart';

final upcomingTransactionsProvider = Provider.family<List<TransactionRecord>, String?>((ref, selectedVaultId) {
  final transactions = ref.watch(allTransactionsProvider);
  final templates = ref.watch(allTemplatesProvider);
  
  final projected = _getUpcomingItems(dbTransactions: transactions, templates: templates);

  if (selectedVaultId != null && selectedVaultId.startsWith('v_')) {
    final filterVaultId = int.tryParse(selectedVaultId.replaceFirst('v_', ''));
    if (filterVaultId != null) {
      return projected.where((tx) => tx.vaultId == filterVaultId).toList();
    }
  }

  return projected;
});

class DueDateRadarWidget extends ConsumerStatefulWidget {
  final HomeWidgetSize size;
  final String? selectedVaultId;
  const DueDateRadarWidget({super.key, this.size = HomeWidgetSize.large, this.selectedVaultId});

  @override
  ConsumerState<DueDateRadarWidget> createState() => _DueDateRadarWidgetState();
}

class _DueDateRadarWidgetState extends ConsumerState<DueDateRadarWidget> {
  final Set<String> _expandedGroups = {};
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(upcomingTransactionsProvider(widget.selectedVaultId));
    final customCategories = ref.watch(customCategoriesProvider);

    if (items.isEmpty) return _buildEmptyState(context);

    // Akıllı Gruplama Mantığı
    final Map<String, List<TransactionRecord>> temporalGroups = {};
    final Map<String, DateTime> groupDateRef = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayUtc = DateTime.utc(today.year, today.month, today.day);

    for (var tx in items) {
      final txDateUtc = DateTime.utc(tx.date.year, tx.date.month, tx.date.day);
      final diff = txDateUtc.difference(todayUtc).inDays;
      String groupKey;
      
      if (diff <= 7) {
        groupKey = 'day_$diff';
      } else if (diff <= 30) {
        final weekNum = (diff / 7).floor();
        groupKey = 'week_$weekNum';
      } else {
        groupKey = 'month_${tx.date.month}_${tx.date.year}';
      }
      
      temporalGroups.putIfAbsent(groupKey, () => []).add(tx);
      if (!groupDateRef.containsKey(groupKey)) {
        groupDateRef[groupKey] = tx.date;
      }

      // İLK SEFERDE: Yakın tarihli grupları otomatik genişlet
      if (!_initialized) {
        if (diff <= 30) {
          _expandedGroups.add(groupKey);
        }
      }
    }
    _initialized = true;

    final sortedGroupKeys = temporalGroups.keys.toList()..sort((a, b) {
      return groupDateRef[a]!.compareTo(groupDateRef[b]!);
    });

    return ListView.builder(
      padding: const EdgeInsets.only(top: 0, bottom: 12), // Üst boşluğu sıfırladım
      itemCount: sortedGroupKeys.length,
      itemBuilder: (context, index) {
        final key = sortedGroupKeys[index];
        final groupItems = temporalGroups[key]!;
        final refDate = groupDateRef[key]!;
        final refDateUtc = DateTime.utc(refDate.year, refDate.month, refDate.day);
        final diff = refDateUtc.difference(todayUtc).inDays;
        final isExpanded = _expandedGroups.contains(key);

        return _buildTemporalGroup(
          refDate, 
          groupItems, 
          diff, 
          key, 
          isExpanded,
          () => setState(() {
            if (_expandedGroups.contains(key)) {
              _expandedGroups.remove(key);
            } else {
              _expandedGroups.add(key);
            }
          }),
          customCategories,
        );
      },
    );
  }

  Widget _buildTemporalGroup(
    DateTime date,
    List<TransactionRecord> groupItems,
    int diff,
    String key,
    bool isExpanded,
    VoidCallback onToggle,
    List<CustomCategory> customCategories,
  ) {
    final incomeItems = groupItems.where((tx) => tx.isIncome).toList();
    final expenseItems = groupItems.where((tx) => !tx.isIncome).toList();
    
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    String railLabel;
    if (diff == 0) {
      railLabel = l10n.todayUpper;
    } else if (diff == 1) {
      railLabel = l10n.tomorrowUpper;
    } else if (diff <= 7) {
      final dayName = DateFormat('EEEE', locale).format(date).toSafeLocaleUpperCase(Localizations.localeOf(context).languageCode);
      railLabel = l10n.daysWithName(diff, dayName);
    } else if (diff <= 30) {
      final weekNum = (diff / 7).ceil();
      railLabel = l10n.weeksLater(weekNum);
    } else {
      railLabel = DateFormat('MMMM yyyy', locale).format(date).toSafeLocaleUpperCase(Localizations.localeOf(context).languageCode);
    }

    return Column(
      children: [
        // Merkezi Ray Başlığı (Tıklanabilir Akordeon)
        GestureDetector(
          onTap: onToggle,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6), // Boşluğu daralttım
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 20, height: 0.5, color: AppColors.getTextSecondary(context).withValues(alpha: 0.15)),
                const SizedBox(width: 8),
                // İkon Animasyonu
                AnimatedRotation(
                  turns: isExpanded ? 0.25 : 0, // 90 derece dön
                  duration: const Duration(milliseconds: 400),
                  child: Icon(
                    Icons.keyboard_arrow_right_rounded,
                    size: 12,
                    color: AppColors.getTextSecondary(context).withValues(alpha: isExpanded ? 0.6 : 0.3),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  railLabel,
                  style: TextStyle(
                    fontSize: 7, 
                    fontWeight: FontWeight.w900, 
                    color: AppColors.getTextSecondary(context).withValues(alpha: isExpanded ? 0.7 : 0.4), 
                    letterSpacing: 1.0
                  ),
                ),
                if (!isExpanded) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.getTextSecondary(context).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${groupItems.length}',
                      style: TextStyle(fontSize: 6, fontWeight: FontWeight.w900, color: AppColors.getTextSecondary(context).withValues(alpha: 0.7)),
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                Container(width: 20, height: 0.5, color: AppColors.getTextSecondary(context).withValues(alpha: 0.15)),
              ],
            ),
          ),
        ),
        
        // Akıllı Animasyonlu İçerik
        AnimatedSize(
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
          alignment: Alignment.topCenter,
          child: isExpanded 
            ? Column(
                children: List.generate(math.max(incomeItems.length, expenseItems.length), (index) {
                  final incomeTx = index < incomeItems.length ? incomeItems[index] : null;
                  final expenseTx = index < expenseItems.length ? expenseItems[index] : null;
                  
                  return IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(child: incomeTx != null ? _buildMiniCard(context, incomeTx, isLeft: true, showDetailDate: diff > 7, customCategories: customCategories) : const SizedBox()),
                        SizedBox(
                          width: 16,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(width: 1, color: AppColors.getTextSecondary(context).withValues(alpha: 0.15)),
                              Container(
                                width: 4, height: 4,
                                decoration: BoxDecoration(
                                  color: (incomeTx != null || expenseTx != null) 
                                      ? (expenseTx != null ? Colors.orange : Colors.green) 
                                      : AppColors.getTextSecondary(context).withValues(alpha: 0.3),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(child: expenseTx != null ? _buildMiniCard(context, expenseTx, isLeft: false, showDetailDate: diff > 7, customCategories: customCategories) : const SizedBox()),
                      ],
                    ),
                  );
                }),
              )
            : const SizedBox(width: double.infinity, height: 0),
        ),
        
        if (!isExpanded) const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildMiniCard(
    BuildContext context,
    TransactionRecord tx, {
    required bool isLeft,
    bool showDetailDate = false,
    required List<CustomCategory> customCategories,
  }) {
    final Color color = CategoryUtils.getCategoryColor(
      categoryId: tx.categoryId,
      customCategories: customCategories,
    );
    
    return Container(
      margin: EdgeInsets.only(left: isLeft ? 4 : 0, right: isLeft ? 0 : 4, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: isLeft ? Alignment.centerRight : Alignment.centerLeft,
          end: isLeft ? Alignment.centerLeft : Alignment.centerRight,
          colors: [color.withValues(alpha: 0.1), Colors.transparent],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.04), width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: isLeft ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isLeft) _buildIcon(context, tx, color, customCategories),
          if (!isLeft) const SizedBox(width: 6),
          
          if (isLeft && showDetailDate) _buildDateText(context, tx, isLeft),
          
          Expanded(
            child: Column(
              crossAxisAlignment: isLeft ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _getSmartTitle(tx, customCategories),
                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: AppColors.getTextPrimary(context)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  CurrencyUtils.formatAmount(tx.effectiveAmount, currencySymbol: tx.currency ?? '₺'),
                  style: TextStyle(
                    fontSize: 8.5, 
                    fontWeight: FontWeight.w900, 
                    color: tx.targetVaultId != null
                        ? Colors.blueGrey
                        : (tx.isIncome ? AppColors.getIncome(context) : AppColors.getExpense(context)),
                  ),
                ),
              ],
            ),
          ),
          
          if (!isLeft && showDetailDate) _buildDateText(context, tx, isLeft),
          if (isLeft) const SizedBox(width: 6),
          if (isLeft) _buildIcon(context, tx, color, customCategories),
        ],
      ),
    );
  }

  Widget _buildDateText(BuildContext context, TransactionRecord tx, bool isLeft) {
    return Padding(
      padding: EdgeInsets.only(left: isLeft ? 0 : 6, right: isLeft ? 6 : 0),
      child: Text(
        DateFormat('d MMM').format(tx.date),
        style: TextStyle(
          fontSize: 6.5, 
          color: AppColors.getTextSecondary(context).withValues(alpha: 0.6), 
          fontWeight: FontWeight.w700
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context, TransactionRecord tx, Color color, List<CustomCategory> customCategories) {
    final accentColor = AppColors.getAccentDeep(context, color);
    return Container(
      width: 18, height: 18,
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.15), 
        borderRadius: BorderRadius.circular(5),
      ),
      child: Icon(
        CategoryUtils.getCategoryIcon(
          categoryId: tx.categoryId,
          customCategories: customCategories,
          iconCode: tx.iconCode,
        ),
        size: 9,
        color: accentColor,
      ),
    );
  }

  String _getSmartTitle(TransactionRecord tx, List<CustomCategory> customCategories) {
    return CategoryUtils.getCategoryName(
      categoryId: tx.categoryId,
      context: context,
      customCategories: customCategories,
      fallbackTitle: tx.title,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_available_rounded, color: AppColors.getTextSecondary(context).withValues(alpha: 0.15), size: 48),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.upcomingPaymentsNotFound,
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

List<TransactionRecord> _getUpcomingItems({
  required List<TransactionRecord> dbTransactions,
  required List<RecurringTemplate> templates,
}) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final limit = today.add(const Duration(days: 365));
  
  final List<TransactionRecord> projectedItems = [];

  // 1. Veritabanındaki gelecekteki işlemleri filtrele
  for (var tx in dbTransactions) {
    if (tx.isArchived) continue;
    if (tx.status == 2) continue; // Skipped olanları gösterme

    final isFuture = tx.date.isAfter(today.subtract(const Duration(hours: 1)));
    if (isFuture && tx.date.isBefore(limit)) {
      projectedItems.add(tx);
    }
  }

  // Veritabanındaki mevcut tekrarlı işlem anahtarlarını çıkaralım
  final Set<String> existingOccurrenceKeys = dbTransactions
      .where((tx) => tx.templateId != null && tx.occurrenceKey.isNotEmpty)
      .map((tx) => tx.occurrenceKey)
      .toSet();

  // 2. Aktif şablonlardan geleceğe yönelik projeksiyon yap
  for (var template in templates) {
    if (template.isPaused || template.isArchived) continue;
    if (template.periodType == 0) continue;

    final dates = RecurrenceEngine.occurrenceDates(
      template.recurrenceRule,
      limit,
    );

    for (final date in dates) {
      if (date.isBefore(today) || date.isAtSameMomentAs(today)) {
        continue;
      }

      final idStr = template.remoteId ?? template.id.toString();
      final yyyyMMdd = '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
      final occurrenceKey = '${idStr}_$yyyyMMdd';

      if (existingOccurrenceKeys.contains(occurrenceKey)) {
        continue;
      }

      final installment = RecurrenceEngine.installmentNumber(template.recurrenceRule, date);

      final projectedTx = TransactionRecord()
        ..templateId = template.id
        ..occurrenceKey = occurrenceKey
        ..title = template.title
        ..amount = template.amount
        ..minAmount = template.minAmount
        ..maxAmount = template.maxAmount
        ..isIncome = template.isIncome
        ..categoryId = template.categoryId
        ..iconCode = template.iconCode
        ..currency = template.currency
        ..date = DateTime(date.year, date.month, date.day, template.notificationHour, template.notificationMinute)
        ..occurrenceDate = date
        ..installmentNumber = installment
        ..totalInstallments = template.totalInstallments
        ..vaultId = template.vaultId;

      projectedItems.add(projectedTx);
    }
  }

  return projectedItems..sort((a, b) => a.date.compareTo(b.date));
}
