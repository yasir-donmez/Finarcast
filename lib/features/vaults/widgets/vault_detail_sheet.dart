import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_constants.dart';
import '../../transactions/widgets/transaction_amount_input.dart';
import '../../../core/database/database_service.dart';
import '../../../core/database/models/vault.dart';
import '../../../core/database/models/transaction_record.dart';
import '../../../core/providers/db_providers.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/services/currency_service.dart';
import '../../../core/database/models/exchange_rate.dart';
import '../../../shared/widgets/segmented_control.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_icon_button.dart';
import '../../../shared/widgets/custom_dialog.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/utils/string_utils.dart';
import '../vaults_providers.dart';

enum VaultDetailTab { transactions, manage }

class VaultDetailSheet extends ConsumerStatefulWidget {
  final String? vaultId;
  const VaultDetailSheet({super.key, required this.vaultId});

  @override
  ConsumerState<VaultDetailSheet> createState() => _VaultDetailSheetState();
}

class _VaultDetailSheetState extends ConsumerState<VaultDetailSheet> with SingleTickerProviderStateMixin {
  late TextEditingController _nameController;
  late TextEditingController _balanceController;
  VaultDetailTab _activeTab = VaultDetailTab.transactions;
  
  String? _tempName;
  String? _tempCurrency;
  bool _isInitialized = false;
  double _initialCurrentBalance = 0.0;

  List<Map<String, String>> _getCurrencies(AppLocalizations l10n) {
    final List<Map<String, String>> items = [
      {'symbol': 'AUTO', 'label': l10n.auto},
    ];
    for (var symbol in AppCurrency.displaySymbols) {
      String label = symbol;
      if (symbol == '₺') {
        label = 'TL';
      } else if (symbol == r'$') {
        label = 'USD';
      } else if (symbol == '€') {
        label = 'EUR';
      }
      items.add({'symbol': symbol, 'label': label});
    }
    return items;
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _nameController.addListener(() {
      if (_isInitialized) {
        _tempName = _nameController.text.trim();
      }
    });
    _balanceController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges(AppLocalizations l10n) async {
    if (widget.vaultId == null) return;
    
    final vaultDbId = int.tryParse(widget.vaultId!.replaceFirst('v_', ''));
    if (vaultDbId == null) return;

    final vault = await DatabaseService.getVault(vaultDbId);
    if (vault == null) return;

    bool vaultChanged = false;
    if (_tempName != null && _tempName != vault.name && _tempName!.isNotEmpty) {
      vault.name = _tempName!;
      vaultChanged = true;
    }
    
    final globalCurrency = ref.read(settingsProvider).currencySymbol;

    if (_tempCurrency != null && _tempCurrency != vault.currency) {
      final baseCurrency = globalCurrency;
      final targetCurrency = _tempCurrency!;
      
      if (targetCurrency != 'AUTO' && targetCurrency != baseCurrency) {
        var rates = await DatabaseService.getAllExchangeRates();
        final code = CurrencyUtils.symbolToCode(targetCurrency);
        var hasRate = rates.any((r) => r.currencyCode == code && r.rate > 0);
        
        if (!hasRate) {
          // Kurlar yok, otomatik çekmeyi dene
          final success = await CurrencyService.updateRates();
          if (success) {
            rates = await DatabaseService.getAllExchangeRates();
            hasRate = rates.any((r) => r.currencyCode == code && r.rate > 0);
          }
        }

        if (!hasRate) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  l10n.exchangeRatesNotLoadedVault,
                ),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
          _tempCurrency = vault.currency;
        } else {
          vault.currency = targetCurrency;
          vaultChanged = true;
        }
      } else {
        vault.currency = targetCurrency;
        vaultChanged = true;
      }
    }

    if (vaultChanged) {
      await DatabaseService.updateVault(vault);
    }

