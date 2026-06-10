import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_widget.dart';
import '../../../core/providers/db_providers.dart';
import '../../../core/database/models/transaction_record.dart';
import '../../../core/database/models/exchange_rate.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../shared/widgets/multi_toggle.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/utils/category_utils.dart';
import '../../../core/database/models/custom_category.dart';
import '../../../core/theme/app_constants.dart';
import 'dart:math' as math;

class SpendingGiantsWidget extends ConsumerStatefulWidget {
  final HomeWidgetSize size;
  final String? selectedVaultId;
  const SpendingGiantsWidget({super.key, this.size = HomeWidgetSize.large, this.selectedVaultId});

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

  void _handleFilterChange(int index) {
    if (_selectedFilterIndex == index) return;
    setState(() => _selectedFilterIndex = index);
    _chartController.reset();
    _chartController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final symbol = settings.currencySymbol;
    final rates = ref.watch(exchangeRatesProvider).value ?? [];
    final transactions = ref.watch(expenseTransactionsProvider);
    final customCategories = ref.watch(customCategoriesProvider);
    
    // Kasa / Vault bazında filtrele
    List<TransactionRecord> vaultFilteredTxs = transactions;
    if (widget.selectedVaultId != null && widget.selectedVaultId!.startsWith('v_')) {
      final filterVaultId = int.tryParse(widget.selectedVaultId!.replaceFirst('v_', ''));
      if (filterVaultId != null) {
        vaultFilteredTxs = transactions.where((tx) => tx.vaultId == filterVaultId).toList();
      }
    }
    
    final periods = _getAnalysisPeriods();
    final currentTxs = vaultFilteredTxs.where((tx) => tx.date.isAfter(periods['currentStart']!) && tx.date.isBefore(periods['currentEnd']!)).toList();
    final previousTxs = vaultFilteredTxs.where((tx) => tx.date.isAfter(periods['prevStart']!) && tx.date.isBefore(periods['prevEnd']!)).toList();

    final giants = _getAnalyticGiants(currentTxs, previousTxs, symbol, rates);

    return Column(
      children: [
        Center(
          child: MultiToggle(
            labels: const ['H', 'A', 'Y'],
            selectedIndex: _selectedFilterIndex,
            onChanged: _handleFilterChange,
            activeColors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary,
            ],
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
                                customCategories: customCategories,
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
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: giants.map((g) => _buildDetailItem(g, symbol, customCategories)).toList(),
                      ),
                    ),
                  ),
                ],
              ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(_AnalyticGiant g, String symbol, List<CustomCategory> customCategories) {
    final Color catColor = CategoryUtils.getCategoryColor(
      categoryId: g.categoryId,
      customCategories: customCategories,
    );
    final IconData catIcon = CategoryUtils.getCategoryIcon(
      categoryId: g.categoryId,
      customCategories: customCategories,
    );
    
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
              color: AppColors.getAccentDeep(context, catColor),
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
                  _getLocalizedCategoryName(context, g.categoryId, customCategories),
                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: AppColors.getTextPrimary(context), letterSpacing: -0.2),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                Text(
                  CurrencyUtils.formatAmount(g.amount, currencySymbol: symbol),
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

  String _getMainCategoryId(String? categoryId) {
    if (categoryId == null || categoryId.isEmpty) return 'Diğer';
    String baseId = categoryId;
    if (categoryId.contains('_custom_')) {
      baseId = categoryId.split('_custom_')[0];
    }
    final parts = baseId.split('_');
    if (parts.length >= 2) {
      return '${parts[0]}_${parts[1]}';
    }
    return baseId;
  }

  List<_AnalyticGiant> _getAnalyticGiants(List<TransactionRecord> currentTxs, List<TransactionRecord> prevTxs, String symbol, List<ExchangeRate> rates) {
    if (currentTxs.isEmpty) return [];
    final Map<String, double> currentSums = {};
    double currentTotal = 0;
    for (final tx in currentTxs) {
      final val = tx.getConvertedAmount(symbol, rates);
      final mainCat = _getMainCategoryId(tx.categoryId);
      currentSums[mainCat] = (currentSums[mainCat] ?? 0) + val;
      currentTotal += val;
    }
    final Map<String, double> prevSums = {};
    double prevTotal = 0;
    for (final tx in prevTxs) {
      final val = tx.getConvertedAmount(symbol, rates);
      final mainCat = _getMainCategoryId(tx.categoryId);
      prevSums[mainCat] = (prevSums[mainCat] ?? 0) + val;
      prevTotal += val;
    }
    final List<_AnalyticGiant> giants = [];
    final sortedCategories = currentSums.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    for (final entry in sortedCategories.take(4)) {
      final catId = entry.key;
      final currentAmount = entry.value;
      final prevAmount = prevSums[catId] ?? 0;
      giants.add(_AnalyticGiant(
        categoryId: catId == 'Diğer' ? null : catId, amount: currentAmount,
        percentage: currentTotal > 0 ? (currentAmount / currentTotal) * 100 : 0,
        prevPercentage: prevTotal > 0 ? (prevAmount / prevTotal) * 100 : 0,
        isNew: prevAmount == 0,
      ));
    }
    return giants;
  }

  String _getLocalizedCategoryName(BuildContext context, String? categoryId, List<CustomCategory> customCategories) {
    return CategoryUtils.getCategoryName(
      categoryId: categoryId,
      context: context,
      customCategories: customCategories,
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_graph_rounded, color: AppColors.getTextSecondary(context).withValues(alpha: 0.15), size: 48),
          const SizedBox(height: 12),
          Text(
            l10n.giantsWait,
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
  final List<CustomCategory> customCategories;

  _TripleOverlapPainter({
    required this.giants,
    required this.animationValue,
    required this.customCategories,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = (math.min(size.width, size.height) / 2) - 8;
    
    const double strokeWidth = 16.0;
    const double spacing = 2.0;
    const double coreWidth = 3.5;

    for (int i = 0; i < giants.length; i++) {
      final g = giants[i];
      
      final double currentRadius = maxRadius - i * (strokeWidth + spacing);
      if (currentRadius < strokeWidth) break;

      final Color catColor = CategoryUtils.getCategoryColor(
        categoryId: g.categoryId,
        customCategories: customCategories,
      );

      // 1. ZEMİN TRACK (Sönük arka plan halkası)
      final trackPaint = Paint()
        ..color = catColor.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      
      canvas.drawCircle(center, currentRadius, trackPaint);

      // 2. ŞU ANKİ DÖNEM (Düz renkli ana halka)
      final double sweepAngle = 2 * math.pi * (g.percentage / 100.0) * animationValue;
      if (sweepAngle > 0) {
        final currentPaint = Paint()
          ..color = catColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;
        
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: currentRadius),
          -math.pi / 2,
          sweepAngle,
          false,
          currentPaint,
        );
      }

      // 3. GEÇEN DÖNEM (İnce beyaz parlak çekirdek)
      final double prevSweepAngle = 2 * math.pi * (g.prevPercentage / 100.0) * animationValue;
      if (prevSweepAngle > 0) {
        final prevPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = coreWidth
          ..strokeCap = StrokeCap.round;
        
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: currentRadius),
          -math.pi / 2,
          prevSweepAngle,
          false,
          prevPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TripleOverlapPainter oldDelegate) => true;
}
