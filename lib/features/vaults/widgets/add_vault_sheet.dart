import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_constants.dart';
import '../../../core/database/database_service.dart';
import '../../../core/database/models/vault.dart';
import '../../../core/database/models/transaction_record.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/string_utils.dart';
import '../../../core/services/currency_service.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../auth/widgets/auth_wave.dart';
import '../../../l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../../transactions/widgets/transaction_amount_input.dart';

class AddVaultSheet extends ConsumerStatefulWidget {
  const AddVaultSheet({super.key});

  @override
  ConsumerState<AddVaultSheet> createState() => _AddVaultSheetState();
}

class _AddVaultSheetState extends ConsumerState<AddVaultSheet> with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();
  String _selectedCurrency = 'AUTO';
  late AnimationController _waveController;

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
      } else if (symbol == 'G') {
        label = l10n.gold;
      }
      
      items.add({'symbol': symbol, 'label': label});
    }
    return items;
  }

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final activeColor = AppColors.getPrimary(context);
    final secondaryColor = AppColors.getSecondary(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final sf = (screenHeight / 812.0).clamp(0.85, 1.0);
    final currencies = _getCurrencies(l10n);

    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: AuthWave(
              controller: _waveController,
              color: secondaryColor,
              isTriggered: true,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _nameController,
                hintText: l10n.vaultNameHint,
                icon: Icons.drive_file_rename_outline_rounded,
                autofocus: true,
                scalingFactor: sf,
              ),
              
              SizedBox(height: 20 * sf),
              CustomTextField(
                controller: _balanceController,
                hintText: l10n.initialBalance,
                icon: Icons.payments_rounded,
                suffixText: _selectedCurrency == 'AUTO' ? '' : _selectedCurrency,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  LocaleCurrencyFormatter(Localizations.localeOf(context).toString()),
                ],
                scalingFactor: sf,
              ),
              
              SizedBox(height: 20 * sf),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  l10n.currency.toSafeUpperCase(context),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: AppColors.getTextSecondary(context),
                    letterSpacing: 1,
                  ),
                ),
              ),
              SizedBox(height: 12 * sf),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: currencies.map((c) {
                    final isSelected = _selectedCurrency == c['symbol'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedCurrency = c['symbol']!);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? activeColor : activeColor.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? activeColor : activeColor.withValues(alpha: 0.1),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            c['label']!,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: isSelected ? Colors.white : AppColors.getTextSecondary(context),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 24 * sf),
              CustomButton(
                label: l10n.createVault,
                onTap: () async {
                  final locale = Localizations.localeOf(context).toString();
                  if (_nameController.text.isNotEmpty) {
                    final baseCurrency = ref.read(settingsProvider).currencySymbol;
                    final targetCurrency = _selectedCurrency;

                    if (targetCurrency != 'AUTO' && targetCurrency != baseCurrency) {
                      var rates = await DatabaseService.getAllExchangeRates();
                      final code = CurrencyUtils.symbolToCode(targetCurrency);
                      var hasRate = code == 'TRY' || rates.any((r) => r.currencyCode == code && r.rate > 0);

                      if (!hasRate) {
                        // Kurlar yok, otomatik çekmeyi dene
                        final success = await CurrencyService.updateRates();
                        if (success) {
                          rates = await DatabaseService.getAllExchangeRates();
                          hasRate = code == 'TRY' || rates.any((r) => r.currencyCode == code && r.rate > 0);
                        }
                      }

                      if (!hasRate) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                l10n.exchangeRatesNotLoadedNewVault,
                              ),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                        return;
                      }
                    }

                    final balanceText = _balanceController.text.trim();
                    double? initialBalance;
                    if (balanceText.isNotEmpty) {
                      final format = NumberFormat.decimalPattern(locale);
                      final decimalSep = format.symbols.DECIMAL_SEP;
                      final groupSep = format.symbols.GROUP_SEP;

                      String clean = balanceText.replaceAll(groupSep, '');
                      if (decimalSep != '.') {
                        clean = clean.replaceAll(decimalSep, '.');
                      }
                      initialBalance = double.tryParse(clean);
                    }
                    
                    final newVault = Vault()
                      ..name = _nameController.text.trim()
                      ..currency = _selectedCurrency;
                    
                    final vaultId = await DatabaseService.addVault(newVault);

                    // Başlangıç bakiyesi varsa otomatik bir "Başlangıç Bakiyesi" işlemi oluştur (Pure Ledger)
                    if (initialBalance != null && initialBalance != 0) {
                      final now = DateTime.now();
                      final txCurrency = _selectedCurrency == 'AUTO' ? baseCurrency : _selectedCurrency;
                      
                      double? snapshotRate;
                      final currencyCode = CurrencyUtils.symbolToCode(txCurrency);
                      if (currencyCode != 'TRY' && currencyCode != '₺') {
                        final rates = await DatabaseService.getAllExchangeRates();
                        final rateRecord = rates.where((r) => r.currencyCode == currencyCode).firstOrNull;
                        if (rateRecord != null && rateRecord.rate > 0) {
                          snapshotRate = rateRecord.rate;
                        }
                      }

                      final tx = TransactionRecord()
                        ..title = l10n.initialBalance
                        ..amount = initialBalance.abs()
                        ..isIncome = initialBalance > 0
                        ..date = now
                        ..occurrenceDate = DateTime(now.year, now.month, now.day)
                        ..vaultId = vaultId
                        ..currency = txCurrency
                        ..snapshotRate = snapshotRate
                        ..categoryId = initialBalance > 0 ? 'inc_other_general' : 'exp_other_general'
                        ..iconCode = 'account_balance_wallet_rounded'
                        ..status = 0
                        ..isReviewed = true
                        ..occurrenceKey = TransactionRecord.generateManualKey();
                      await DatabaseService.addTransaction(tx);
                    }

                    _nameController.clear();
                    _balanceController.clear();
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                activeColor: activeColor,
                height: 64 * sf,
              ),
              SizedBox(height: 24 * sf),
            ],
          ),
        ),
      ],
    );
  }
}
