import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dashboard_widget.dart';
import '../../../core/providers/db_providers.dart';
import '../../../core/database/models/transaction_record.dart';
import '../../../core/database/models/exchange_rate.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../shared/widgets/precision_mini_segmented_control.dart';
import '../../../l10n/app_localizations.dart';
import '../../transactions/widgets/transaction_category_data.dart';
import '../../../core/utils/icon_utils.dart';
import '../../../core/theme/app_constants.dart';
import 'dart:math' as math;

class SpendingGiantsWidget extends ConsumerStatefulWidget {
  final DashboardWidgetSize size;
  const SpendingGiantsWidget({super.key, this.size = DashboardWidgetSize.large});

  @override
  ConsumerState<SpendingGiantsWidget> createState() => _SpendingGiantsWidgetState();
}

class _SpendingGiantsWidgetState extends ConsumerState<SpendingGiantsWidget> with SingleTickerProviderStateMixin {
  int _selectedFilterIndex = 1;
  late AnimationController _chartController;

  @override
  void initState() {
    super.initState();
    _chartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
  }

  @override
  void dispose() {
    _chartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final symbol = settings.currencySymbol;
    final rates = ref.watch(exchangeRatesProvider).value ?? [];
    final transactions = ref.watch(expenseTransactionsProvider);
    
    final periods = _getAnalysisPeriods();
    final currentTxs = transactions.where((tx) => tx.date.isAfter(periods['currentStart']!) && tx.date.isBefore(periods['currentEnd']!)).toList();
    final previousTxs = transactions.where((tx) => tx.date.isAfter(periods['prevStart']!) && tx.date.isBefore(periods['prevEnd']!)).toList();

    final giants = _getAnalyticGiants(currentTxs, previousTxs, symbol, rates);

    return Column(
      children: [
        Center(
          child: Transform.scale(
            scale: 0.75,
            child: PrecisionMiniSegmentedControl(
              items: const ['H', 'A', 'Y'],
              selectedIndex: _selectedFilterIndex,
              onChanged: (index) {
                setState(() => _selectedFilterIndex = index);
                _chartController.reset();
                _chartController.forward();
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: giants.isEmpty 
            ? _buildEmptyState() 
            : Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: AnimatedBuilder(
                          animation: _chartController,
                          builder: (context, child) {
                            return CustomPaint(
                              painter: _TripleOverlapPainter(
                                giants: giants,
                                animationValue: _chartController.value,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: giants.map((g) => _buildDetailItem(g, symbol)).toList(),
                    ),
                  ),
                ],
              ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(_AnalyticGiant g, String symbol) {
    final Color catColor = IconUtils.getColor(g.categoryId);
    final IconData catIcon = IconUtils.getIcon(g.categoryId);
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            catColor.withValues(alpha: 0.1),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          // Kategori İkonu (Renkli Kare İçinde)
          Container(
            width: 24, height: 24,
            decoration: BoxDecoration(
              color: catColor,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: catColor.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(catIcon, size: 12, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getLocalizedCategoryName(context, g.categoryId),
                  style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.2),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${CurrencyUtils.formatAmount(g.amount)}$symbol',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: catColor.withValues(alpha: 0.9)),
                ),
              ],
            ),
          ),
          if (g.isNew)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.getIncome(context).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'NEW',
                style: TextStyle(fontSize: 5, fontWeight: FontWeight.w900, color: AppColors.getIncome(context)),
              ),
            ),
        ],
      ),
    );
  }

  Map<String, DateTime> _getAnalysisPeriods() {
    final now = DateTime.now();
    DateTime currentStart, currentEnd, prevStart, prevEnd;

    switch (_selectedFilterIndex) {
      case 0: // Hafta
        currentStart = now.subtract(const Duration(days: 7));
        currentEnd = now;
        prevStart = now.subtract(const Duration(days: 14));
        prevEnd = now.subtract(const Duration(days: 7));
        break;
      case 2: // Yıl
        currentStart = DateTime(now.year - 1, now.month, now.day);
        currentEnd = now;
        prevStart = DateTime(now.year - 2, now.month, now.day);
        prevEnd = DateTime(now.year - 1, now.month, now.day);
        break;
      default: // Ay (Varsayılan)
        currentStart = DateTime(now.year, now.month - 1, now.day);
        currentEnd = now;
        prevStart = DateTime(now.year, now.month - 2, now.day);
        prevEnd = DateTime(now.year, now.month - 1, now.day);
    }
    return {'currentStart': currentStart, 'currentEnd': currentEnd, 'prevStart': prevStart, 'prevEnd': prevEnd};
  }

  List<_AnalyticGiant> _getAnalyticGiants(List<TransactionRecord> currentTxs, List<TransactionRecord> prevTxs, String symbol, List<ExchangeRate> rates) {
    if (currentTxs.isEmpty) return [];
    final Map<String, double> currentSums = {};
    double currentTotal = 0;
    for (final tx in currentTxs) {
      final val = tx.getConvertedAmount(symbol, rates);
      currentSums[tx.categoryId ?? 'Diğer'] = (currentSums[tx.categoryId ?? 'Diğer'] ?? 0) + val;
      currentTotal += val;
    }
    final Map<String, double> prevSums = {};
    double prevTotal = 0;
    for (final tx in prevTxs) {
      final val = tx.getConvertedAmount(symbol, rates);
      prevSums[tx.categoryId ?? 'Diğer'] = (prevSums[tx.categoryId ?? 'Diğer'] ?? 0) + val;
      prevTotal += val;
    }
    final List<_AnalyticGiant> giants = [];
    final sortedCategories = currentSums.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    for (final entry in sortedCategories.take(5)) {
      final catId = entry.key;
      final currentAmount = entry.value;
      final prevAmount = prevSums[catId] ?? 0;
      giants.add(_AnalyticGiant(
        categoryId: catId, amount: currentAmount,
        percentage: currentTotal > 0 ? (currentAmount / currentTotal) * 100 : 0,
        prevPercentage: prevTotal > 0 ? (prevAmount / prevTotal) * 100 : 0,
        isNew: prevAmount == 0,
      ));
    }
    return giants;
  }

  String _getLocalizedCategoryName(BuildContext context, String? categoryId) {
    final l10n = AppLocalizations.of(context)!;
    if (categoryId == null || categoryId == 'Diğer') return l10n.other;
    final String targetId = categoryId.toLowerCase();
    final categories = TransactionCategoryData.getExpenseCategories(context, l10n);
    for (var cat in categories) {
      if ((cat['id'] as String).toLowerCase() == targetId) return cat['name'] as String;
      if (cat['subModels'] != null) {
        for (var sub in (cat['subModels'] as List)) {
          if ((sub['id'] as String).toLowerCase() == targetId) return sub['name'] as String;
        }
      }
    }
    return categoryId;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Icon(Icons.blur_circular_rounded, color: Colors.white.withValues(alpha: 0.05), size: 40),
    );
  }
}

