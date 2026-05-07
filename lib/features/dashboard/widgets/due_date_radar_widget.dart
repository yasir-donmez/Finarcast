import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dashboard_widget.dart';
import '../../../core/providers/db_providers.dart';
import '../../../core/database/models/transaction_record.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/icon_utils.dart';

class DueDateRadarWidget extends ConsumerStatefulWidget {
  final DashboardWidgetSize size;
  const DueDateRadarWidget({super.key, this.size = DashboardWidgetSize.large});

  @override
  ConsumerState<DueDateRadarWidget> createState() => _DueDateRadarWidgetState();
}

class _DueDateRadarWidgetState extends ConsumerState<DueDateRadarWidget> {
  final Set<String> _expandedGroups = {};
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(allTransactionsProvider);
    final items = _getUpcomingItems(transactions);

    if (items.isEmpty) return _buildEmptyState(context);

    // Akıllı Gruplama Mantığı
    final Map<String, List<TransactionRecord>> temporalGroups = {};
    final Map<String, DateTime> groupDateRef = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (var tx in items) {
      final txDate = DateTime(tx.date.year, tx.date.month, tx.date.day);
      final diff = txDate.difference(today).inDays;
      String groupKey;
      
      if (diff <= 7) {
        groupKey = 'day_$diff';
      } else if (diff <= 30) {
        final weekNum = (diff / 7).floor();
        groupKey = 'week_$weekNum';
      } else {
        groupKey = 'month_${txDate.month}_${txDate.year}';
      }
      
      temporalGroups.putIfAbsent(groupKey, () => []).add(tx);
      if (!groupDateRef.containsKey(groupKey)) {
        groupDateRef[groupKey] = txDate;
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
        final diff = refDate.difference(today).inDays;
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
        );
      },
    );
  }

  Widget _buildTemporalGroup(DateTime date, List<TransactionRecord> groupItems, int diff, String key, bool isExpanded, VoidCallback onToggle) {
    final incomeItems = groupItems.where((tx) => tx.isIncome).toList();
    final expenseItems = groupItems.where((tx) => !tx.isIncome).toList();
    
    String railLabel;
    if (diff == 0) {
      railLabel = 'BUGÜN';
    } else if (diff == 1) {
      railLabel = 'YARIN';
    } else if (diff <= 7) {
      final dayName = DateFormat('EEEE', 'tr_TR').format(date).toUpperCase();
      railLabel = '$diff GÜN - $dayName';
    } else if (diff <= 30) {
      final weekNum = (diff / 7).ceil();
      railLabel = '$weekNum HAFTA SONRA';
    } else {
      railLabel = DateFormat('MMMM yyyy', 'tr_TR').format(date).toUpperCase();
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
                Container(width: 20, height: 0.5, color: Colors.white.withValues(alpha: 0.05)),
                const SizedBox(width: 8),
                // İkon Animasyonu
                AnimatedRotation(
                  turns: isExpanded ? 0.25 : 0, // 90 derece dön
                  duration: const Duration(milliseconds: 400),
                  child: Icon(
                    Icons.keyboard_arrow_right_rounded,
                    size: 12,
                    color: Colors.white.withValues(alpha: isExpanded ? 0.5 : 0.2),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  railLabel,
                  style: TextStyle(
                    fontSize: 7, 
                    fontWeight: FontWeight.w900, 
                    color: Colors.white.withValues(alpha: isExpanded ? 0.4 : 0.2), 
                    letterSpacing: 1.0
                  ),
                ),
                if (!isExpanded) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${groupItems.length}',
                      style: TextStyle(fontSize: 6, fontWeight: FontWeight.w900, color: Colors.white.withValues(alpha: 0.3)),
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                Container(width: 20, height: 0.5, color: Colors.white.withValues(alpha: 0.05)),
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
                        Expanded(child: incomeTx != null ? _buildMiniCard(incomeTx, isLeft: true, showDetailDate: diff > 7) : const SizedBox()),
                        SizedBox(
                          width: 16,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(width: 1, color: Colors.white.withValues(alpha: 0.03)),
                              Container(
                                width: 4, height: 4,
                                decoration: BoxDecoration(
                                  color: (incomeTx != null || expenseTx != null) 
                                      ? (expenseTx != null ? Colors.orange : Colors.green) 
                                      : Colors.white.withValues(alpha: 0.05),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(child: expenseTx != null ? _buildMiniCard(expenseTx, isLeft: false, showDetailDate: diff > 7) : const SizedBox()),
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

  Widget _buildMiniCard(TransactionRecord tx, {required bool isLeft, bool showDetailDate = false}) {
    final Color color = IconUtils.getColor(tx.iconCode ?? tx.categoryId);
    
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
          if (!isLeft) _buildIcon(tx, color),
          if (!isLeft) const SizedBox(width: 6),
          
          if (isLeft && showDetailDate) _buildDateText(tx, isLeft),
          
          Expanded(
            child: Column(
              crossAxisAlignment: isLeft ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _getSmartTitle(tx),
                  style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${CurrencyUtils.formatAmount(tx.effectiveAmount)}${tx.currency ?? '₺'}',
                  style: TextStyle(
                    fontSize: 8.5, 
                    fontWeight: FontWeight.w900, 
                    color: tx.isIncome ? Colors.green.withValues(alpha: 0.8) : Colors.orange.withValues(alpha: 0.8)
                  ),
                ),
              ],
            ),
          ),
          
          if (!isLeft && showDetailDate) _buildDateText(tx, isLeft),
          if (isLeft) const SizedBox(width: 6),
          if (isLeft) _buildIcon(tx, color),
        ],
      ),
    );
  }

  Widget _buildDateText(TransactionRecord tx, bool isLeft) {
    return Padding(
      padding: EdgeInsets.only(left: isLeft ? 0 : 6, right: isLeft ? 6 : 0),
      child: Text(
        DateFormat('d MMM').format(tx.date),
        style: TextStyle(
          fontSize: 6.5, 
          color: Colors.white.withValues(alpha: 0.3), 
          fontWeight: FontWeight.w700
        ),
      ),
    );
  }

  Widget _buildIcon(TransactionRecord tx, Color color) {
    return Container(
      width: 18, height: 18,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
      child: Icon(IconUtils.getIcon(tx.iconCode ?? tx.categoryId), size: 9, color: Colors.white),
    );
  }

  String _getSmartTitle(TransactionRecord tx) {
    final String cleanTitle = tx.title.trim();
    if (cleanTitle.isNotEmpty) return cleanTitle;
    return tx.categoryId ?? 'İşlem';
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_note_rounded, color: Colors.white.withValues(alpha: 0.1), size: 24),
          const SizedBox(height: 6),
          Text(
            'Yakın zamanda planlı işlem yok',
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.2)),
          ),
        ],
      ),
    );
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
      // Eğer anchorDate gelecekse, olduğu gibi kalsın. 
      // Eğer anchorDate geçmişse, bugünden sonraki ilk durağına ilerlet.
      if (currentOccurrence.isBefore(today)) {
        while (currentOccurrence.isBefore(today)) {
          currentOccurrence = _getNextOccurrence(currentOccurrence, tx.periodType);
          if (currentOccurrence.isAfter(limit.add(const Duration(days: 3650)))) break;
        }
      }

      // 1 Yıllık pencere içindeki tüm tekrarları ekle
      int count = 0;
      while (currentOccurrence.isBefore(limit)) {
        // Klon oluşturarak farklı tarihlerle listeye ekle
        // Eğer bir "Kez" sınırı (recurrenceDuration) varsa ve dolmuşsa ekleme
        if (tx.recurrenceDuration != null && tx.recurrenceDuration! > 0) {
          // Burada basit bir "kaçıncı taksit" hesabı yapılabilir
          // Şimdilik ana mantığa odaklanalım
        }

        // Klon oluşturarak farklı tarihlerle listeye ekle
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
          ..date = currentOccurrence; // Projeksiyon tarihi
          
        projectedItems.add(projectedTx);
        
        currentOccurrence = _getNextOccurrence(currentOccurrence, tx.periodType);
        count++;
        if (count > 100) break; // Sonsuz döngü koruması
      }
    }

    return projectedItems..sort((a, b) => a.date.compareTo(b.date));
  }

  DateTime _getNextOccurrence(DateTime current, int periodType) {
    switch (periodType) {
      case 1: return current.add(const Duration(days: 7)); // Haftalık
      case 2: return DateTime(current.year, current.month + 1, current.day, current.hour, current.minute); // Aylık
      case 3: return DateTime(current.year + 1, current.month, current.day, current.hour, current.minute); // Yıllık
      case 4: return current.add(const Duration(days: 14));
      case 5: return current.add(const Duration(days: 21));
      case 6: return DateTime(current.year, current.month + 3, current.day, current.hour, current.minute); // 3 Ayda bir
      case 7: return DateTime(current.year, current.month + 6, current.day, current.hour, current.minute); // 6 Ayda bir
      case 8: return current.add(const Duration(days: 1)); // Günlük
      case 9: return current.add(const Duration(days: 2));
      case 10: return current.add(const Duration(days: 3));
      default: return current.add(const Duration(days: 30));
    }
  }
}
