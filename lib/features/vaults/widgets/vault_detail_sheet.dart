import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_constants.dart';
import '../../../core/database/database_service.dart';
import '../../../core/database/models/vault.dart';
import '../../../core/providers/db_providers.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/icon_utils.dart';
import '../../../core/database/models/exchange_rate.dart';
import '../../../shared/widgets/precision_toggle.dart';
import '../../../shared/widgets/precision_segmented_control.dart';
import '../../../shared/widgets/precision_card.dart';
import '../../../shared/widgets/precision_input.dart';
import '../../../shared/widgets/precision_icon_button.dart';
import '../../../shared/widgets/precision_dialog.dart';
import '../../../l10n/app_localizations.dart';
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
  VaultDetailTab _activeTab = VaultDetailTab.transactions;
  
  String? _tempName;
  String? _tempCurrency;
  Set<int>? _tempSelectedTxIds;
  bool _isInitialized = false;

  List<Map<String, String>> _getCurrencies(AppLocalizations l10n) => [
    {'symbol': 'AUTO', 'label': l10n.auto},
    {'symbol': '₺', 'label': 'TL'},
    {'symbol': '\$', 'label': 'USD'},
    {'symbol': '€', 'label': 'EUR'},
    {'symbol': 'G', 'label': l10n.gold},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _nameController.addListener(() {
      if (_isInitialized) {
        _tempName = _nameController.text.trim();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
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
    if (_tempCurrency != null && _tempCurrency != vault.currency) {
      vault.currency = _tempCurrency!;
      vaultChanged = true;
    }

    if (vaultChanged) {
      await DatabaseService.updateVault(vault);
    }

    if (_tempSelectedTxIds != null) {
      final allTx = await DatabaseService.getAllTransactions();
      for (final tx in allTx) {
        final shouldBeInVault = _tempSelectedTxIds!.contains(tx.id);
        final isInVault = tx.vaultIds.contains(vaultDbId);
        
        if (shouldBeInVault != isInVault) {
          final newVaultIds = List<int>.from(tx.vaultIds);
          if (shouldBeInVault) {
            newVaultIds.add(vaultDbId);
          } else {
            newVaultIds.remove(vaultDbId);
          }
          tx.vaultIds = newVaultIds;
          await DatabaseService.updateTransaction(tx);
        }
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
    final globalCurrency = ref.watch(settingsProvider).currencySymbol;
    final rates = ref.watch(exchangeRatesProvider).value ?? [];
    
    final bool isMainVault = widget.vaultId == null;
    Vault? vault;
    List<TransactionUI> displayTxs;

    if (isMainVault) {
      vault = Vault()
        ..name = l10n.mainVault
        ..iconCode = 'account_balance_wallet_rounded'
        ..currency = 'AUTO';
      displayTxs = allTransactions;
    } else {
      final vaultDbId = int.tryParse(widget.vaultId!.replaceFirst('v_', ''));
      vault = allVaults.where((v) => v.id == vaultDbId).firstOrNull;
      
      if (vault != null && !_isInitialized) {
        _tempName = vault.name;
        _tempCurrency = vault.currency;
        _nameController.text = _tempName!;
        _tempSelectedTxIds = allTransactions
            .where((t) => t.groupIds.contains(widget.vaultId!))
            .map((t) => t.dbId!)
            .toSet();
        _isInitialized = true;
      }

      displayTxs = allTransactions.where((t) {
        if (_tempSelectedTxIds != null) {
          return _tempSelectedTxIds!.contains(t.dbId);
        }
        return t.groupIds.contains(widget.vaultId!);
      }).toList();
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
        if (didPop) {
          await _saveChanges();
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isMainVault)
            PrecisionSegmentedControl(
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
                ? _buildMainView(context, vault, displayTxs, activeColor, isDark, isMainVault, displayCurrency, sf, rates, l10n)
                : _buildManageView(context, vault, allTransactions, displayTxs, activeColor, isDark, sf, l10n),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainView(BuildContext context, Vault vault, List<TransactionUI> vaultTransactions, Color activeColor, bool isDark, bool isMainVault, String currency, double sf, List<ExchangeRate> rates, AppLocalizations l10n) {
    final incomeLoad = vaultTransactions.where((t) => t.isIncome).fold<double>(0, (sum, t) => sum + t.getConvertedMonthlyEquivalent(currency, rates));
    final expenseLoad = vaultTransactions.where((t) => !t.isIncome).fold<double>(0, (sum, t) => sum + t.getConvertedMonthlyEquivalent(currency, rates));
    final netLoad = incomeLoad - expenseLoad;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        key: const ValueKey('main_view'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  IconUtils.getIcon(vault.iconCode ?? vault.name),
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
          PrecisionCard(
            scalingFactor: sf,
            backgroundColor: activeColor.withValues(alpha: 0.05),
            borderColor: activeColor.withValues(alpha: 0.1),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.averageMonthlyLoad.toUpperCase(), style: TextStyle(fontSize: 9 * sf, fontWeight: FontWeight.w900, color: activeColor.withValues(alpha: 0.6), letterSpacing: 1)),
                    const SizedBox(height: 4),
                    Text(CurrencyUtils.formatFullAmount(netLoad, symbol: currency), style: TextStyle(fontSize: 20 * sf, fontWeight: FontWeight.w900, color: netLoad >= 0 ? AppColors.getIncome(context) : AppColors.getExpense(context))),
                  ],
                ),
                const Spacer(),
                Icon(Icons.query_stats_rounded, color: activeColor.withValues(alpha: 0.3), size: 24 * sf),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.transactions, style: TextStyle(fontSize: 14 * sf, fontWeight: FontWeight.w900, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black).withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.45 : 0.65))),
          const SizedBox(height: 12),
          if (vaultTransactions.isNotEmpty)
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.35 * sf),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(vertical: 4 * sf),
                itemCount: vaultTransactions.length,
                separatorBuilder: (_, __) => SizedBox(height: 10 * sf),
                itemBuilder: (context, index) => _buildTransactionItem(context, vaultTransactions[index], sf, isDark),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 40 * sf),
              child: Opacity(
                opacity: 0.5,
                child: Column(
                  children: [
                    Icon(Icons.receipt_long_rounded, size: 40 * sf),
                    SizedBox(height: 8 * sf),
                    Text(l10n.noTransactionsInVault, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13 * sf)),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildManageView(BuildContext context, Vault vault, List<TransactionUI> allTransactions, List<TransactionUI> vaultTransactions, Color activeColor, bool isDark, double sf, AppLocalizations l10n) {
    final standaloneTransactions = allTransactions.where((t) => t.groupIds.isEmpty || (_tempSelectedTxIds?.contains(t.dbId) ?? false)).toList();
    final currencies = _getCurrencies(l10n);

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
                child: PrecisionInput(
                  controller: _nameController,
                  hintText: l10n.vaultNameHint,
                  icon: Icons.edit_rounded,
                  scalingFactor: sf,
                ),
              ),
              const SizedBox(width: 12),
              PrecisionIconButton(
                icon: Icons.delete_outline_rounded,
                onTap: () => _confirmDeleteVault(context, vault),
                color: AppColors.error,
                backgroundColor: AppColors.error.withValues(alpha: 0.1),
                padding: 14,
                borderRadius: 16,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(l10n.currency.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black).withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.45 : 0.65), letterSpacing: 1)),
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
                      child: Text(c['label']!, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: isSelected ? Colors.white : AppColors.getTextPrimary(context).withValues(alpha: 0.5), letterSpacing: 0.5)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 32),
          Text(l10n.manageTransactionsInVault, style: TextStyle(fontSize: 16 * sf, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.35 * sf),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(vertical: 8 * sf),
              itemCount: standaloneTransactions.length,
              separatorBuilder: (_, __) => SizedBox(height: 10 * sf),
              itemBuilder: (context, index) {
                final tx = standaloneTransactions[index];
                final isSelected = _tempSelectedTxIds?.contains(tx.dbId) ?? false;
                return PrecisionCard(
                  scalingFactor: sf,
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8 * sf),
                        decoration: BoxDecoration(color: tx.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12 * sf)),
                        child: Icon(tx.icon, color: tx.color, size: 20 * sf),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(tx.name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14 * sf))),
                      PrecisionToggle(
                        value: isSelected,
                        activeColor: activeColor,
                        activeIcon: Icons.check_rounded,
                        inactiveIcon: Icons.add_rounded,
                        scalingFactor: 0.75 * sf,
                        onChanged: (val) {
                          if (tx.dbId == null) return;
                          HapticFeedback.selectionClick();
                          setState(() {
                            if (val) {
                              _tempSelectedTxIds!.add(tx.dbId!);
                            } else {
                              _tempSelectedTxIds!.remove(tx.dbId!);
                            }
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, TransactionUI tx, double sf, bool isDark) {
    return PrecisionCard(
      scalingFactor: sf,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8 * sf),
            decoration: BoxDecoration(color: tx.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12 * sf)),
            child: Icon(tx.icon, color: tx.color, size: 20 * sf),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.name, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14 * sf, letterSpacing: -0.5)),
                Text(CurrencyUtils.formatAmount(tx.effectiveAmount, currencySymbol: tx.currency ?? "₺"), style: TextStyle(fontSize: 12 * sf, fontWeight: FontWeight.w900, color: tx.isIncome ? AppColors.getIncome(context) : AppColors.getExpense(context))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteVault(BuildContext context, Vault vault) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showPrecisionDialog<bool>(
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
