import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:flutter/services.dart';
import '../../core/theme/app_constants.dart';
import '../../core/database/database_service.dart';
import '../../core/database/models/financial_goal.dart';
import '../../core/database/models/transaction_record.dart';
import '../../core/database/models/vault.dart';
import '../../core/database/models/exchange_rate.dart';
import '../../core/database/models/app_settings.dart';
import '../../core/providers/db_providers.dart';
import '../../core/providers/settings_provider.dart';

import '../../shared/widgets/precision_sheet.dart';
import 'optimization_providers.dart';
import 'ai_service.dart';
import '../../l10n/app_localizations.dart';
import '../../core/services/subscription_service.dart';
import '../../shared/widgets/precision_glass_card.dart';
import '../../shared/widgets/precision_button.dart';

import '../../shared/widgets/precision_picker.dart';
import '../../shared/widgets/precision_notification.dart';

import 'widgets/common/fluid_background.dart';
import 'widgets/setup/analysis_cockpit.dart';

import 'widgets/common/thousands_separator_formatter.dart';
import 'widgets/setup/history_section.dart';
import 'widgets/setup/persona_header.dart';
import 'widgets/setup/items_section.dart';

/// Hedef Odaklı Tasarruf Planlayıcı & AI Finansal Koç
class OptimizationScreen extends ConsumerStatefulWidget {
  const OptimizationScreen({super.key});

  @override
  ConsumerState<OptimizationScreen> createState() => _OptimizationScreenState();
}

