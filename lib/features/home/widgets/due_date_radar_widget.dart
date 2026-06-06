import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_widget.dart';
import '../../../core/providers/db_providers.dart';
import '../../../core/database/models/transaction_record.dart';
import '../../../core/database/models/custom_category.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/category_utils.dart';
import '../../../core/theme/app_constants.dart';
import '../../../core/utils/string_utils.dart';
import '../../../l10n/app_localizations.dart';

final upcomingTransactionsProvider = Provider.family<List<TransactionRecord>, String?>((ref, selectedVaultId) {
  final transactions = ref.watch(allTransactionsProvider);
  
  List<TransactionRecord> vaultFilteredTxs = transactions;
  if (selectedVaultId != null && selectedVaultId.startsWith('v_')) {
    final filterVaultId = int.tryParse(selectedVaultId.replaceFirst('v_', ''));
    if (filterVaultId != null) {
      vaultFilteredTxs = transactions.where((tx) => tx.vaultIds.contains(filterVaultId)).toList();
    }
  }

  return _getUpcomingItems(vaultFilteredTxs);
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
                    color: tx.isIncome ? Colors.green.withValues(alpha: 0.8) : Colors.orange.withValues(alpha: 0.8)
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
    return Container(
      width: 18, height: 18,
      decoration: BoxDecoration(
        color: AppColors.getAccentDeep(context, color), 
        borderRadius: BorderRadius.circular(5),
      ),
      child: Icon(
        CategoryUtils.getCategoryIcon(
          categoryId: tx.categoryId,
          customCategories: customCategories,
          iconCode: tx.iconCode,
        ),
        size: 9,
        color: Colors.white,
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

List<TransactionRecord> _getUpcomingItems(List<TransactionRecord> transactions) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final limit = today.add(const Duration(days: 365));
  
  final List<TransactionRecord> projectedItems = [];

  for (var tx in transactions) {
    if (tx.isArchived) continue;

    // 1. Tek Seferlik İşlemler
    if (tx.periodType == 0) {
      if (tx.date.isAfter(today.subtract(const Duration(hours: 1))) && tx.date.isBefore(limit)) {
        projectedItems.add(tx);
      }
      continue;
    }

    // 2. Periyodik İşlemler (Projeksiyon)
    // ÖNCELİK: recurrenceDate (Çapa Tarihi). Yoksa normal tarihi kullan.
    DateTime anchorDate = tx.recurrenceDate ?? tx.date;
    DateTime currentOccurrence = DateTime(anchorDate.year, anchorDate.month, anchorDate.day, anchorDate.hour, anchorDate.minute);
    
    // Başlangıç tarihini bugüne veya en yakın gelecekteki durağına çek
    if (currentOccurrence.isBefore(today)) {
      while (currentOccurrence.isBefore(today)) {
        currentOccurrence = _getNextOccurrence(currentOccurrence, tx.periodType);
        if (currentOccurrence.isAfter(limit.add(const Duration(days: 3650)))) break;
      }
    }

    // 1 Yıllık pencere içindeki tüm tekrarları ekle
    int occurrencesProjected = 0;
    
    // Toplam limit hesabı:
    int? maxOccurrences;
    if (tx.remainingInstallments != null && tx.remainingInstallments! > 0) {
      maxOccurrences = tx.remainingInstallments;
    } else if (tx.recurrenceDuration != null && tx.recurrenceDuration! > 0) {
      DateTime pastOccurrence = DateTime(anchorDate.year, anchorDate.month, anchorDate.day, anchorDate.hour, anchorDate.minute);
      int passedCount = 0;
      while (pastOccurrence.isBefore(today)) {
        pastOccurrence = _getNextOccurrence(pastOccurrence, tx.periodType);
        passedCount++;
      }
      maxOccurrences = math.max(0, tx.recurrenceDuration! - (passedCount - 1));
    }

    while (currentOccurrence.isBefore(limit)) {
      if (maxOccurrences != null && occurrencesProjected >= maxOccurrences) break;

      final projectedTx = TransactionRecord()
        ..id = tx.id
        ..title = tx.title
        ..amount = tx.amount
        ..minAmount = tx.minAmount
        ..maxAmount = tx.maxAmount
        ..isIncome = tx.isIncome
        ..categoryId = tx.categoryId
        ..iconCode = tx.iconCode
        ..currency = tx.currency
        ..periodType = tx.periodType
        ..date = currentOccurrence;
        
      projectedItems.add(projectedTx);
      
      currentOccurrence = _getNextOccurrence(currentOccurrence, tx.periodType);
      occurrencesProjected++;
      if (occurrencesProjected > 100) break;
    }
  }

  return projectedItems..sort((a, b) => a.date.compareTo(b.date));
}

DateTime _getNextOccurrence(DateTime current, int periodType) {
  if (periodType == 250) {
    int addDays = 1;
    if (current.weekday == DateTime.friday) {
      addDays = 3;
    } else if (current.weekday == DateTime.saturday) {
      addDays = 2;
    }
    return current.add(Duration(days: addDays));
  } else if (periodType == 251) {
    int addDays = 1;
    if (current.weekday == DateTime.sunday) {
      addDays = 6;
    } else if (current.weekday >= DateTime.monday && current.weekday <= DateTime.friday) {
      addDays = DateTime.saturday - current.weekday;
    }
    return current.add(Duration(days: addDays));
  } else {
    final unit = periodType ~/ 100;
    final interval = periodType % 100;
    if (interval > 0) {
      switch (unit) {
        case 1:
          return current.add(Duration(days: interval));
        case 2:
          return current.add(Duration(days: interval * 7));
        case 3:
          return DateTime(current.year, current.month + interval, current.day, current.hour, current.minute);
        case 4:
          return DateTime(current.year + interval, current.month, current.day, current.hour, current.minute);
      }
    }
  }
  return current.add(const Duration(days: 30));
}