    // --- BAKIYE DUZELTME ISLEMI ---
    double? parseLocaleDouble(String input) {
      if (input.isEmpty) return null;
      final locale = Localizations.localeOf(context).toString();
      final format = NumberFormat.decimalPattern(locale);
      final decimalSep = format.symbols.DECIMAL_SEP;
      final groupSep = format.symbols.GROUP_SEP;

      String clean = input.replaceAll(groupSep, '');
      if (decimalSep != '.') {
        clean = clean.replaceAll(decimalSep, '.');
      }
      return double.tryParse(clean);
    }

    final double? editedBalance = parseLocaleDouble(_balanceController.text);
    if (editedBalance != null) {
      final tempCurrency = (_tempCurrency ?? vault.currency) == 'AUTO' ? globalCurrency : (_tempCurrency ?? vault.currency);
      
      final cardData = ref.read(vaultCardDataProvider)[widget.vaultId];
      final double currentBalanceVal = cardData?.balance ?? 0.0;

      if ((editedBalance - currentBalanceVal).abs() > 0.005) {
        final double difference = editedBalance - currentBalanceVal;
        
        final String oldBalanceStr = CurrencyUtils.formatFullAmount(currentBalanceVal, symbol: tempCurrency);
        final String newBalanceStr = CurrencyUtils.formatFullAmount(editedBalance, symbol: tempCurrency);
        
        final tx = TransactionRecord()
          ..title = l10n.balanceAdjustment
          ..amount = difference.abs()
          ..isIncome = difference > 0
          ..date = DateTime.now()
          ..occurrenceDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
          ..vaultId = vault.id
          ..currency = tempCurrency
          ..categoryId = difference > 0 ? 'inc_other_general' : 'exp_other_general'
          ..iconCode = 'account_balance_wallet_rounded'
          ..note = l10n.balanceAdjustmentNote(oldBalanceStr, newBalanceStr)
          ..status = 0
          ..isReviewed = true
          ..occurrenceKey = TransactionRecord.generateManualKey();

        await DatabaseService.addTransaction(tx);
      }
    }
  }

  void _switchTab(VaultDetailTab tab) {
    if (_activeTab == tab) return;
    HapticFeedback.mediumImpact();
    setState(() => _activeTab = tab);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final allVaults = ref.watch(allVaultsProvider);
    final allTransactions = ref.watch(vaultTransactionsProvider);
    final allTemplates = ref.watch(vaultTemplatesProvider);
    final globalCurrency = ref.watch(settingsProvider).currencySymbol;
    final rates = ref.watch(exchangeRatesProvider).value ?? [];
    
    final bool isMainVault = widget.vaultId == null;
    Vault? vault;
    List<TransactionUI> displayTxs;
    List<TemplateUI> displayTemplates;

    if (isMainVault) {
      vault = Vault()
        ..name = l10n.mainVault
        ..currency = 'AUTO';
      displayTxs = allTransactions;
      displayTemplates = allTemplates;
    } else {
      final vaultDbId = int.tryParse(widget.vaultId!.replaceFirst('v_', ''));
      vault = allVaults.where((v) => v.id == vaultDbId).firstOrNull;
      
      displayTxs = allTransactions.where((t) {
        return t.groupIds.contains(widget.vaultId!);
      }).toList();

      displayTemplates = allTemplates.where((t) {
        return t.vaultId == vaultDbId;
      }).toList();

      if (vault != null && !_isInitialized) {
        _tempName = vault.name;
        _tempCurrency = vault.currency;
        _nameController.text = _tempName!;
        
        final cardData = ref.read(vaultCardDataProvider)[widget.vaultId];
        _initialCurrentBalance = cardData?.balance ?? 0.0;

        final locale = Localizations.localeOf(context).toString();
        final format = NumberFormat.decimalPattern(locale);
        final decimalSep = format.symbols.DECIMAL_SEP;
        String rawText = _initialCurrentBalance.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '').replaceAll('.', decimalSep);
        final formatter = LocaleCurrencyFormatter(locale);
        _balanceController.text = formatter.formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(text: rawText),
        ).text;
        
        _isInitialized = true;
      }
    }

    if (vault == null) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = AppColors.getPrimary(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final sf = (screenHeight / 812.0).clamp(0.85, 1.0);

    final displayCurrency = (_tempCurrency ?? vault.currency) == 'AUTO' 
        ? globalCurrency 
        : (_tempCurrency ?? vault.currency);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        // Changes are only saved when explicitly clicking the "Save" button.
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isMainVault)
            SegmentedControl(
              tabs: [l10n.transactions, l10n.manage],
              selectedIndex: _activeTab == VaultDetailTab.transactions ? 0 : 1,
              onTabChanged: (index) => _switchTab(index == 0 ? VaultDetailTab.transactions : VaultDetailTab.manage),
              scalingFactor: sf,
            ),
          SizedBox(height: (isMainVault ? 0 : 12) * sf),
          AnimatedSize(
            duration: const Duration(milliseconds: 400),
            alignment: Alignment.topCenter,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: _activeTab == VaultDetailTab.transactions
                ? _buildMainView(context, vault, displayTxs, displayTemplates, activeColor, isDark, isMainVault, displayCurrency, sf, rates, l10n)
                : _buildManageView(context, vault, activeColor, isDark, sf, l10n),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainView(
    BuildContext context,
    Vault vault,
    List<TransactionUI> vaultTransactions,
    List<TemplateUI> vaultTemplates,
    Color activeColor,
    bool isDark,
    bool isMainVault,
    String currency,
    double sf,
    List<ExchangeRate> rates,
    AppLocalizations l10n,
  ) {
    final isTr = Localizations.localeOf(context).languageCode == 'tr';
    // === FİNANSAL HESAPLAMALAR ===
    final incomeLoad = vaultTemplates.where((t) => t.isIncome).fold<double>(0, (sum, t) => sum + t.getConvertedMonthlyEquivalent(currency, rates));
    final expenseLoad = vaultTemplates.where((t) => !t.isIncome).fold<double>(0, (sum, t) => sum + t.getConvertedMonthlyEquivalent(currency, rates));
    final netLoad = incomeLoad - expenseLoad;
    final savingsRate = incomeLoad > 0 ? ((netLoad / incomeLoad) * 100).clamp(-999.0, 100.0) : 0.0;
    final yearlyProjection = netLoad * 12;

    // En büyük gelir ve gider kalemleri
    final incomeItems = vaultTemplates.where((t) => t.isIncome).toList()..sort((a, b) => b.getConvertedMonthlyEquivalent(currency, rates).compareTo(a.getConvertedMonthlyEquivalent(currency, rates)));
    final expenseItems = vaultTemplates.where((t) => !t.isIncome).toList()..sort((a, b) => b.getConvertedMonthlyEquivalent(currency, rates).compareTo(a.getConvertedMonthlyEquivalent(currency, rates)));
    final topIncome = incomeItems.isNotEmpty ? incomeItems.first : null;
    final topExpense = expenseItems.isNotEmpty ? expenseItems.first : null;

    // İşlem sayısı dağılımı
    final incomeCount = vaultTransactions.where((t) => t.isIncome).length;
    final expenseCount = vaultTransactions.where((t) => !t.isIncome).length;

    // Senaryo analizi (esnek işlemlerin min/max değerlerine göre)
    final hasFlexible = vaultTemplates.any((t) => t.minAmount != null || t.maxAmount != null);
    double monthlyBest = 0, monthlyWorst = 0;
    for (final tx in vaultTemplates) {
      if (tx.isIncome) {
        monthlyBest += tx.maxMonthlyEquivalent > 0 ? CurrencyUtils.convert(tx.maxMonthlyEquivalent, tx.currency ?? '₺', currency, rates) : tx.getConvertedMonthlyEquivalent(currency, rates);
        monthlyWorst += tx.minMonthlyEquivalent > 0 ? CurrencyUtils.convert(tx.minMonthlyEquivalent, tx.currency ?? '₺', currency, rates) : tx.getConvertedMonthlyEquivalent(currency, rates);
      } else {
        monthlyBest -= tx.minMonthlyEquivalent > 0 ? CurrencyUtils.convert(tx.minMonthlyEquivalent, tx.currency ?? '₺', currency, rates) : tx.getConvertedMonthlyEquivalent(currency, rates);
        monthlyWorst -= tx.maxMonthlyEquivalent > 0 ? CurrencyUtils.convert(tx.maxMonthlyEquivalent, tx.currency ?? '₺', currency, rates) : tx.getConvertedMonthlyEquivalent(currency, rates);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        key: const ValueKey('main_view'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // === HEADER ===
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_rounded,
                  color: activeColor.withValues(alpha: 0.4),
                  size: 22 * sf,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _tempName ?? vault.name,
                    style: TextStyle(fontSize: 18 * sf, fontWeight: FontWeight.w900, letterSpacing: -0.5, color: AppColors.getTextPrimary(context)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // === 1. AYLIK NET BAKİYE (Hero Kart) ===
          CustomCard(
            scalingFactor: sf,
            backgroundColor: activeColor.withValues(alpha: 0.06),
            borderColor: activeColor.withValues(alpha: 0.12),
            padding: EdgeInsets.all(16 * sf),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8 * sf),
                      decoration: BoxDecoration(
                        color: activeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10 * sf),
                      ),
                      child: Icon(Icons.account_balance_wallet_rounded, color: activeColor, size: 18 * sf),
                    ),
                    SizedBox(width: 10 * sf),
                    Text(l10n.monthlyNetBalance, style: TextStyle(fontSize: 9 * sf, fontWeight: FontWeight.w900, color: activeColor.withValues(alpha: isDark ? 0.7 : 0.95), letterSpacing: 1.2)),
                    const Spacer(),
                    Text(l10n.perMonth, style: TextStyle(fontSize: 10 * sf, fontWeight: FontWeight.w700, color: AppColors.getTextSecondary(context).withValues(alpha: isDark ? 0.4 : 0.7))),
                  ],
                ),
                SizedBox(height: 12 * sf),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    CurrencyUtils.formatFullAmount(netLoad, symbol: currency),
                    style: TextStyle(fontSize: 28 * sf, fontWeight: FontWeight.w900, color: netLoad >= 0 ? AppColors.getIncome(context) : AppColors.getExpense(context), letterSpacing: -1),
                  ),
                ),
                SizedBox(height: 12 * sf),
                // Gelir & Gider satırı
                Row(
                  children: [
                    _buildMiniMetric(context, l10n.income, CurrencyUtils.formatFullAmount(incomeLoad, symbol: currency), AppColors.getIncome(context), sf),
                    SizedBox(width: 16 * sf),
                    _buildMiniMetric(context, l10n.expense, CurrencyUtils.formatFullAmount(expenseLoad, symbol: currency), AppColors.getExpense(context), sf),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 10 * sf),

          // === 2. TASARRUF ORANI & YILLIK PROJEKSİYON (İkili Kart) ===
          Row(
            children: [
              Expanded(
                child: CustomCard(
                  scalingFactor: sf,
                  padding: EdgeInsets.all(14 * sf),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.savings_rounded, color: savingsRate >= 0 ? Colors.teal : AppColors.getExpense(context), size: 14 * sf),
                          SizedBox(width: 6 * sf),
                          Flexible(child: Text(l10n.savingsRate, style: TextStyle(fontSize: 8 * sf, fontWeight: FontWeight.w900, color: AppColors.getTextSecondary(context).withValues(alpha: isDark ? 0.5 : 0.8), letterSpacing: 0.8))),
                        ],
                      ),
                      SizedBox(height: 8 * sf),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          incomeLoad > 0 
                              ? (isTr 
                                  ? (savingsRate >= 0 ? '%${savingsRate.toStringAsFixed(1)}' : '-%${savingsRate.abs().toStringAsFixed(1)}')
                                  : '${savingsRate.toStringAsFixed(1)}%')
                              : '—',
                          style: TextStyle(fontSize: 22 * sf, fontWeight: FontWeight.w900, color: savingsRate >= 20 ? Colors.teal : savingsRate >= 0 ? Colors.orange : AppColors.getExpense(context)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 10 * sf),
              Expanded(
                child: CustomCard(
                  scalingFactor: sf,
                  padding: EdgeInsets.all(14 * sf),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.trending_up_rounded, color: yearlyProjection >= 0 ? AppColors.getIncome(context) : AppColors.getExpense(context), size: 14 * sf),
                          SizedBox(width: 6 * sf),
                          Flexible(child: Text(l10n.yearlyProjection, style: TextStyle(fontSize: 8 * sf, fontWeight: FontWeight.w900, color: AppColors.getTextSecondary(context).withValues(alpha: isDark ? 0.5 : 0.8), letterSpacing: 0.8))),
                        ],
                      ),
                      SizedBox(height: 8 * sf),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          CurrencyUtils.formatFullAmount(yearlyProjection, symbol: currency),
                          style: TextStyle(fontSize: 20 * sf, fontWeight: FontWeight.w900, color: yearlyProjection >= 0 ? AppColors.getIncome(context) : AppColors.getExpense(context)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 10 * sf),

          // === 3. EN BÜYÜK GELİR & GİDER (İkili Kart) ===
          Row(
            children: [
              Expanded(
                child: CustomCard(
                  scalingFactor: sf,
                  padding: EdgeInsets.all(14 * sf),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.topIncome, style: TextStyle(fontSize: 8 * sf, fontWeight: FontWeight.w900, color: AppColors.getIncome(context).withValues(alpha: isDark ? 0.6 : 0.85), letterSpacing: 0.8)),
                      SizedBox(height: 6 * sf),
                      if (topIncome != null) ...[
                        Row(
                          children: [
                            Icon(topIncome.icon, color: topIncome.color, size: 16 * sf),
                            SizedBox(width: 6 * sf),
                            Flexible(child: Text(topIncome.title, style: TextStyle(fontSize: 12 * sf, fontWeight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                        SizedBox(height: 4 * sf),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(CurrencyUtils.formatFullAmount(topIncome.getConvertedMonthlyEquivalent(currency, rates), symbol: currency), style: TextStyle(fontSize: 14 * sf, fontWeight: FontWeight.w900, color: AppColors.getIncome(context))),
                        ),
                      ] else
                        Text('—', style: TextStyle(fontSize: 14 * sf, fontWeight: FontWeight.w700, color: AppColors.getTextSecondary(context).withValues(alpha: 0.3))),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 10 * sf),
              Expanded(
                child: CustomCard(
                  scalingFactor: sf,
                  padding: EdgeInsets.all(14 * sf),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.topExpense, style: TextStyle(fontSize: 8 * sf, fontWeight: FontWeight.w900, color: AppColors.getExpense(context).withValues(alpha: isDark ? 0.6 : 0.85), letterSpacing: 0.8)),
                      SizedBox(height: 6 * sf),
                      if (topExpense != null) ...[
                        Row(
                          children: [
                            Icon(topExpense.icon, color: topExpense.color, size: 16 * sf),
                            SizedBox(width: 6 * sf),
                            Flexible(child: Text(topExpense.title, style: TextStyle(fontSize: 12 * sf, fontWeight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                        SizedBox(height: 4 * sf),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(CurrencyUtils.formatFullAmount(topExpense.getConvertedMonthlyEquivalent(currency, rates), symbol: currency), style: TextStyle(fontSize: 14 * sf, fontWeight: FontWeight.w900, color: AppColors.getExpense(context))),
                        ),
                      ] else
                        Text('—', style: TextStyle(fontSize: 14 * sf, fontWeight: FontWeight.w700, color: AppColors.getTextSecondary(context).withValues(alpha: 0.3))),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 10 * sf),

          // === 4. İŞLEM DAĞILIMI ===
          CustomCard(
            scalingFactor: sf,
            padding: EdgeInsets.all(14 * sf),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.transactionBreakdown, style: TextStyle(fontSize: 9 * sf, fontWeight: FontWeight.w900, color: AppColors.getTextSecondary(context).withValues(alpha: isDark ? 0.5 : 0.8), letterSpacing: 1)),
                SizedBox(height: 10 * sf),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    height: 8 * sf,
                    child: Row(
                      children: [
                        if (incomeCount > 0)
                          Flexible(
                            flex: incomeCount,
                            child: Container(color: AppColors.getIncome(context)),
                          ),
                        if (expenseCount > 0)
                          Flexible(
                            flex: expenseCount,
                            child: Container(color: AppColors.getExpense(context)),
                          ),
                        if (incomeCount == 0 && expenseCount == 0)
                          Expanded(child: Container(color: AppColors.getTextSecondary(context).withValues(alpha: 0.1))),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10 * sf),
                Row(
                  children: [
                    _buildCountChip(context, l10n.incomeCount, incomeCount, AppColors.getIncome(context), sf),
                    SizedBox(width: 12 * sf),
                    _buildCountChip(context, l10n.expenseCount, expenseCount, AppColors.getExpense(context), sf),
                    const Spacer(),
                    Text(l10n.itemCount(vaultTransactions.length), style: TextStyle(fontSize: 11 * sf, fontWeight: FontWeight.w700, color: AppColors.getTextSecondary(context).withValues(alpha: isDark ? 0.4 : 0.7))),
                  ],
                ),
              ],
            ),
          ),

          // === 5. SENARYO ANALİZİ (sadece esnek işlem varsa) ===
          if (hasFlexible) ...[
            SizedBox(height: 10 * sf),
            CustomCard(
              scalingFactor: sf,
              backgroundColor: Colors.deepPurple.withValues(alpha: isDark ? 0.08 : 0.04),
              borderColor: Colors.deepPurple.withValues(alpha: 0.12),
              padding: EdgeInsets.all(14 * sf),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.analytics_rounded, color: Colors.deepPurple, size: 16 * sf),
                      SizedBox(width: 8 * sf),
                      Text(l10n.scenarioAnalysis, style: TextStyle(fontSize: 9 * sf, fontWeight: FontWeight.w900, color: Colors.deepPurple.withValues(alpha: isDark ? 0.7 : 0.95), letterSpacing: 1)),
                    ],
                  ),
                  SizedBox(height: 12 * sf),
                  // Aylık senaryolar
                  Row(
                    children: [
                      Expanded(child: _buildScenarioCell(context, l10n.monthlyBest, monthlyBest, currency, AppColors.getIncome(context), sf)),
                      SizedBox(width: 10 * sf),
                      Expanded(child: _buildScenarioCell(context, l10n.monthlyWorst, monthlyWorst, currency, AppColors.getExpense(context), sf)),
                    ],
                  ),
                  SizedBox(height: 8 * sf),
                  // Yıllık senaryolar
                  Row(
                    children: [
                      Expanded(child: _buildScenarioCell(context, l10n.yearlyBest, monthlyBest * 12, currency, AppColors.getIncome(context), sf)),
                      SizedBox(width: 10 * sf),
                      Expanded(child: _buildScenarioCell(context, l10n.yearlyWorst, monthlyWorst * 12, currency, AppColors.getExpense(context), sf)),
                    ],
                  ),
                ],
              ),
            ),
          ],

          SizedBox(height: 16 * sf),
        ],
      ),
    );
  }

  // === YARDIMCI WİDGETLER ===

  Widget _buildMiniMetric(BuildContext context, String label, String value, Color color, double sf) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12 * sf, vertical: 8 * sf),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10 * sf),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toSafeUpperCase(context), style: TextStyle(fontSize: 8 * sf, fontWeight: FontWeight.w900, color: color.withValues(alpha: isDark ? 0.6 : 0.85), letterSpacing: 0.8)),
            SizedBox(height: 2 * sf),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, style: TextStyle(fontSize: 15 * sf, fontWeight: FontWeight.w900, color: color)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountChip(BuildContext context, String label, int count, Color color, double sf) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8 * sf, height: 8 * sf,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        SizedBox(width: 4 * sf),
        Text('$label: $count', style: TextStyle(fontSize: 11 * sf, fontWeight: FontWeight.w700, color: AppColors.getTextSecondary(context).withValues(alpha: isDark ? 0.6 : 0.85))),
      ],
    );
  }

  Widget _buildScenarioCell(BuildContext context, String label, double value, String currency, Color accentColor, double sf) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPositive = value >= 0;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12 * sf, vertical: 8 * sf),
      decoration: BoxDecoration(
        color: (isPositive ? AppColors.getIncome(context) : AppColors.getExpense(context)).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10 * sf),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 8 * sf, fontWeight: FontWeight.w900, color: AppColors.getTextSecondary(context).withValues(alpha: isDark ? 0.5 : 0.8), letterSpacing: 0.5)),
          SizedBox(height: 4 * sf),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              CurrencyUtils.formatFullAmount(value, symbol: currency),
              style: TextStyle(fontSize: 14 * sf, fontWeight: FontWeight.w900, color: isPositive ? AppColors.getIncome(context) : AppColors.getExpense(context)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManageView(BuildContext context, Vault vault, Color activeColor, bool isDark, double sf, AppLocalizations l10n) {
    final currencies = _getCurrencies(l10n);

    final allVaults = ref.watch(allVaultsProvider);
    final bool isLastVault = allVaults.length <= 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        key: const ValueKey('manage_view'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _nameController,
                  hintText: l10n.vaultNameHint,
                  icon: Icons.edit_rounded,
                  scalingFactor: sf,
                ),
              ),
              const SizedBox(width: 12),
              CustomIconButton(
                icon: Icons.delete_outline_rounded,
                onTap: isLastVault
                    ? () {
                        HapticFeedback.vibrate();
                        showCustomDialog(
                          context: context,
                          accentColor: AppColors.error,
                          title: l10n.cannotDeleteVault,
                          content: l10n.cannotDeleteVaultDesc,
                          actions: [
                            PrecisionDialogAction(
                              label: l10n.ok,
                              onTap: () => Navigator.pop(context),
                              isPrimary: true,
                            ),
                          ],
                        );
                      }
                    : () => _confirmDeleteVault(context, vault),
                color: isLastVault ? AppColors.getTextFaint(context) : AppColors.error,
                backgroundColor: isLastVault
                    ? AppColors.getTextFaint(context).withValues(alpha: 0.05)
                    : AppColors.error.withValues(alpha: 0.1),
                padding: 14,
                borderRadius: 16,
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _balanceController,
            hintText: l10n.currentBalance,
            icon: Icons.payments_rounded,
            suffixText: (_tempCurrency ?? vault.currency) == 'AUTO' ? '' : (_tempCurrency ?? vault.currency),
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            inputFormatters: [
              LocaleCurrencyFormatter(Localizations.localeOf(context).toString()),
            ],
            scalingFactor: sf,
          ),
          const SizedBox(height: 20),
          Text(l10n.currency.toSafeUpperCase(context), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.getTextSecondary(context), letterSpacing: 1)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: currencies.map((c) {
                final isSelected = (_tempCurrency ?? vault.currency) == c['symbol'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _tempCurrency = c['symbol']!);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? activeColor : activeColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? activeColor : activeColor.withValues(alpha: 0.1), width: 1.5),
                      ),
                      child: Text(c['label']!, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: isSelected ? Colors.white : AppColors.getTextSecondary(context), letterSpacing: 0.5)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            label: l10n.save,
            onTap: () async {
              await _saveChanges(l10n);
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            activeColor: activeColor,
            height: 54 * sf,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
  Future<void> _confirmDeleteVault(BuildContext context, Vault vault) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showCustomDialog<bool>(
      context: context,
      accentColor: AppColors.error,
      title: l10n.deleteVault,
      content: l10n.deleteVaultConfirm(vault.name),
      actions: [
        PrecisionDialogAction(label: l10n.cancel, onTap: () => Navigator.pop(context, false), isPrimary: false),
        PrecisionDialogAction(label: l10n.ok, onTap: () => Navigator.pop(context, true), isPrimary: true),
      ],
    );
    if (confirm == true) {
      await DatabaseService.deleteVault(vault.id);
      if (context.mounted) Navigator.pop(context);
    }
  }
}