class _OptimizationScreenState extends ConsumerState<OptimizationScreen>
    with TickerProviderStateMixin {
  double _targetAmount = 50000;
  DateTime _targetDate = DateTime.now().add(const Duration(days: 365));
  int? _scopeVaultId;

  bool _isAnalyzing = false;
  String? _personaText;
  
  final Set<int> _userLockedIds = {};
  final Set<int> _userFlexibleIds = {};

  late final AnimationController _bgAnimationController;

  @override
  void initState() {
    super.initState();
    _bgAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _bgAnimationController.dispose();
    super.dispose();
  }

  Future<void> _startAnalysis(
    List<TransactionRecord> txs,
    List<Vault> vaults,
    List<FinancialGoal> previousGoals,
    List<ExchangeRate> allRates,
    AppSettings settings,
  ) async {
    final subscription = ref.read(subscriptionServiceProvider);
    // Test amaçlı PRO ve Limit kontrolleri devre dışı bırakıldı
    /*
    if (!subscription.isPro) {
      if (mounted) ProUpgradeSheet.show(context);
      return;
    }
    if (subscription.usedAiCount >= subscription.dailyAiLimit) {
      if (mounted) {
        _showChicError('Günlük AI analiz limitine ulaştınız.');
      }
      return;
    }
    */

    setState(() => _isAnalyzing = true);
    await subscription.incrementAiUsage();

    // 1. Persona Üret
    try {
      final pText = await AiService.generatePersona(
        allTransactions: txs,
        vaults: vaults,
        countryName: settings.countryName,
        languageCode: settings.languageCode,
        previousGoals: previousGoals,
      );
      if (mounted) {
        setState(() => _personaText = pText);
      }
    } catch (_) {}

    // 2. Analiz Et
    final result = await OptimizationEngine.analyze(
      targetAmount: _targetAmount,
      targetDate: _targetDate,
      scopeVaultId: _scopeVaultId,
      allTransactions: txs,
      allVaults: vaults,
      allRates: allRates,
      settings: settings,
      userLockedIds: _userLockedIds,
      userFlexibleIds: _userFlexibleIds,
      vetoedCategories: previousGoals
          .where((g) => g.userApproved == false)
          .expand((g) => g.rejectedCategories)
          .toSet()
          .toList(),
      previousGoals: previousGoals,
    );

    // 3. Kaydet
    await _saveGoalDraft(result);

    if (mounted) {
      setState(() => _isAnalyzing = false);
      // Başarı mesajı göster (İsteğe bağlı ama iyi bir UX için)
      PrecisionNotification.success(
        context,
        AppLocalizations.of(context)!.financialIdentityUpdated,
      );
    }
  }

  Future<int> _saveGoalDraft(AnalysisResult result) async {
    final rawJson = jsonEncode({
      'snapshot': {
        'currentBalance': result.snapshot.currentBalance,
        'targetAmount': result.snapshot.targetAmount,
        'gap': result.snapshot.gap,
        'monthlyIncome': result.snapshot.monthlyIncome,
        'monthlyExpense': result.snapshot.monthlyExpense,
        'monthlySurplus': result.snapshot.monthlySurplus,
        'months': result.snapshot.months,
        'requiredMonthlySaving': result.snapshot.requiredMonthlySaving,
        'isAlreadyOnTrack': result.snapshot.isAlreadyOnTrack,
        'currencySymbol': result.snapshot.currencySymbol,
      },
      'optimization': result.optimizationResult == null
          ? null
          : {
              'coachMessage': result.optimizationResult!.coachMessage,
              'isFeasible': result.optimizationResult!.isFeasible,
              'cuts': result.optimizationResult!.cuts
                  .map(
                    (c) => {
                      'category': c.category,
                      'currentAmount': c.currentAmount,
                      'suggestedAmount': c.suggestedAmount,
                      'saving': c.saving,
                      'reason': c.reason,
                    },
                  )
                  .toList(),
            },
      'usedAi': result.usedAi,
      'persona': result.persona,
    });

    final goal = FinancialGoal()
      ..targetAmount = _targetAmount
      ..currencySymbol = result.snapshot.currencySymbol
      ..targetDate = _targetDate
      ..vaultId = _scopeVaultId
      ..createdAt = DateTime.now()
      ..aiPersonaText = _personaText
      ..aiStrategyText = result.optimizationResult?.coachMessage
      ..analysisRawData = rawJson;

    final id = await DatabaseService.addGoal(goal);
    final all = await DatabaseService.getAllGoals();
    if (all.length > 5) await DatabaseService.deleteGoal(all.last.id);
    return id;
  }

  void _showManualAmountEntry() {
    final l10n = AppLocalizations.of(context)!;
    final formatter = NumberFormat.decimalPattern('tr_TR');
    final controller = TextEditingController(
      text: formatter.format(_targetAmount.toInt()),
    );
    final settings = ref.read(settingsProvider);
    
    PrecisionSheet.show(
      context: context,
      title: l10n.amount,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PrecisionGlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  settings.currencySymbol,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.getPrimary(context).withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(width: 8),
                IntrinsicWidth(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      ThousandsSeparatorFormatter(),
                    ],
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: AppColors.getTextPrimary(context),
                      letterSpacing: -1,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                      hintText: '0',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          PrecisionButton(
            label: l10n.save,
            onTap: () {
              final val = double.tryParse(controller.text.replaceAll('.', ''));
              if (val != null) {
                setState(() => _targetAmount = val.clamp(0, 2000000));
              }
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  void _showVaultPicker(List<Vault> vaults, AppLocalizations l10n) {
    final List<String> pickerItems = [l10n.allVaults, ...vaults.map((v) => v.name)];
    
    int initialIdx = _scopeVaultId == null 
        ? 0 
        : vaults.indexWhere((v) => v.id == _scopeVaultId) + 1;
    if (initialIdx < 0) initialIdx = 0;

    int tempIdx = initialIdx;

    PrecisionSheet.show(
      context: context,
      title: l10n.scopeLabel,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PrecisionPicker.strings(
            items: pickerItems,
            initialItem: initialIdx,
            onSelectedItemChanged: (index) {
              tempIdx = index;
            },
          ),
          const SizedBox(height: 24),
          PrecisionButton(
            label: l10n.ok,
            onTap: () {
              setState(() {
                if (tempIdx == 0) {
                  _scopeVaultId = null;
                } else {
                  _scopeVaultId = vaults[tempIdx - 1].id;
                }
              });
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final txsAsync = ref.watch(activeTransactionsProvider);
    final vaultsAsync = ref.watch(vaultsProvider);
    final goalsAsync = ref.watch(goalsProvider);
    final ratesAsync = ref.watch(exchangeRatesProvider);
    final settings = ref.watch(settingsProvider);

    return Stack(
      fit: StackFit.expand,
      children: [
        FluidBackground(animation: _bgAnimationController),
        txsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Hata: $e')),
          data: (txs) => vaultsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Hata: $e')),
            data: (vaults) => goalsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => const Center(child: Text('Hata')),
              data: (goals) => ratesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => const Center(child: Text('Kurlar yüklenemedi')),
                data: (rates) => _buildContent(
                  txs,
                  vaults,
                  goals,
                  rates,
                  settings,
                  AppLocalizations.of(context)!,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(
    List<TransactionRecord> txs,
    List<Vault> vaults,
    List<FinancialGoal> goals,
    List<ExchangeRate> rates,
    AppSettings settings,
    AppLocalizations l10n,
  ) {
    return SafeArea(
      bottom: false,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 350),
            children: [
              OptimizationPersonaHeader(
                goals: goals,
                currentPersonaText: _personaText,
                isAnalyzing: _isAnalyzing,
                l10n: l10n,
              ),
              const SizedBox(height: 16),
              OptimizationItemsSection(
                txs: txs,
                scopeVaultId: _scopeVaultId,
                userLockedIds: _userLockedIds,
                userFlexibleIds: _userFlexibleIds,
                l10n: l10n,
                onStatusChanged: (id, status) {
                  setState(() {
                    if (status == 0) {
                      _userLockedIds.add(id);
                      _userFlexibleIds.remove(id);
                    } else if (status == 1) {
                      _userLockedIds.remove(id);
                      _userFlexibleIds.remove(id);
                    } else {
                      _userLockedIds.remove(id);
                      _userFlexibleIds.add(id);
                    }
                  });
                },
              ),
              const SizedBox(height: 32),
              OptimizationHistorySection(
                goals: goals,
                l10n: l10n,
                isAnalyzing: _isAnalyzing,
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnalysisCockpit(
              targetAmount: _targetAmount,
              isAnalyzing: _isAnalyzing,
              onAnalyzeTap: () => _startAnalysis(txs, vaults, goals, rates, settings),
              onAmountTap: _showManualAmountEntry,
              targetDate: _targetDate,
              vaultName: _scopeVaultId == null
                  ? l10n.allVaults
                  : vaults.firstWhere((v) => v.id == _scopeVaultId).name,
              onDateTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _targetDate,
                  firstDate: DateTime.now().add(const Duration(days: 30)),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                );
                if (picked != null) setState(() => _targetDate = picked);
              },
              onVaultTap: () => _showVaultPicker(vaults, l10n),
              currencySymbol: settings.currencySymbol,
              l10n: l10n,
            ),
          ),
        ],
      ),
    );
  }
}