class _AnalyticGiant {
  final String? categoryId;
  final double amount;
  final double percentage;
  final double prevPercentage;
  final bool isNew;
  _AnalyticGiant({this.categoryId, required this.amount, required this.percentage, required this.prevPercentage, required this.isNew});
}
class _TripleOverlapPainter extends CustomPainter {
  final List<_AnalyticGiant> giants;
  final double animationValue;

  _TripleOverlapPainter({required this.giants, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = (math.min(size.width, size.height) / 2) - 8;
    
    // Temel değerler
    double currentBaseStroke = 11.5;
    double currentBaseSpacing = 5.0;
    double currentBaseCore = 3.5;

    for (int i = 0; i < giants.length; i++) {
      final g = giants[i];
      
      // Dinamik daraltma (Merkeze gittikçe incelme)
      final double sWidth = (currentBaseStroke - (i * 1.2)).clamp(4.0, 12.0);
      final double cWidth = (currentBaseCore - (i * 0.4)).clamp(1.5, 4.0);
      final double sSpacing = (currentBaseSpacing - (i * 0.4)).clamp(2.0, 6.0);
      
      // Yarıçap hesaplama
      double currentRadius = maxRadius;
      for (int j = 0; j < i; j++) {
        currentRadius -= (currentBaseStroke - (j * 1.2)).clamp(4.0, 12.0) + (currentBaseSpacing - (j * 0.4)).clamp(2.0, 6.0);
      }
      
      if (currentRadius < 10) break; // Çok küçükse çizme

      final Color catColor = IconUtils.getColor(g.categoryId);
      final Rect arcRect = Rect.fromCircle(center: center, radius: currentRadius);
      
      // Dinamik Gap (Her halkada aynı boşluk mesafesi)
      final double gapAngle = 4.0 / currentRadius;

      // --- YARDIMCI ÇİZİM FONKSİYONU ---
      void drawSegmentedArc(double percentage, Paint paint) {
        final double totalSweep = (percentage / 100) * 2 * math.pi * animationValue;
        for (int q = 0; q < 4; q++) {
          final double qStart = q * (math.pi / 2);
          if (totalSweep > qStart) {
            final double startAngle = -math.pi / 2 + qStart + gapAngle;
            double sweepAngle = math.min(totalSweep - qStart, math.pi / 2) - (gapAngle * 2);
            if (sweepAngle > 0) {
              canvas.drawArc(arcRect, startAngle, sweepAngle, false, paint);
            }
          }
        }
      }

      // 1. KATMAN: ZEMİN
      final trackPaint = Paint()
        ..color = catColor.withValues(alpha: 0.05)
        ..style = PaintingStyle.stroke
        ..strokeWidth = sWidth
        ..strokeCap = StrokeCap.round;
      drawSegmentedArc(100.0, trackPaint);

      // 2. KATMAN: ŞU ANKİ DÖNEM
      final currentPaint = Paint()
        ..color = catColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = sWidth
        ..strokeCap = StrokeCap.round;
      drawSegmentedArc(g.percentage, currentPaint);

      // 3. KATMAN: GEÇEN DÖNEM (PARLAK ÇEKİRDEK)
      final prevPaint = Paint()
        ..color = catColor.withValues(alpha: 1.0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = cWidth
        ..strokeCap = StrokeCap.round;
      drawSegmentedArc(g.prevPercentage, prevPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TripleOverlapPainter oldDelegate) => true;
}
