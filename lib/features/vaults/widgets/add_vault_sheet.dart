import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_constants.dart';
import '../../../core/database/database_service.dart';
import '../../../core/database/models/vault.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../auth/widgets/auth_wave.dart';
import '../../../l10n/app_localizations.dart';

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
              SizedBox(
                height: 50 * sf,
                child: CustomTextField(
                  controller: _nameController,
                  hintText: l10n.vaultNameHint,
                  icon: Icons.drive_file_rename_outline_rounded,
                  autofocus: true,
                  scalingFactor: sf,
                ),
              ),
              
              SizedBox(height: 20 * sf),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  l10n.currency.toUpperCase(),
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
              
              SizedBox(height: 20 * sf),
              SizedBox(
                height: 50 * sf,
                child: CustomTextField(
                  controller: _balanceController,
                  hintText: l10n.initialBalance,
                  icon: Icons.payments_rounded,
                  suffixText: _selectedCurrency == 'AUTO' ? '' : _selectedCurrency,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  scalingFactor: sf,
                ),
              ),
              SizedBox(height: 24 * sf),
              CustomButton(
                label: l10n.createVault,
                onTap: () async {
                  if (_nameController.text.isNotEmpty) {
                    final double? initialBalance = double.tryParse(_balanceController.text.replaceAll(',', '.'));
                    
                    final newVault = Vault()
                      ..name = _nameController.text.trim()
                      ..currency = _selectedCurrency
                      ..balance = initialBalance ?? 0.0
                      ..showOnDashboard = true;
                    
                    await DatabaseService.addVault(newVault);
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
